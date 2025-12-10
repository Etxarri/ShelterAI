# clustering_pipeline_umap_hdbscan.py
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA

import hdbscan

# Intentar usar UMAP (opcional, recomendado para datos one-hot)
try:
    import umap.umap_ as umap
    HAVE_UMAP = True
except Exception:
    HAVE_UMAP = False
    print("umap no encontrado -> se usará PCA 2D como fallback. Para mejores visualizaciones instala: pip install umap-learn")

RANDOM_STATE = 42

# ---------------------------
# 1) Cargar y seleccionar columnas
# ---------------------------
dataset = pd.read_csv('../data/preprocessed_data.csv')

columns_for_clustering = [
    'marital_status', 'have_children', 'status', 'province',
    'site_001', 'site_type', 'assessment_modality', 'respondent_gender', 'are_you_headhh',
    'male_0_6','male_7_14','male_15_17','male_18_59','male_60',
    'female_0_6','female_7_14','female_15_17','female_18_59','female_60',
    'hh_info_person_health','hh_info_legal_needs','hh_info_school_dropout','hh_info_unable_work',
    'hh_info_child_armed_group','hh_info_family_unity','hh_info_drug_dependence'
]
df = dataset[columns_for_clustering].copy()

# ---------------------------
# 2) Imputación y one-hot
# ---------------------------
# Imputar con la moda (apto para categóricas y binarios)
imputer = SimpleImputer(strategy='most_frequent')
df_imputed = pd.DataFrame(imputer.fit_transform(df), columns=df.columns, index=df.index)

# One-hot encode (drop_first=False para no perder categorías)
X_df = pd.get_dummies(df_imputed, drop_first=False)
# Guardamos una versión binaria (útil para UMAP con metric='hamming')
X_binary = X_df.values.astype(int)

# ---------------------------
# 3) Reducción intermedia con PCA para clustering (evita la dispersión en 1 eje)
# ---------------------------
n_samples, n_features = X_binary.shape
# elegir número de componentes intermedios: hasta 20 o menos si hay menos features/samples
pca_mid = min(20, n_features, max(2, n_samples - 1))
if pca_mid < 2:
    raise ValueError(f"No hay suficientes muestras/características para reducción (n_samples={n_samples}, n_features={n_features}).")

pca = PCA(n_components=pca_mid, random_state=RANDOM_STATE)
X_pca_mid = pca.fit_transform(X_binary)  # reducir dimensionalidad para clustering

# Estandarizar las componentes PCA (HDBSCAN suele ir bien con features centradas/escaladas)
scaler = StandardScaler()
X_for_clustering = scaler.fit_transform(X_pca_mid)

# ---------------------------
# 4) Clustering con HDBSCAN
# ---------------------------
clusterer = hdbscan.HDBSCAN(
    min_cluster_size=15,   # ajusta esto según esperes clusters pequeños/grandes
    min_samples=5,         # si lo pones None, HDBSCAN lo estimará internamente
    metric='euclidean',
    cluster_selection_method='eom'
)
cluster_labels = clusterer.fit_predict(X_for_clustering)
print("HDBSCAN finished. Number of clusters (excluding -1 noise):",
      len(set(cluster_labels) - {-1}))
print("Cluster counts (incluye -1 = noise):")
print(pd.Series(cluster_labels).value_counts().sort_index())

# ---------------------------
# 5) Embedding 2D para visualización (UMAP recomendado)
# ---------------------------
if HAVE_UMAP:
    # Usar la versión binaria con metric='hamming' para que UMAP separe bien datos one-hot
    umap_reducer = umap.UMAP(n_components=2, random_state=RANDOM_STATE,
                             n_neighbors=15, min_dist=0.1, metric='hamming')
    X_emb = umap_reducer.fit_transform(X_binary)
    emb_x, emb_y = X_emb[:, 0], X_emb[:, 1]
    emb_method = "UMAP (metric=hamming)"
else:
    # Fallback: hacer PCA 2D sobre las componentes intermedias ya calculadas
    pca2 = PCA(n_components=2, random_state=RANDOM_STATE)
    X_emb2 = pca2.fit_transform(X_pca_mid)
    emb_x, emb_y = X_emb2[:, 0], X_emb2[:, 1]
    emb_method = "PCA 2D (fallback)"

# Construir dataframe de visualización
vis_df = pd.DataFrame({
    'emb_x': emb_x,
    'emb_y': emb_y,
    'cluster': cluster_labels
}, index=X_df.index)

# ---------------------------
# 6) Quitar noise para las gráficas
# ---------------------------
vis_df_no_noise = vis_df[vis_df['cluster'] != -1].copy()
if vis_df_no_noise.shape[0] == 0:
    raise ValueError("No quedan puntos tras filtrar noise (-1). Reduce min_cluster_size o revisa los datos.")

# ---------------------------
# 7) Plots: izquierda = sin etiquetas (solo puntos), derecha = con clusters coloreados (sin noise)
# ---------------------------
plt.figure(figsize=(14,6))

# IZQUIERDA: embedding sin etiquetas (sin noise)
ax1 = plt.subplot(1,2,1)
ax1.scatter(vis_df_no_noise['emb_x'], vis_df_no_noise['emb_y'], s=18, alpha=0.7, edgecolor='none')
ax1.set_xlabel('Dim 1')
ax1.set_ylabel('Dim 2')
ax1.set_title(f'Embedding 2D (sin noise) — {emb_method}')

# DERECHA: embedding con clusters coloreados
ax2 = plt.subplot(1,2,2)

clusters = sorted(vis_df_no_noise['cluster'].unique())
n_clusters = len(clusters)
cmap = plt.cm.get_cmap('viridis')

# Mapear cluster -> índice 0..(n_clusters-1)
cluster_to_idx = {c: i for i, c in enumerate(clusters)}

for cluster in clusters:
    idx = cluster_to_idx[cluster]
    mask = vis_df_no_noise['cluster'] == cluster
    # interpolar color en [0,1]
    norm_val = idx / max(1, n_clusters - 1)
    color = cmap(norm_val)
    ax2.scatter(vis_df_no_noise.loc[mask, 'emb_x'],
                vis_df_no_noise.loc[mask, 'emb_y'],
                s=25, alpha=0.8, label=f'Cluster {cluster}', c=[color], edgecolor='none')

ax2.set_xlabel('Dim 1')
ax2.set_ylabel('Dim 2')
ax2.set_title(f'Clusters HDBSCAN (sin noise) — {n_clusters} clusters')

# Mostrar leyenda solo si no hay demasiados clusters (para no llenar la figura).
if n_clusters <= 30:
    ax2.legend(bbox_to_anchor=(1.05, 1), loc='upper left', fontsize='small')
else:
    # Alternativa: mostrar pequeña tabla de cuentas
    counts = pd.Series(cluster_labels).value_counts()
    top_counts = counts[counts.index != -1].sort_values(ascending=False).head(10)
    print("Top 10 clusters por tamaño:")
    print(top_counts)

plt.tight_layout()
plt.show()

# ---------------------------
# 8) Guardar resultados (opcional)
# ---------------------------
# out = vis_df.copy()
# out['original_index'] = out.index
# out.to_csv('embeddings_and_clusters.csv', index=False)
print("Guardado: embeddings_and_clusters.csv  (incluye noise con label -1)")

# ---------------------------
# Recomendaciones rápidas:
# - Si UMAP produce "manchas" muy dispersas, intenta ajustar n_neighbors (5-50) y min_dist (0.0-0.5).
# - Si tienes demasiados puntos etiquetados como noise, baja min_cluster_size (ej. 10 o 5).
# - Si ves aún la "línea vertical", prueba usar UMAP (si aún no lo tenías) o aumentar `pca_mid` antes del clustering.
# ---------------------------
