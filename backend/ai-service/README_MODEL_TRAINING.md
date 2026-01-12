# 🤖 ShelterAI - Model Training Guide

This guide explains how to train the HDBSCAN clustering model used for refugee classification.

---

## 📋 Overview

The ShelterAI system uses **HDBSCAN** (Hierarchical Density-Based Spatial Clustering of Applications with Noise) to classify refugees into vulnerability clusters. This helps match refugees with appropriate shelters based on their profiles.

**What you'll learn:**
1. Setting up the Python environment
2. Understanding the training data
3. Training the clustering model
4. Validating the trained model

---

## 🛠️ Prerequisites

- **Python 3.11** (recommended for compatibility)
- **8GB RAM minimum** (for model training)
- **Training dataset** (`data/data.csv`)

---

## 📦 Step 1: Create Python Environment

### Option A: Using Conda (Recommended)

```powershell
# Navigate to ai-service folder
cd backend\ai-service

# Create conda environment with Python 3.11
conda create -n ai-service python=3.11

# Activate environment
conda activate ai-service
```

### Option B: Using venv

```powershell
# Navigate to ai-service folder
cd backend\ai-service

# Create virtual environment
python -m venv venv

# Activate environment (Windows PowerShell)
.\venv\Scripts\Activate

# Activate environment (Windows CMD)
.\venv\Scripts\activate.bat
```

---

## 📥 Step 2: Install Dependencies

```powershell
# Make sure environment is activated
# You should see (ai-service) or (venv) in your prompt

# Install all required packages
pip install -r requirements.txt
```

**Key packages installed:**
- `numpy==1.26.3` - Numerical computing
- `pandas==2.1.4` - Data manipulation
- `scikit-learn==1.4.0` - Machine learning utilities
- `hdbscan==0.8.38.post1` - Clustering algorithm
- `umap-learn==0.5.5` - Dimensionality reduction
- `joblib==1.3.2` - Model serialization

**Note:** If you encounter issues with `hdbscan`, make sure you're using Python 3.11 and have the latest version (0.8.38.post1), which includes precompiled wheels.

---

## 📊 Step 3: Understand the Training Data

The training data is located in `data/data.csv` and contains refugee profiles with features like:

**Demographic Information:**
- Age, gender, nationality
- Family size, number of children
- Marital status

**Needs & Requirements:**
- Medical conditions
- Disability status
- Language preferences
- Education level

**Vulnerability Indicators:**
- Employment status
- Income level
- Previous displacement history
- Trauma indicators

**Dataset Statistics:**
- **Rows:** 8,957 refugee profiles
- **Original columns:** 256 features
- **After encoding:** 555 features (one-hot encoded)
- **Missing values:** Imputed using median/mode strategies

---

## 🚀 Step 4: Train the Model

```powershell
# Navigate to training folder
cd model_training

# Run the training script
python train_final_model.py
```

### Training Process

The script performs these steps:

**1. Data Loading**
```
[1/6] Loading data...
   ✓ Dataset loaded: 8957 rows, 256 columns
```

**2. Preprocessing**
```
[2/6] Preprocessing data...
   ✓ Dropped columns: 9 (irrelevant features)
   ✓ Missing values imputed
   ✓ Categorical encoding complete
   ✓ Final shape: (8957, 555)
```
- Removes ID columns and irrelevant features
- Imputes missing values (median for numeric, mode for categorical)
- One-hot encodes categorical variables

**3. Feature Scaling**
```
[3/6] Scaling data...
   ✓ StandardScaler applied
```
- Normalizes features to have mean=0, std=1
- Essential for distance-based clustering

**4. Dimensionality Reduction**
```
[4/6] Dimensionality reduction (UMAP)...
   ✓ Reduced from 555 → 10 dimensions
```
- Uses UMAP (Uniform Manifold Approximation and Projection)
- Reduces computational complexity
- Preserves local and global structure

**5. HDBSCAN Clustering**
```
[5/6] Training HDBSCAN...
   ✓ Clusters found: 54
   ✓ Noise points: 1234
```
- **min_cluster_size:** 60 (minimum refugees per cluster)
- **min_samples:** 5 (core point threshold)
- Automatically determines optimal number of clusters
- Identifies outliers as noise (-1 label)

**6. Model Saving**
```
[6/6] Saving model...
   ✓ Model saved: ../models/shelter_model.pkl
   ✓ Size: ~2.5 MB
```

### Expected Training Time
- **Small dataset (< 5K rows):** 1-2 minutes
- **Medium dataset (5K-10K rows):** 3-5 minutes
- **Large dataset (> 10K rows):** 5-10 minutes

---

## ✅ Step 5: Verify the Trained Model

After training, check that these files were created:

```powershell
# List model files
ls ..\models\

# Expected output:
# shelter_model.pkl         (~2.5 MB)
# model_metadata.txt        (~1 KB)
```

### Check Model Metadata

```powershell
# View model information
cat ..\models\model_metadata.txt
```

**Expected content:**
```
Model Training Metadata
=======================
Training Date: 2026-01-07 14:30:00
Training Duration: 4.2 minutes

Dataset Statistics:
- Total samples: 8957
- Features (original): 256
- Features (after encoding): 555
- Features (after UMAP): 10

HDBSCAN Parameters:
- min_cluster_size: 60
- min_samples: 5

Clustering Results:
- Clusters found: 54
- Noise points: 1234 (13.8%)
- Average cluster size: 143
- Largest cluster: 457 samples
- Smallest cluster: 62 samples

Model Components:
- Preprocessor: StandardScaler
- Dimensionality Reduction: UMAP (n_components=10)
- Clustering: HDBSCAN

Model File: shelter_model.pkl
Model Size: 2.5 MB
```

---

## 🔬 Step 6: Test the Model (Optional)

You can test the trained model with a simple Python script:

```python
# test_model.py
import joblib
import numpy as np
import pandas as pd

# Load the trained model
model = joblib.load('../models/shelter_model.pkl')

print("Model loaded successfully!")
print(f"Model type: {type(model)}")
print(f"Components: {model.keys() if hasattr(model, 'keys') else 'N/A'}")

# Load test data
test_data = pd.read_csv('../data/test_data.csv')
print(f"\nTest data shape: {test_data.shape}")

# Note: You'll need to preprocess test_data the same way as training data
# before making predictions
```

Run the test:
```powershell
python test_model.py
```

---

## 📊 Understanding the Clusters

The model creates **54 vulnerability clusters** based on refugee profiles:

**High Vulnerability Clusters (0-17):**
- Large families with medical needs
- Elderly refugees with disabilities
- Single parents with multiple children
- Refugees with severe trauma

**Medium Vulnerability Clusters (18-35):**
- Small families without special needs
- Young adults seeking employment
- Educated refugees with job skills

**Low Vulnerability Clusters (36-53):**
- Single adults without dependents
- Employed refugees with stable income
- Refugees with local language skills

**Noise (-1):**
- Outliers that don't fit any cluster pattern
- Treated as high vulnerability by default

---

## 🔧 Advanced: Tuning Parameters

If you want to experiment with different clustering parameters, edit `train_final_model.py`:

```python
# Line ~80 (HDBSCAN parameters)
clusterer = hdbscan.HDBSCAN(
    min_cluster_size=60,      # Increase for larger, fewer clusters
    min_samples=5,             # Increase for stricter core points
    cluster_selection_epsilon=0.0,
    metric='euclidean'
)

# Line ~60 (UMAP parameters)
reducer = umap.UMAP(
    n_components=10,          # Dimensions to reduce to
    n_neighbors=15,           # Local structure preservation
    min_dist=0.1,             # Cluster tightness
    random_state=42
)
```

**Parameter Guidelines:**
- **min_cluster_size:** Higher = fewer, larger clusters (30-100 recommended)
- **min_samples:** Higher = stricter clustering, more noise (5-20 recommended)
- **n_components:** Lower = faster but less information (5-15 recommended)

After changing parameters, retrain:
```powershell
python train_final_model.py
```

---

## 🛠️ Troubleshooting

### Issue: ImportError for hdbscan

**Error:**
```
ImportError: DLL load failed while importing _hdbscan_tree
```

**Solution:**
```powershell
# Upgrade to version with precompiled wheels
pip install --upgrade hdbscan==0.8.38.post1

# If still failing, install Microsoft Visual C++ 14.0+
# Download from: https://visualstudio.microsoft.com/visual-cpp-build-tools/
```

---

### Issue: Memory Error during training

**Error:**
```
MemoryError: Unable to allocate array
```

**Solution:**
```powershell
# Reduce dataset size or UMAP dimensions
# Edit train_final_model.py, line ~60:
n_components=5  # Instead of 10

# Or sample the dataset (line ~30):
data = data.sample(n=5000, random_state=42)
```

---

### Issue: Training takes too long

**Causes:**
- Large dataset (> 10K rows)
- High dimensionality
- Slow CPU

**Solutions:**
```powershell
# Option 1: Reduce UMAP dimensions (faster, less accurate)
n_components=5

# Option 2: Sample the dataset
data = data.sample(frac=0.7, random_state=42)  # Use 70% of data

# Option 3: Increase min_cluster_size (faster clustering)
min_cluster_size=100
```

---

### Issue: Too many/few clusters

**Too many clusters (> 80):**
```python
# Increase min_cluster_size
min_cluster_size=100  # Default: 60
```

**Too few clusters (< 30):**
```python
# Decrease min_cluster_size
min_cluster_size=40  # Default: 60

# Or decrease min_samples
min_samples=3  # Default: 5
```

---

## 📈 Model Performance Metrics

After training, evaluate cluster quality:

```python
# Add to train_final_model.py for validation
from sklearn.metrics import silhouette_score, davies_bouldin_score

# Calculate metrics (exclude noise points)
mask = labels != -1
if mask.sum() > 0:
    silhouette = silhouette_score(X_umap[mask], labels[mask])
    davies_bouldin = davies_bouldin_score(X_umap[mask], labels[mask])
    
    print(f"\nCluster Quality Metrics:")
    print(f"   Silhouette Score: {silhouette:.3f}")  # Higher is better (-1 to 1)
    print(f"   Davies-Bouldin Index: {davies_bouldin:.3f}")  # Lower is better
```

**Good clustering:**
- Silhouette Score: > 0.5
- Davies-Bouldin Index: < 1.0
- Noise ratio: 10-20%

---

## 🎯 Next Steps

Once the model is trained:

1. ✅ **Model file created:** `models/shelter_model.pkl`
2. ✅ **Metadata saved:** `models/model_metadata.txt`
3. ➡️ **Deploy with Docker:** See [README_DOCKER.md](README_DOCKER.md)
4. ➡️ **Set up API:** See [README_SETUP.md](README_SETUP.md)

---

## 📚 Further Reading

**HDBSCAN Algorithm:**
- [Official Documentation](https://hdbscan.readthedocs.io/)
- [Original Paper](https://link.springer.com/chapter/10.1007/978-3-642-37456-2_14)

**UMAP Dimensionality Reduction:**
- [Official Documentation](https://umap-learn.readthedocs.io/)
- [Understanding UMAP](https://pair-code.github.io/understanding-umap/)

**Clustering Best Practices:**
- Preprocessing: Handle missing values, scale features
- Validation: Use multiple metrics, visualize clusters
- Iteration: Experiment with parameters, retrain as needed

---

## 📝 Model Versioning

When retraining the model:

```powershell
# Backup previous model
copy ..\models\shelter_model.pkl ..\models\shelter_model_backup_2026-01-07.pkl

# Train new model
python train_final_model.py

# Compare performance before deploying
```

---

**🎓 Educational Project** - Universidad del País Vasco (UPV/EHU)
