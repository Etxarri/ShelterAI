"""
ShelterAI - Predictor Class for Inference
Loads the trained Agglomerative model and performs cluster assignment using KNN.
"""

from __future__ import annotations

import os
from pathlib import Path
from typing import Dict, Any, Optional, Tuple, List

import numpy as np
import pandas as pd
import joblib
from sklearn.neighbors import NearestNeighbors


class ShelterPredictor:
    """
    Predictor for ShelterAI clustering model.
    
    Since AgglomerativeClustering doesn't have a predict() method,
    we use KNN on the training data to assign new samples to clusters.
    """
    
    def __init__(self, model_path: str):
        """
        Load the trained model artifacts.
        
        Args:
            model_path: Path to the .pkl file containing the model artifacts
        """
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"Model file not found: {model_path}")
        
        print(f"Loading model from: {model_path}")
        artifacts = joblib.load(model_path)
        
        # Extract components
        self.clusterer = artifacts.get("clusterer")
        self.scaler = artifacts.get("scaler")
        self.numeric_imputer = artifacts.get("numeric_imputer")
        self.categorical_imputer = artifacts.get("categorical_imputer")
        
        # Feature information
        self.feature_names = artifacts.get("feature_names", [])
        self.numeric_cols = artifacts.get("numeric_cols", [])
        self.categorical_cols = artifacts.get("categorical_cols", [])
        
        # Training data for KNN prediction
        self.X_train_scaled = artifacts.get("X_train_scaled")
        self.y_train_clusters = artifacts.get("y_train_clusters")
        
        # Statistical information
        self.global_feature_mean = artifacts.get("global_feature_mean")
        self.global_feature_std = artifacts.get("global_feature_std")
        self.cluster_feature_mean = artifacts.get("cluster_feature_mean")
        self.cluster_sizes = artifacts.get("cluster_sizes")
        
        # Cluster profiles and metadata
        self.cluster_profiles = artifacts.get("cluster_profiles", {})
        self.clusters_index = artifacts.get("clusters_index", [])
        self.n_clusters = artifacts.get("n_clusters", 0)
        self.model_version = artifacts.get("model_version", "unknown")
        
        print(f"✓ Model loaded: {self.model_version}")
        print(f"  - Features: {len(self.feature_names)}")
        print(f"  - Clusters: {self.n_clusters}")
        print(f"  - Training samples: {len(self.y_train_clusters) if self.y_train_clusters is not None else 0}")
    
    def align_features(self, features: Dict[str, Any]) -> Tuple[np.ndarray, Dict[str, Any]]:
        """
        Align input features with expected feature names.
        
        Args:
            features: Dictionary of feature name -> value
            
        Returns:
            Tuple of (aligned feature array, metadata dict)
        """
        aligned = np.zeros((1, len(self.feature_names)), dtype=np.float32)
        
        provided_count = 0
        missing_count = 0
        
        for i, fname in enumerate(self.feature_names):
            if fname in features:
                aligned[0, i] = float(features[fname])
                provided_count += 1
            else:
                missing_count += 1
        
        metadata = {
            "n_features_expected": len(self.feature_names),
            "n_features_provided": provided_count,
            "n_features_missing": missing_count,
        }
        
        return aligned, metadata
    
    def predict_cluster(
        self, 
        features: Dict[str, Any], 
        k_neighbors: int = 25
    ) -> Tuple[int, float]:
        """
        Predict cluster assignment for new data using KNN.
        
        Args:
            features: Dictionary of feature name -> value
            k_neighbors: Number of neighbors to use for KNN voting
            
        Returns:
            Tuple of (cluster_id, confidence)
        """
        # Align features
        X_aligned, _ = self.align_features(features)
        
        # Scale
        X_scaled = self.scaler.transform(X_aligned)
        
        # KNN prediction on training data
        if self.X_train_scaled is None or self.y_train_clusters is None:
            raise RuntimeError("Training data not available for KNN prediction")
        
        # Find k nearest neighbors
        knn = NearestNeighbors(n_neighbors=min(k_neighbors, len(self.X_train_scaled)))
        knn.fit(self.X_train_scaled)
        
        distances, indices = knn.kneighbors(X_scaled)
        
        # Get cluster labels of neighbors
        neighbor_clusters = self.y_train_clusters[indices[0]]
        
        # Majority vote
        unique, counts = np.unique(neighbor_clusters, return_counts=True)
        cluster_id = int(unique[np.argmax(counts)])
        confidence = float(np.max(counts) / len(neighbor_clusters))
        
        return cluster_id, confidence
    
    def top_person_features(
        self, 
        features: Dict[str, Any], 
        cluster_id: int, 
        top_n: int = 8
    ) -> List[Dict[str, Any]]:
        """
        Get top distinguishing features for a specific person.
        
        Args:
            features: Dictionary of feature name -> value
            cluster_id: The assigned cluster
            top_n: Number of top features to return
            
        Returns:
            List of feature dictionaries with comparisons
        """
        X_aligned, _ = self.align_features(features)
        person_values = X_aligned[0]
        
        results = []
        
        for i, fname in enumerate(self.feature_names):
            person_val = float(person_values[i])
            global_mean = float(self.global_feature_mean[i])
            cluster_mean = float(self.cluster_feature_mean[cluster_id, i])
            
            delta_global = person_val - global_mean
            delta_cluster = person_val - cluster_mean
            
            results.append({
                "feature": fname,
                "value": person_val,
                "global_mean": global_mean,
                "cluster_mean": cluster_mean,
                "delta_vs_global": delta_global,
                "delta_vs_cluster": delta_cluster,
                "abs_delta_global": abs(delta_global),
            })
        
        # Sort by absolute delta vs global
        results.sort(key=lambda x: x["abs_delta_global"], reverse=True)
        
        # Return top N
        return results[:top_n]
    
    def get_cluster_profile(self, cluster_id: int) -> Optional[Dict[str, Any]]:
        """
        Get the profile for a specific cluster.
        
        Args:
            cluster_id: The cluster ID
            
        Returns:
            Cluster profile dictionary or None if not found
        """
        return self.cluster_profiles.get(cluster_id)
    
    def get_clusters_index(self) -> List[Dict[str, Any]]:
        """
        Get the index of all clusters with sizes and shares.
        
        Returns:
            List of cluster summary dictionaries
        """
        return self.clusters_index
