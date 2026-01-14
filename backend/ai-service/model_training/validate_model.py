"""
Script de validación del modelo de clustering HDBSCAN
Este script valida el modelo entrenado usando métricas de clustering
y verifica que no exista overfitting comparando train vs test
"""

import pandas as pd
import numpy as np
import joblib
from sklearn.metrics import (
    silhouette_score, 
    calinski_harabasz_score, 
    davies_bouldin_score
)
from sklearn.preprocessing import StandardScaler
from sklearn.impute import SimpleImputer
import os
from datetime import datetime

# Configuración
MODEL_PATH = '../models/shelter_model.pkl'
TRAIN_DATA_PATH = '../data/train_data.csv'
TEST_DATA_PATH = '../data/test_data.csv'
VALIDATION_REPORT_PATH = '../models/validation_report.txt'

print("=" * 80)
print("VALIDACIÓN DEL MODELO DE CLUSTERING HDBSCAN")
print("=" * 80)

# ===== 1. CARGAR MODELO =====
print("\n[1/5] Cargando modelo entrenado...")
if not os.path.exists(MODEL_PATH):
    print(f"❌ Error: Modelo no encontrado en {MODEL_PATH}")
    print("   Por favor, ejecuta primero train_final_model.py")
    exit(1)

artifacts = joblib.load(MODEL_PATH)
print(f"   ✓ Modelo cargado exitosamente")
print(f"   - Versión: {artifacts['model_version']}")
print(f"   - Fecha entrenamiento: {artifacts['training_date']}")
print(f"   - Clusters: {artifacts['n_clusters']}")


# ===== 2. FUNCIÓN DE PREPROCESAMIENTO =====
def preprocess_data(df, artifacts):
    """
    Preprocesa datos que ya vienen one-hot encoded desde train_data.csv/test_data.csv
    """
    # Los datos ya están preprocesados, solo asegurar que tengan todas las columnas
    # Asegurar que tenga todas las columnas del entrenamiento
    for col in artifacts['feature_names']:
        if col not in df.columns:
            df[col] = 0
    
    # Mantener solo las columnas del entrenamiento en el mismo orden
    df_aligned = df[artifacts['feature_names']]
    
    return df_aligned


# ===== 3. CARGAR Y PREPROCESAR DATOS =====
print("\n[2/5] Cargando y preprocesando datos de train y test...")

# Train data
df_train = pd.read_csv(TRAIN_DATA_PATH)
X_train_processed = preprocess_data(df_train, artifacts)
X_train_scaled = artifacts['scaler'].transform(X_train_processed)
X_train_reduced = artifacts['umap_reducer'].transform(X_train_scaled)

print(f"   ✓ Train data: {X_train_processed.shape[0]} muestras")
print(f"     - Features: {X_train_processed.shape[1]}")
print(f"     - Reducido a: {X_train_reduced.shape[1]} dimensiones")

# Test data
df_test = pd.read_csv(TEST_DATA_PATH)
X_test_processed = preprocess_data(df_test, artifacts)
X_test_scaled = artifacts['scaler'].transform(X_test_processed)
X_test_reduced = artifacts['umap_reducer'].transform(X_test_scaled)

print(f"   ✓ Test data: {X_test_processed.shape[0]} muestras")
print(f"     - Features: {X_test_processed.shape[1]}")
print(f"     - Reducido a: {X_test_reduced.shape[1]} dimensiones")


# ===== 4. PREDECIR CLUSTERS EN TRAIN Y TEST =====
print("\n[3/5] Prediciendo clusters para train y test...")

# Usar approximate_predict de HDBSCAN para ambos conjuntos
import hdbscan

# Train labels
train_labels, train_probs = hdbscan.approximate_predict(artifacts['clusterer'], X_train_reduced)
n_clusters_train = len(set(train_labels)) - (1 if -1 in train_labels else 0)
n_noise_train = list(train_labels).count(-1)

print(f"   ✓ TRAIN:")
print(f"     - Clusters: {n_clusters_train}")
print(f"     - Puntos de ruido: {n_noise_train} ({n_noise_train/len(train_labels)*100:.1f}%)")

# Test labels
test_labels, test_probs = hdbscan.approximate_predict(artifacts['clusterer'], X_test_reduced)

n_clusters_test = len(set(test_labels)) - (1 if -1 in test_labels else 0)
n_noise_test = list(test_labels).count(-1)

print(f"   ✓ TEST:")
print(f"     - Clusters: {n_clusters_test}")
print(f"     - Puntos de ruido: {n_noise_test} ({n_noise_test/len(test_labels)*100:.1f}%)")


# ===== 5. CALCULAR MÉTRICAS DE CLUSTERING =====
print("\n[4/5] Calculando métricas de clustering...")

results = {
    'train': {},
    'test': {},
    'comparison': {}
}

# === MÉTRICAS PARA TRAIN ===
print("\n   📊 TRAIN SET:")

# Filtrar ruido para métricas (no se pueden calcular con cluster -1)
train_labels_no_noise = train_labels[train_labels != -1]
X_train_reduced_no_noise = X_train_reduced[train_labels != -1]

if len(train_labels_no_noise) > 0:
    # Silhouette Score (rango: [-1, 1], más cercano a 1 es mejor)
    # Mide qué tan similares son los puntos dentro del mismo cluster vs otros clusters
    train_silhouette = silhouette_score(X_train_reduced_no_noise, train_labels_no_noise)
    results['train']['silhouette'] = train_silhouette
    print(f"     - Silhouette Score: {train_silhouette:.4f}")
    print(f"       (Rango: [-1, 1], óptimo: cercano a 1)")

    # Calinski-Harabasz Score (más alto es mejor)
    # Mide la ratio de dispersión entre clusters vs dentro de clusters
    train_ch = calinski_harabasz_score(X_train_reduced_no_noise, train_labels_no_noise)
    results['train']['calinski_harabasz'] = train_ch
    print(f"     - Calinski-Harabasz: {train_ch:.2f}")
    print(f"       (Más alto = mejor separación de clusters)")

    # Davies-Bouldin Score (más bajo es mejor)
    # Mide la ratio promedio de similitud entre cada cluster y su más similar
    train_db = davies_bouldin_score(X_train_reduced_no_noise, train_labels_no_noise)
    results['train']['davies_bouldin'] = train_db
    print(f"     - Davies-Bouldin: {train_db:.4f}")
    print(f"       (Más bajo = clusters mejor definidos)")
else:
    print("     ⚠️  No se pudieron calcular métricas (todos los puntos son ruido)")

# Distribución de clusters
train_cluster_dist = pd.Series(train_labels).value_counts().sort_index()
results['train']['cluster_distribution'] = train_cluster_dist.to_dict()


# === MÉTRICAS PARA TEST ===
print("\n   📊 TEST SET:")

# Filtrar ruido para métricas (no se pueden calcular con cluster -1)
test_labels_no_noise = test_labels[test_labels != -1]
X_test_reduced_no_noise = X_test_reduced[test_labels != -1]

if len(test_labels_no_noise) > 0:
    test_silhouette = silhouette_score(X_test_reduced_no_noise, test_labels_no_noise)
    results['test']['silhouette'] = test_silhouette
    print(f"     - Silhouette Score: {test_silhouette:.4f}")
    
    test_ch = calinski_harabasz_score(X_test_reduced_no_noise, test_labels_no_noise)
    results['test']['calinski_harabasz'] = test_ch
    print(f"     - Calinski-Harabasz: {test_ch:.2f}")
    
    test_db = davies_bouldin_score(X_test_reduced_no_noise, test_labels_no_noise)
    results['test']['davies_bouldin'] = test_db
    print(f"     - Davies-Bouldin: {test_db:.4f}")
else:
    print("     ⚠️  No se pudieron calcular métricas (todos los puntos son ruido)")


# Distribución de clusters en test
test_cluster_dist = pd.Series(test_labels).value_counts().sort_index()
results['test']['cluster_distribution'] = test_cluster_dist.to_dict()


# === COMPARACIÓN TRAIN VS TEST ===
print("\n   🔍 COMPARACIÓN TRAIN vs TEST (Detección de Overfitting):")

if len(test_labels_no_noise) > 0:
    # Diferencias en métricas
    silhouette_diff = abs(train_silhouette - test_silhouette)
    ch_diff_percent = abs(train_ch - test_ch) / train_ch * 100
    db_diff_percent = abs(train_db - test_db) / train_db * 100
    
    results['comparison']['silhouette_diff'] = silhouette_diff
    results['comparison']['ch_diff_percent'] = ch_diff_percent
    results['comparison']['db_diff_percent'] = db_diff_percent
    
    print(f"     - Diferencia Silhouette: {silhouette_diff:.4f}")
    print(f"       (< 0.1 es bueno, indica consistencia)")
    
    print(f"     - Diferencia Calinski-Harabasz: {ch_diff_percent:.2f}%")
    print(f"       (< 20% es bueno)")
    
    print(f"     - Diferencia Davies-Bouldin: {db_diff_percent:.2f}%")
    print(f"       (< 20% es bueno)")
    
    # Evaluación de overfitting
    overfitting = False
    warnings = []
    
    if silhouette_diff > 0.15:
        overfitting = True
        warnings.append(f"⚠️ Silhouette muy diferente (diff={silhouette_diff:.4f})")
    
    if ch_diff_percent > 30:
        overfitting = True
        warnings.append(f"⚠️ Calinski-Harabasz muy diferente ({ch_diff_percent:.1f}%)")
    
    if db_diff_percent > 30:
        overfitting = True
        warnings.append(f"⚠️ Davies-Bouldin muy diferente ({db_diff_percent:.1f}%)")
    
    # Verificar distribución de ruido
    noise_train_percent = (list(train_labels).count(-1) / len(train_labels)) * 100
    noise_test_percent = (list(test_labels).count(-1) / len(test_labels)) * 100
    noise_diff = abs(noise_train_percent - noise_test_percent)
    
    results['comparison']['noise_train_percent'] = noise_train_percent
    results['comparison']['noise_test_percent'] = noise_test_percent
    results['comparison']['noise_diff'] = noise_diff
    
    print(f"\n     - Ruido en train: {noise_train_percent:.1f}%")
    print(f"     - Ruido en test: {noise_test_percent:.1f}%")
    print(f"     - Diferencia: {noise_diff:.1f}%")
    
    if noise_diff > 15:
        warnings.append(f"⚠️ Diferencia de ruido significativa ({noise_diff:.1f}%)")
    
    results['comparison']['overfitting'] = overfitting
    results['comparison']['warnings'] = warnings


# ===== 6. EVALUACIÓN FINAL =====
print("\n[5/5] Evaluación final del modelo...")

print("\n" + "=" * 80)
print("RESUMEN DE VALIDACIÓN")
print("=" * 80)

# Interpretación de métricas
print("\n📈 CALIDAD DEL CLUSTERING:")

# Silhouette interpretation
if train_silhouette > 0.5:
    silhouette_quality = "EXCELENTE"
elif train_silhouette > 0.3:
    silhouette_quality = "BUENA"
elif train_silhouette > 0.2:
    silhouette_quality = "ACEPTABLE"
else:
    silhouette_quality = "MEJORABLE"

print(f"   - Silhouette Score: {silhouette_quality}")
print(f"     Train: {train_silhouette:.4f} | Test: {test_silhouette:.4f}")

# Davies-Bouldin interpretation (lower is better)
if train_db < 1.0:
    db_quality = "EXCELENTE"
elif train_db < 1.5:
    db_quality = "BUENA"
elif train_db < 2.0:
    db_quality = "ACEPTABLE"
else:
    db_quality = "MEJORABLE"

print(f"   - Davies-Bouldin: {db_quality}")
print(f"     Train: {train_db:.4f} | Test: {test_db:.4f}")

# Overfitting evaluation
print(f"\n🎯 DETECCIÓN DE OVERFITTING:")
if not overfitting:
    print("   ✅ NO SE DETECTÓ OVERFITTING")
    print("   El modelo generaliza bien a datos no vistos")
else:
    print("   ⚠️ POSIBLE OVERFITTING DETECTADO")
    for warning in warnings:
        print(f"   {warning}")

# Distribución de clusters
print(f"\n📊 DISTRIBUCIÓN DE CLUSTERS:")
print("\n   TRAIN:")
for cluster_id in sorted(train_cluster_dist.index):
    count = train_cluster_dist[cluster_id]
    label = f"Cluster {cluster_id}" if cluster_id >= 0 else "Ruido"
    print(f"     {label:15s}: {count:4d} ({count/len(train_labels)*100:5.1f}%)")

print("\n   TEST:")
for cluster_id in sorted(test_cluster_dist.index):
    count = test_cluster_dist[cluster_id]
    label = f"Cluster {cluster_id}" if cluster_id >= 0 else "Ruido"
    print(f"     {label:15s}: {count:4d} ({count/len(test_labels)*100:5.1f}%)")


# ===== 7. GUARDAR REPORTE =====
print(f"\n💾 Guardando reporte de validación...")

with open(VALIDATION_REPORT_PATH, 'w', encoding='utf-8') as f:
    f.write("SHELTER AI - REPORTE DE VALIDACIÓN DEL MODELO\n")
    f.write("=" * 80 + "\n\n")
    f.write(f"Fecha de validación: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    f.write(f"Modelo: {MODEL_PATH}\n")
    f.write(f"Versión del modelo: {artifacts['model_version']}\n")
    f.write(f"Fecha de entrenamiento: {artifacts['training_date']}\n\n")
    
    f.write("MÉTRICAS DE CLUSTERING\n")
    f.write("-" * 80 + "\n\n")
    
    f.write("TRAIN SET:\n")
    f.write(f"  Silhouette Score:     {train_silhouette:.4f} [{silhouette_quality}]\n")
    f.write(f"  Calinski-Harabasz:    {train_ch:.2f}\n")
    f.write(f"  Davies-Bouldin:       {train_db:.4f} [{db_quality}]\n")
    f.write(f"  Muestras:             {len(train_labels)}\n")
    f.write(f"  Clusters:             {n_clusters_test}\n")
    f.write(f"  Ruido:                {noise_train_percent:.1f}%\n\n")
    
    f.write("TEST SET:\n")
    f.write(f"  Silhouette Score:     {test_silhouette:.4f}\n")
    f.write(f"  Calinski-Harabasz:    {test_ch:.2f}\n")
    f.write(f"  Davies-Bouldin:       {test_db:.4f}\n")
    f.write(f"  Muestras:             {len(test_labels)}\n")
    f.write(f"  Clusters:             {n_clusters_test}\n")
    f.write(f"  Ruido:                {noise_test_percent:.1f}%\n\n")
    
    f.write("COMPARACIÓN TRAIN vs TEST\n")
    f.write("-" * 80 + "\n\n")
    f.write(f"  Diferencia Silhouette:        {silhouette_diff:.4f}\n")
    f.write(f"  Diferencia Calinski-Harabasz: {ch_diff_percent:.2f}%\n")
    f.write(f"  Diferencia Davies-Bouldin:    {db_diff_percent:.2f}%\n")
    f.write(f"  Diferencia Ruido:             {noise_diff:.1f}%\n\n")
    
    f.write("EVALUACIÓN DE OVERFITTING\n")
    f.write("-" * 80 + "\n\n")
    if not overfitting:
        f.write("✅ NO SE DETECTÓ OVERFITTING\n")
        f.write("El modelo generaliza bien a datos no vistos.\n\n")
    else:
        f.write("⚠️ POSIBLE OVERFITTING DETECTADO\n\n")
        f.write("Warnings:\n")
        for warning in warnings:
            f.write(f"  - {warning}\n")
        f.write("\n")
    
    f.write("DISTRIBUCIÓN DE CLUSTERS\n")
    f.write("-" * 80 + "\n\n")
    f.write("TRAIN:\n")
    for cluster_id in sorted(train_cluster_dist.index):
        count = train_cluster_dist[cluster_id]
        label = f"Cluster {cluster_id}" if cluster_id >= 0 else "Ruido"
        f.write(f"  {label:15s}: {count:4d} ({count/len(train_labels)*100:5.1f}%)\n")
    
    f.write("\nTEST:\n")
    for cluster_id in sorted(test_cluster_dist.index):
        count = test_cluster_dist[cluster_id]
        label = f"Cluster {cluster_id}" if cluster_id >= 0 else "Ruido"
        f.write(f"  {label:15s}: {count:4d} ({count/len(test_labels)*100:5.1f}%)\n")
    
    f.write("\n" + "=" * 80 + "\n")
    f.write("INTERPRETACIÓN DE MÉTRICAS\n")
    f.write("=" * 80 + "\n\n")
    f.write("Silhouette Score:\n")
    f.write("  - Rango: [-1, 1]\n")
    f.write("  - > 0.5:  Excelente separación de clusters\n")
    f.write("  - 0.3-0.5: Buena separación\n")
    f.write("  - 0.2-0.3: Aceptable\n")
    f.write("  - < 0.2:  Clusters poco definidos\n\n")
    
    f.write("Calinski-Harabasz Score:\n")
    f.write("  - Más alto = mejor\n")
    f.write("  - Mide ratio de dispersión entre/dentro de clusters\n\n")
    
    f.write("Davies-Bouldin Score:\n")
    f.write("  - Más bajo = mejor\n")
    f.write("  - < 1.0:  Excelente\n")
    f.write("  - 1.0-1.5: Bueno\n")
    f.write("  - 1.5-2.0: Aceptable\n")
    f.write("  - > 2.0:  Mejorable\n\n")

print(f"   ✓ Reporte guardado en: {VALIDATION_REPORT_PATH}")

print("\n" + "=" * 80)
print("✅ VALIDACIÓN COMPLETADA EXITOSAMENTE")
print("=" * 80)
print("\nEl modelo ha sido validado. Revisa el reporte detallado en:")
print(f"  {VALIDATION_REPORT_PATH}")
