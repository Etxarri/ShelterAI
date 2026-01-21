"""
ShelterAI - Validation script for the FINAL clustering model (AGGLOMERATIVE)

Goal
----
This script validates the trained *final* Agglomerative model using standard clustering metrics
and checks train vs. test consistency to detect instability / potential overfitting-like behavior.

Notes
-----
- AgglomerativeClustering does NOT support "predict" on new data.
  So for the TEST set we assign clusters by:
    1) computing train centroids in the *same feature space used for clustering*
    2) assigning each test sample to the nearest centroid (Euclidean)

- This is a practical validation approach for hierarchical clustering deployments:
  the "model" is a fixed partition of the training space; new samples are mapped to that partition.

Assumptions
-----------
- You trained the final model with:
    AgglomerativeClustering(n_clusters=30, linkage="ward")
  on the *scaled full feature space* (NO UMAP for clustering).
- artifacts saved in ../models/shelter_model.pkl include:
    - 'clusterer'
    - 'scaler'
    - 'feature_names'
    - 'model_version'
    - 'training_date'
    - 'n_clusters'

If your train/test CSVs are already one-hot encoded, this script aligns columns to feature_names.
If not, you should validate using the same preprocessing pipeline used at training time.
"""

import os
import joblib
import numpy as np
import pandas as pd
from datetime import datetime
from sklearn.metrics import silhouette_score, calinski_harabasz_score, davies_bouldin_score


# ======================
# Configuration
# ======================
MODEL_PATH = "../models/shelter_model.pkl"
TRAIN_DATA_PATH = "../data/train_data.csv"
TEST_DATA_PATH = "../data/test_data.csv"
VALIDATION_REPORT_PATH = "../models/validation_report.txt"

# Final model config (documented best)
FINAL_MODEL_NAME = "AgglomerativeClustering"
FINAL_N_CLUSTERS = 30
FINAL_LINKAGE = "ward"

print("=" * 80)
print("VALIDATION OF FINAL CLUSTERING MODEL (AGGLOMERATIVE)")
print("=" * 80)


# ======================
# 1) Load model artifacts
# ======================
print("\n[1/6] Loading trained model...")
if not os.path.exists(MODEL_PATH):
    print(f"❌ Error: Model not found at {MODEL_PATH}")
    print("   Please run train_final_model.py first.")
    raise SystemExit(1)

artifacts = joblib.load(MODEL_PATH)

print("   ✓ Model loaded successfully")
print(f"   - Version: {artifacts.get('model_version')}")
print(f"   - Training date: {artifacts.get('training_date')}")
print(f"   - n_clusters: {artifacts.get('n_clusters')}")


# ======================
# 2) Preprocess helper
# ======================
def preprocess_aligned(df: pd.DataFrame, feature_names: list) -> pd.DataFrame:
    """
    Align a (possibly one-hot encoded) dataframe to the training feature space.

    - Adds missing columns with 0
    - Drops extra columns
    - Orders columns to match training
    """
    df = df.copy()

    # Add missing
    for col in feature_names:
        if col not in df.columns:
            df[col] = 0

    # Keep only training columns, in order
    return df[feature_names]


# ======================
# 3) Load and scale train/test
# ======================
print("\n[2/6] Loading and preprocessing train/test data...")

feature_names = artifacts["feature_names"]
scaler = artifacts["scaler"]
clusterer = artifacts["clusterer"]

df_train = pd.read_csv(TRAIN_DATA_PATH)
X_train = preprocess_aligned(df_train, feature_names)
X_train_scaled = scaler.transform(X_train)

df_test = pd.read_csv(TEST_DATA_PATH)
X_test = preprocess_aligned(df_test, feature_names)
X_test_scaled = scaler.transform(X_test)

print(f"   ✓ Train: {X_train_scaled.shape[0]} samples | {X_train_scaled.shape[1]} features")
print(f"   ✓ Test : {X_test_scaled.shape[0]} samples | {X_test_scaled.shape[1]} features")


# ======================
# 4) Get train labels (fit_partition) + test labels (nearest centroid)
# ======================
print("\n[3/6] Getting cluster assignments...")

# Train labels: the partition used to train the final model
train_labels = clusterer.fit_predict(X_train_scaled)
n_clusters_train = len(np.unique(train_labels))

print("   ✓ TRAIN:")
print(f"     - Clusters found: {n_clusters_train}")

# Sanity check vs documented final config
if n_clusters_train != FINAL_N_CLUSTERS:
    print(f"   ⚠️ Warning: train produced {n_clusters_train} clusters, but expected {FINAL_N_CLUSTERS}.")
    print("     Check your saved model configuration/artifacts.")

# Compute centroids in scaled feature space
centroids = np.vstack([X_train_scaled[train_labels == c].mean(axis=0) for c in range(n_clusters_train)])

# Assign test points to nearest centroid (Euclidean)
# (vectorized distance computation)
# dist[i, c] = ||x_i - centroid_c||^2
dists = (
    (X_test_scaled ** 2).sum(axis=1, keepdims=True)
    - 2 * (X_test_scaled @ centroids.T)
    + (centroids ** 2).sum(axis=1)
)
test_labels = np.argmin(dists, axis=1)

n_clusters_test = len(np.unique(test_labels))
print("   ✓ TEST (nearest-centroid mapping):")
print(f"     - Clusters used: {n_clusters_test} (should match train: {n_clusters_train})")


# ======================
# 5) Compute clustering metrics (train + test)
# ======================
print("\n[4/6] Computing clustering metrics...")

results = {"train": {}, "test": {}, "comparison": {}}

# ---- Train metrics ----
print("\n   📊 TRAIN SET:")
train_silhouette = silhouette_score(X_train_scaled, train_labels)
train_ch = calinski_harabasz_score(X_train_scaled, train_labels)
train_db = davies_bouldin_score(X_train_scaled, train_labels)

results["train"]["silhouette"] = float(train_silhouette)
results["train"]["calinski_harabasz"] = float(train_ch)
results["train"]["davies_bouldin"] = float(train_db)

print(f"     - Silhouette Score: {train_silhouette:.4f}")
print(f"     - Calinski-Harabasz: {train_ch:.2f}")
print(f"     - Davies-Bouldin: {train_db:.4f}")

train_dist = pd.Series(train_labels).value_counts().sort_index()
results["train"]["cluster_distribution"] = train_dist.to_dict()

# ---- Test metrics ----
print("\n   📊 TEST SET (mapped to train centroids):")
test_silhouette = silhouette_score(X_test_scaled, test_labels)
test_ch = calinski_harabasz_score(X_test_scaled, test_labels)
test_db = davies_bouldin_score(X_test_scaled, test_labels)

results["test"]["silhouette"] = float(test_silhouette)
results["test"]["calinski_harabasz"] = float(test_ch)
results["test"]["davies_bouldin"] = float(test_db)

print(f"     - Silhouette Score: {test_silhouette:.4f}")
print(f"     - Calinski-Harabasz: {test_ch:.2f}")
print(f"     - Davies-Bouldin: {test_db:.4f}")

test_dist = pd.Series(test_labels).value_counts().sort_index()
results["test"]["cluster_distribution"] = test_dist.to_dict()


# ======================
# 6) Train vs test consistency checks (stability)
# ======================
print("\n[5/6] Train vs test consistency checks...")

silhouette_diff = abs(train_silhouette - test_silhouette)
ch_diff_percent = abs(train_ch - test_ch) / (abs(train_ch) + 1e-12) * 100
db_diff_percent = abs(train_db - test_db) / (abs(train_db) + 1e-12) * 100

results["comparison"]["silhouette_diff"] = float(silhouette_diff)
results["comparison"]["ch_diff_percent"] = float(ch_diff_percent)
results["comparison"]["db_diff_percent"] = float(db_diff_percent)

print(f"   - Silhouette diff: {silhouette_diff:.4f}")
print(f"   - Calinski-Harabasz diff: {ch_diff_percent:.2f}%")
print(f"   - Davies-Bouldin diff: {db_diff_percent:.2f}%")

# Simple warning rules (practical heuristics)
overfitting_like = False
warnings = []

if silhouette_diff > 0.15:
    overfitting_like = True
    warnings.append(f"⚠️ Large silhouette shift (diff={silhouette_diff:.4f})")

if ch_diff_percent > 30:
    overfitting_like = True
    warnings.append(f"⚠️ Large CH shift ({ch_diff_percent:.1f}%)")

if db_diff_percent > 30:
    overfitting_like = True
    warnings.append(f"⚠️ Large DB shift ({db_diff_percent:.1f}%)")

results["comparison"]["flagged_instability"] = overfitting_like
results["comparison"]["warnings"] = warnings


# ======================
# 7) Final summary + save report
# ======================
print("\n[6/6] Final summary + saving report...")

def silhouette_quality_label(v: float) -> str:
    if v > 0.50:
        return "EXCELLENT"
    if v > 0.30:
        return "GOOD"
    if v > 0.20:
        return "ACCEPTABLE"
    return "WEAK"

def db_quality_label(v: float) -> str:
    if v < 1.0:
        return "EXCELLENT"
    if v < 1.5:
        return "GOOD"
    if v < 2.0:
        return "ACCEPTABLE"
    return "WEAK"

train_sil_q = silhouette_quality_label(train_silhouette)
test_sil_q = silhouette_quality_label(test_silhouette)
train_db_q = db_quality_label(train_db)
test_db_q = db_quality_label(test_db)

print("\n" + "=" * 80)
print("VALIDATION SUMMARY")
print("=" * 80)

print("\n📌 MODEL CONFIG (FINAL):")
print(f"   - Model: {FINAL_MODEL_NAME}")
print(f"   - n_clusters: {FINAL_N_CLUSTERS}")
print(f"   - linkage: {FINAL_LINKAGE}")

print("\n📈 CLUSTERING QUALITY:")
print(f"   - Silhouette: Train {train_silhouette:.4f} [{train_sil_q}] | Test {test_silhouette:.4f} [{test_sil_q}]")
print(f"   - Davies-Bouldin: Train {train_db:.4f} [{train_db_q}] | Test {test_db:.4f} [{test_db_q}]")

print("\n🎯 STABILITY CHECK (train vs test):")
if not overfitting_like:
    print("   ✅ No major instability detected (metrics are reasonably consistent).")
else:
    print("   ⚠️ Possible instability detected:")
    for w in warnings:
        print(f"   - {w}")

print("\n📊 CLUSTER DISTRIBUTION:")
print("   TRAIN:")
for c in train_dist.index:
    count = int(train_dist[c])
    print(f"     Cluster {c:2d}: {count:5d} ({count/len(train_labels)*100:5.1f}%)")
print("   TEST:")
for c in test_dist.index:
    count = int(test_dist[c])
    print(f"     Cluster {c:2d}: {count:5d} ({count/len(test_labels)*100:5.1f}%)")


# Save report
os.makedirs(os.path.dirname(VALIDATION_REPORT_PATH), exist_ok=True)

with open(VALIDATION_REPORT_PATH, "w", encoding="utf-8") as f:
    f.write("SHELTERAI - CLUSTER MODEL VALIDATION REPORT\n")
    f.write("=" * 80 + "\n\n")
    f.write(f"Validation date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    f.write(f"Model path: {MODEL_PATH}\n")
    f.write(f"Model version: {artifacts.get('model_version')}\n")
    f.write(f"Training date: {artifacts.get('training_date')}\n\n")

    f.write("FINAL MODEL CONFIG\n")
    f.write("-" * 80 + "\n")
    f.write(f"Model: {FINAL_MODEL_NAME}\n")
    f.write(f"n_clusters: {FINAL_N_CLUSTERS}\n")
    f.write(f"linkage: {FINAL_LINKAGE}\n\n")

    f.write("METRICS\n")
    f.write("-" * 80 + "\n")
    f.write("TRAIN:\n")
    f.write(f"  Silhouette:        {train_silhouette:.4f} [{train_sil_q}]\n")
    f.write(f"  Calinski-Harabasz: {train_ch:.2f}\n")
    f.write(f"  Davies-Bouldin:    {train_db:.4f} [{train_db_q}]\n")
    f.write(f"  Samples:           {len(train_labels)}\n")
    f.write(f"  Clusters:          {n_clusters_train}\n\n")

    f.write("TEST (nearest-centroid mapping):\n")
    f.write(f"  Silhouette:        {test_silhouette:.4f} [{test_sil_q}]\n")
    f.write(f"  Calinski-Harabasz: {test_ch:.2f}\n")
    f.write(f"  Davies-Bouldin:    {test_db:.4f} [{test_db_q}]\n")
    f.write(f"  Samples:           {len(test_labels)}\n")
    f.write(f"  Clusters:          {n_clusters_test}\n\n")

    f.write("TRAIN vs TEST CONSISTENCY\n")
    f.write("-" * 80 + "\n")
    f.write(f"  Silhouette diff:        {silhouette_diff:.4f}\n")
    f.write(f"  Calinski-Harabasz diff: {ch_diff_percent:.2f}%\n")
    f.write(f"  Davies-Bouldin diff:    {db_diff_percent:.2f}%\n\n")

    f.write("STABILITY FLAGS\n")
    f.write("-" * 80 + "\n")
    if not overfitting_like:
        f.write("✅ No major instability detected.\n\n")
    else:
        f.write("⚠️ Possible instability detected:\n")
        for w in warnings:
            f.write(f"  - {w}\n")
        f.write("\n")

    f.write("CLUSTER DISTRIBUTION\n")
    f.write("-" * 80 + "\n")
    f.write("TRAIN:\n")
    for c in train_dist.index:
        count = int(train_dist[c])
        f.write(f"  Cluster {c:2d}: {count:5d} ({count/len(train_labels)*100:5.1f}%)\n")
    f.write("\nTEST:\n")
    for c in test_dist.index:
        count = int(test_dist[c])
        f.write(f"  Cluster {c:2d}: {count:5d} ({count/len(test_labels)*100:5.1f}%)\n")

print(f"\n💾 Report saved to: {VALIDATION_REPORT_PATH}")

print("\n" + "=" * 80)
print("✅ VALIDATION COMPLETED SUCCESSFULLY")
print("=" * 80)
