"""
Script to train the final AGGLOMERATIVE clustering model (Ward, k=30)
This script trains the model and saves all the artifacts needed for inference.

Inference strategy (because AgglomerativeClustering has no .predict()):
- Fit Agglomerative on X_scaled
- Save X_train_scaled + y_train_clusters
- At inference: scale incoming feature vector -> KNN over X_train_scaled -> majority vote cluster
"""

from __future__ import annotations

import os
from pathlib import Path
from datetime import datetime
import argparse

import numpy as np
import pandas as pd
import joblib

from sklearn.cluster import AgglomerativeClustering
from sklearn.preprocessing import StandardScaler
from sklearn.impute import SimpleImputer


def resolve_path(p: str) -> Path:
    return Path(p).expanduser().resolve()


def build_cluster_profiles(
    X_encoded_df: pd.DataFrame,
    y: np.ndarray,
    top_n: int = 12,
) -> tuple[dict, list, np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    """
    Build interpretable cluster profiles in the *encoded feature space* (before scaling):
    - global mean/std per feature
    - per-cluster mean per feature
    - top positive/negative features vs global (z of delta)
    """
    feature_names = X_encoded_df.columns.tolist()
    X = X_encoded_df.to_numpy(dtype=np.float32)

    n_samples, n_features = X.shape
    n_clusters = int(np.max(y)) + 1

    global_mean = X.mean(axis=0)
    global_std = X.std(axis=0)  # population std (ddof=0)
    eps = 1e-9
    safe_std = np.where(global_std < eps, 1.0, global_std)

    cluster_sizes = np.bincount(y, minlength=n_clusters).astype(int)
    cluster_mean = np.zeros((n_clusters, n_features), dtype=np.float32)

    for c in range(n_clusters):
        mask = (y == c)
        if mask.sum() > 0:
            cluster_mean[c] = X[mask].mean(axis=0)

    cluster_profiles: dict[int, dict] = {}
    clusters_index: list[dict] = []

    for c in range(n_clusters):
        n_c = int(cluster_sizes[c])
        share = float(n_c / n_samples) if n_samples > 0 else 0.0

        delta = cluster_mean[c] - global_mean
        z = delta / safe_std

        # Top positive and negative by z of delta
        pos_idx = np.argsort(-z)[:top_n]
        neg_idx = np.argsort(z)[:top_n]

        top_positive = []
        for i in pos_idx:
            top_positive.append(
                {
                    "feature": feature_names[i],
                    "cluster_mean": float(cluster_mean[c, i]),
                    "global_mean": float(global_mean[i]),
                    "delta": float(delta[i]),
                    "z_score": float(z[i]),
                    "direction": "higher in cluster",
                }
            )

        top_negative = []
        for i in neg_idx:
            top_negative.append(
                {
                    "feature": feature_names[i],
                    "cluster_mean": float(cluster_mean[c, i]),
                    "global_mean": float(global_mean[i]),
                    "delta": float(delta[i]),
                    "z_score": float(z[i]),
                    "direction": "lower in cluster",
                }
            )

        cluster_profiles[c] = {
            "cluster_id": int(c),
            "n": n_c,
            "share": share,
            "top_positive": top_positive,
            "top_negative": top_negative,
        }

        clusters_index.append({"cluster_id": int(c), "n": n_c, "share": share})

    return (
        cluster_profiles,
        clusters_index,
        global_mean.astype(np.float32),
        global_std.astype(np.float32),
        cluster_mean.astype(np.float32),
        cluster_sizes.astype(np.int32),
    )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--data",
        default=str((Path(__file__).resolve().parent.parent / "data" / "data.csv").resolve()),
        help="Path to data.csv",
    )
    parser.add_argument(
        "--out",
        default=str((Path(__file__).resolve().parent.parent / "models" / "shelter_model.pkl").resolve()),
        help="Output .pkl model path",
    )
    parser.add_argument(
        "--n-clusters",
        type=int,
        default=30,
        help="Number of clusters (final: 30)",
    )
    args = parser.parse_args()

    data_path = resolve_path(args.data)
    out_path = resolve_path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    print("=" * 60)
    print("FINAL CLUSTERING MODEL TRAINING (AGGLOMERATIVE)")
    print("=" * 60)

    print("\n[1/5] Loading data...")
    if not data_path.exists():
        raise FileNotFoundError(f"Data file not found: {data_path}")
    df = pd.read_csv(data_path)
    print(f"   ✓ Dataset loaded: {df.shape[0]} rows, {df.shape[1]} columns")
    print(f"   ✓ Data path: {data_path}")

    print("\n[2/5] Preprocessing...")

    columns_to_drop = [
        "pseudo_id", "today", "interviewtype", "monitor_gender",
        "interview_province", "interview_district", "site_001",
        "assessment_modality", "weight",
    ]
    df_processed = df.drop(columns=[c for c in columns_to_drop if c in df.columns])
    print(f"   ✓ Columns dropped: {len([c for c in columns_to_drop if c in df.columns])}")

    numeric_cols = df_processed.select_dtypes(include=["int64", "float64", "int32", "float32"]).columns.tolist()
    categorical_cols = df_processed.select_dtypes(include=["object", "bool"]).columns.tolist()

    print(f"   ✓ Numeric columns: {len(numeric_cols)}")
    print(f"   ✓ Categorical columns: {len(categorical_cols)}")

    num_imputer = SimpleImputer(strategy="median")
    cat_imputer = SimpleImputer(strategy="constant", fill_value="Unknown")

    if numeric_cols:
        df_processed[numeric_cols] = num_imputer.fit_transform(df_processed[numeric_cols])

    if categorical_cols:
        df_processed[categorical_cols] = cat_imputer.fit_transform(df_processed[categorical_cols])

    df_encoded = pd.get_dummies(df_processed, drop_first=True)
    feature_names = df_encoded.columns.tolist()
    print(f"   ✓ Encoded features: {len(feature_names)}")

    print("\n[3/5] Scaling + training Agglomerative...")
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(df_encoded).astype(np.float32)

    k = int(args.n_clusters)
    clusterer = AgglomerativeClustering(n_clusters=k, linkage="ward")
    y = clusterer.fit_predict(X_scaled).astype(np.int32)

    n_clusters_found = len(np.unique(y))
    print(f"   ✓ Clustering completed (requested k={k})")
    print(f"     - Clusters found: {n_clusters_found}")

    print("\n[4/5] Building cluster profiles (interpretable)...")
    (
        cluster_profiles,
        clusters_index,
        global_mean,
        global_std,
        cluster_feature_mean,
        cluster_sizes,
    ) = build_cluster_profiles(df_encoded, y, top_n=12)

    print("   ✓ Profiles built")
    print(f"     - Example cluster 0 top features: {[x['feature'] for x in cluster_profiles[0]['top_positive'][:5]]}")

    print("\n[5/5] Saving artifacts...")
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    artifacts = {
        # model
        "clusterer": clusterer,
        "scaler": scaler,
        "numeric_imputer": num_imputer,
        "categorical_imputer": cat_imputer,

        # features
        "feature_names": feature_names,
        "numeric_cols": numeric_cols,
        "categorical_cols": categorical_cols,

        # inference essentials (Agglomerative has no .predict)
        "X_train_scaled": X_scaled,            # (n_samples, n_features)
        "y_train_clusters": y,                 # (n_samples,)

        # global + cluster stats for explanations
        "global_feature_mean": global_mean,            # (n_features,)
        "global_feature_std": global_std,              # (n_features,)
        "cluster_feature_mean": cluster_feature_mean,  # (n_clusters, n_features)
        "cluster_sizes": cluster_sizes,                # (n_clusters,)

        # human-usable summaries
        "cluster_profiles": cluster_profiles,  # dict[int -> profile]
        "clusters_index": clusters_index,      # list[{"cluster_id","n","share"}]

        # metadata
        "n_clusters": int(k),
        "training_date": timestamp,
        "model_version": "2.0-agglomerative-ward-k30",
    }

    joblib.dump(artifacts, out_path)
    print(f"   ✓ Model saved at: {out_path}")

    meta_path = out_path.with_suffix(".metadata.txt")
    with open(meta_path, "w", encoding="utf-8") as f:
        f.write("SHELTERAI - FINAL CLUSTERING MODEL (AGGLOMERATIVE)\n")
        f.write("=" * 70 + "\n\n")
        f.write(f"training_date: {timestamp}\n")
        f.write(f"model_version: {artifacts['model_version']}\n")
        f.write(f"n_samples: {X_scaled.shape[0]}\n")
        f.write(f"n_features: {X_scaled.shape[1]}\n")
        f.write(f"n_clusters: {k}\n")
        f.write("\nClusters index:\n")
        for row in clusters_index:
            f.write(f"  cluster {row['cluster_id']}: n={row['n']} share={row['share']:.4f}\n")

    print(f"   ✓ Metadata saved at: {meta_path}")

    print("\n" + "=" * 60)
    print("✅ TRAINING COMPLETED SUCCESSFULLY")
    print("=" * 60)


if __name__ == "__main__":
    main()
