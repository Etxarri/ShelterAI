"""
Script para entrenar el modelo final de clustering HDBSCAN
Este script entrena el modelo y guarda todos los artefactos necesarios para inferencia
"""

import pandas as pd
import numpy as np
import joblib
import hdbscan
import umap.umap_ as umap
from sklearn.preprocessing import StandardScaler
from sklearn.impute import SimpleImputer
import os
from datetime import datetime

# Configuración
MODEL_DIR = '../models'
DATA_PATH = '../data/data.csv'
RANDOM_STATE = 42

# Crear directorio de modelos si no existe
os.makedirs(MODEL_DIR, exist_ok=True)

print("=" * 60)
print("ENTRENAMIENTO DEL MODELO FINAL DE CLUSTERING")
print("=" * 60)

# 1. CARGA DE DATOS
print("\n[1/6] Cargando datos...")
df = pd.read_csv(DATA_PATH)
print(f"   ✓ Dataset cargado: {df.shape[0]} filas, {df.shape[1]} columnas")

# 2. PREPROCESAMIENTO
print("\n[2/6] Preprocesando datos...")

# Columnas a eliminar (no aportan información útil para clustering)
columns_to_drop = [
    'pseudo_id', 'today', 'interviewtype', 'monitor_gender',
    'interview_province', 'interview_district', 'site_001',
    'assessment_modality', 'weight'  # weight es para ponderación estadística, no para clustering
]

df_processed = df.drop(columns=[col for col in columns_to_drop if col in df.columns])
print(f"   ✓ Columnas eliminadas: {len([c for c in columns_to_drop if c in df.columns])}")

# Identificar tipos de columnas
numeric_cols = df_processed.select_dtypes(include=['int64', 'float64']).columns.tolist()
categorical_cols = df_processed.select_dtypes(include=['object']).columns.tolist()

print(f"   ✓ Columnas numéricas: {len(numeric_cols)}")
print(f"   ✓ Columnas categóricas: {len(categorical_cols)}")

# Imputar valores faltantes
# Numéricas: mediana
num_imputer = SimpleImputer(strategy='median')
df_processed[numeric_cols] = num_imputer.fit_transform(df_processed[numeric_cols])

# Categóricas: constante 'Unknown'
cat_imputer = SimpleImputer(strategy='constant', fill_value='Unknown')
df_processed[categorical_cols] = cat_imputer.fit_transform(df_processed[categorical_cols])

print(f"   ✓ Valores faltantes imputados")

# Convertir categóricas a dummies (one-hot encoding)
df_encoded = pd.get_dummies(df_processed, drop_first=True)
print(f"   ✓ Variables categóricas codificadas: {df_encoded.shape[1]} features finales")

# 3. ESCALADO
print("\n[3/6] Escalando features...")
scaler = StandardScaler()
X_scaled = scaler.fit_transform(df_encoded)
print(f"   ✓ Features escaladas: shape {X_scaled.shape}")

# 4. REDUCCIÓN DE DIMENSIONALIDAD CON UMAP
print("\n[4/6] Aplicando UMAP para reducción de dimensionalidad...")
reducer = umap.UMAP(
    n_components=10,  # Reducir a 10 dimensiones antes de clustering
    n_neighbors=30,
    min_dist=0.1,
    metric='euclidean',
    random_state=RANDOM_STATE,
    verbose=True
)
X_reduced = reducer.fit_transform(X_scaled)
print(f"   ✓ UMAP aplicado: {X_scaled.shape[1]} → {X_reduced.shape[1]} dimensiones")

# 5. CLUSTERING CON HDBSCAN
print("\n[5/6] Entrenando modelo HDBSCAN...")
clusterer = hdbscan.HDBSCAN(
    min_cluster_size=60,
    min_samples=5,
    metric='euclidean',
    cluster_selection_method='eom',
    prediction_data=True  # Importante para poder predecir nuevos datos
)
cluster_labels = clusterer.fit_predict(X_reduced)

# Análisis de clusters
n_clusters = len(set(cluster_labels)) - (1 if -1 in cluster_labels else 0)
n_noise = list(cluster_labels).count(-1)
print(f"   ✓ Clustering completado:")
print(f"     - Clusters encontrados: {n_clusters}")
print(f"     - Puntos de ruido: {n_noise} ({n_noise/len(cluster_labels)*100:.1f}%)")

# Distribución de clusters
for cluster_id in sorted(set(cluster_labels)):
    count = list(cluster_labels).count(cluster_id)
    label = f"Cluster {cluster_id + 1}" if cluster_id >= 0 else "Ruido"
    print(f"     - {label}: {count} personas ({count/len(cluster_labels)*100:.1f}%)")

# 6. GUARDAR ARTEFACTOS
print("\n[6/6] Guardando modelos y artefactos...")

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

artifacts = {
    'clusterer': clusterer,
    'umap_reducer': reducer,
    'scaler': scaler,
    'numeric_imputer': num_imputer,
    'categorical_imputer': cat_imputer,
    'feature_names': df_encoded.columns.tolist(),
    'numeric_cols': numeric_cols,
    'categorical_cols': categorical_cols,
    'n_clusters': n_clusters,
    'training_date': timestamp,
    'model_version': '1.0'
}

model_path = os.path.join(MODEL_DIR, 'shelter_model.pkl')
joblib.dump(artifacts, model_path)
print(f"   ✓ Modelo guardado en: {model_path}")

# Guardar también metadata en formato legible
metadata = {
    'n_clusters': n_clusters,
    'n_features': len(df_encoded.columns),
    'n_samples': len(df),
    'n_noise_points': n_noise,
    'training_date': timestamp,
    'model_version': '1.0',
    'random_state': RANDOM_STATE
}

metadata_path = os.path.join(MODEL_DIR, 'model_metadata.txt')
with open(metadata_path, 'w', encoding='utf-8') as f:
    f.write("SHELTER AI - MODELO DE CLUSTERING\n")
    f.write("=" * 50 + "\n\n")
    for key, value in metadata.items():
        f.write(f"{key}: {value}\n")
    f.write("\n\nDistribución de clusters:\n")
    f.write("-" * 50 + "\n")
    for cluster_id in sorted(set(cluster_labels)):
        count = list(cluster_labels).count(cluster_id)
        label = f"Cluster {cluster_id + 1}" if cluster_id >= 0 else "Ruido"
        f.write(f"{label}: {count} personas ({count/len(cluster_labels)*100:.1f}%)\n")

print(f"   ✓ Metadata guardada en: {metadata_path}")

print("\n" + "=" * 60)
print("✅ ENTRENAMIENTO COMPLETADO EXITOSAMENTE")
print("=" * 60)
print(f"\nArchivos generados:")
print(f"  - {model_path}")
print(f"  - {metadata_path}")
print(f"\nEl modelo está listo para ser usado en la API de inferencia.")
