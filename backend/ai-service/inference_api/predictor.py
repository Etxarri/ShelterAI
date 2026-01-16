"""
Predictor - Sistema de recomendación de refugios basado en clustering
"""

import joblib
import numpy as np
import pandas as pd
import hdbscan
from typing import List, Tuple, Dict, Optional
from sklearn.neighbors import NearestNeighbors
from scipy import stats
from .schemas import RefugeeInput, ShelterRecommendation
from .database import Shelter
from .config import settings
import os


class ShelterPredictor:
    """Clase para predecir y recomendar refugios para refugiados"""
    
    def __init__(self, model_path: str = None):
        """
        Inicializa el predictor cargando el modelo entrenado
        """
        if model_path is None:
            model_path = settings.MODEL_PATH
        
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"Modelo no encontrado en: {model_path}")
        
        print(f"📦 Cargando modelo desde: {model_path}")
        self.artifacts = joblib.load(model_path)
        
        # Extraer componentes
        self.clusterer = self.artifacts['clusterer']
        self.umap_reducer = self.artifacts['umap_reducer']
        self.scaler = self.artifacts['scaler']
        self.numeric_imputer = self.artifacts['numeric_imputer']
        self.categorical_imputer = self.artifacts['categorical_imputer']
        self.feature_names = self.artifacts['feature_names']
        self.numeric_cols = self.artifacts['numeric_cols']
        self.categorical_cols = self.artifacts['categorical_cols']
        self.n_clusters = self.artifacts['n_clusters']
        self.model_version = self.artifacts.get('model_version', '1.0')
        
        # Intentar cargar datos de entrenamiento reducidos si están disponibles
        self.X_train_reduced = self.artifacts.get('X_train_reduced', None)
        self.y_train_clusters = self.artifacts.get('y_train_clusters', None)
        
        # Si no tenemos datos de entrenamiento, usaremos el exemplars del clusterer
        if self.X_train_reduced is None and hasattr(self.clusterer, 'exemplars_'):
            print(f"⚠️  Usando exemplars del clusterer para KNN")
            self.X_train_reduced = self.clusterer.exemplars_
            self.y_train_clusters = self.clusterer.labels_[self.clusterer.exemplars_indices_]
        
        print(f"✅ Modelo cargado exitosamente (versión {self.model_version})")
        print(f"   - {self.n_clusters} clusters")
        print(f"   - {len(self.feature_names)} features")
    
    
    def preprocess_refugee_data(self, refugee: RefugeeInput) -> np.ndarray:
        """
        Preprocesa los datos del refugiado para que coincidan con el formato del modelo
        
        Como el modelo fue entrenado con el dataset completo (555 features),
        creamos un vector con todas las features esperadas, usando valores neutros
        por defecto donde no tengamos información del refugiado actual.
        """
        # Inicializar diccionario con TODAS las features en 0.5 (valor neutro en lugar de 0)
        # Esto ayuda a que el punto no sea tan diferente de los datos de entrenamiento
        features = {col: 0.5 for col in self.feature_names}
        
        # Ahora rellenar con los valores que SÍ tenemos del refugiado
        # Esto es un mapeo básico - idealmente necesitarías mapear cada campo
        # del formulario a las columnas exactas del modelo entrenado
        
        # Por ahora, como estrategia de inferencia, usamos la media de features
        # y solo ajustamos algunas claves basadas en lo que recibimos
        
        # Edad
        if 'head_age_group' in features:
            features['head_age_group'] = refugee.age
        
        # Género (buscar columnas relacionadas)
        # Importante: buscar 'female' antes que 'male' porque 'female' contiene 'male'
        for col in self.feature_names:
            if 'gender' in col.lower() and 'female' in col.lower():
                features[col] = 1 if refugee.gender.upper() == 'F' else 0
            elif 'gender' in col.lower() and 'male' in col.lower():
                features[col] = 1 if refugee.gender.upper() == 'M' else 0
        
        # Tamaño de familia
        if 'what_is_sizeyour_famil' in features:
            features['what_is_sizeyour_famil'] = refugee.family_size or 1
        
        # Niños
        if refugee.has_children:
            for col in self.feature_names:
                if 'have_children' in col.lower() and not col.endswith('_001'):
                    features[col] = 1
        
        # Condiciones médicas
        if refugee.medical_conditions or refugee.requires_medical_facilities:
            for col in self.feature_names:
                if 'medical' in col.lower() or 'health' in col.lower():
                    if 'hh_info' in col.lower() or 'person_health' in col.lower():
                        features[col] = 1
        
        # Discapacidad
        if refugee.has_disability:
            for col in self.feature_names:
                if 'disability' in col.lower() or 'difficul' in col.lower():
                    features[col] = 1
        
        # Estrés psicológico
        if refugee.psychological_distress:
            for col in self.feature_names:
                if 'psychological_distress' in col.lower():
                    features[col] = 1
        
        # Estado (refugee/idp)
        for col in self.feature_names:
            if 'status' in col.lower():
                if 'refugee' in col.lower() and refugee.status == 'refugee':
                    features[col] = 1
                elif 'idp' in col.lower() and refugee.status == 'idp':
                    features[col] = 1
        
        # Crear DataFrame con una fila
        df = pd.DataFrame([features])
        
        # Asegurar orden correcto
        df = df[self.feature_names]
        
        return df.values
    
    
    def predict_cluster(self, refugee: RefugeeInput) -> Tuple[int, str, str]:
        """
        Predice el cluster del refugiado
        
        Returns:
            tuple: (cluster_id, cluster_label, vulnerability_level)
        """
        print(f"🔍 [PREDICTOR] Iniciando predicción...")
        
        # Preprocesar datos
        print(f"🔍 [PREDICTOR] Preprocesando datos del refugiado...")
        X = self.preprocess_refugee_data(refugee)
        print(f"   ✓ Vector preprocesado: shape {X.shape}")
        
        # Escalar
        print(f"🔍 [PREDICTOR] Escalando features...")
        X_scaled = self.scaler.transform(X)
        print(f"   ✓ Features escaladas: shape {X_scaled.shape}")
        
        # Reducir dimensionalidad
        print(f"🔍 [PREDICTOR] Aplicando UMAP (esto puede tardar)...")
        X_reduced = self.umap_reducer.transform(X_scaled)
        print(f"   ✓ UMAP aplicado: {X_scaled.shape[1]} → {X_reduced.shape[1]} dimensiones")
        
        # Predecir cluster usando KNN (más confiable que approximate_predict)
        print(f"🔍 [PREDICTOR] Prediciendo cluster con KNN...")
        cluster_id = self._predict_cluster_knn(X_reduced)
        print(f"   ✓ Cluster predicho: {cluster_id}")
        
        # Asignar etiqueta y nivel de vulnerabilidad
        cluster_label, vulnerability_level = self._get_cluster_info(cluster_id, refugee)
        
        return int(cluster_id), cluster_label, vulnerability_level
    
    
    def _predict_cluster_knn(self, X_reduced: np.ndarray, k: int = 15) -> int:
        """
        Predice el cluster usando K-Nearest Neighbors en el espacio reducido
        
        Args:
            X_reduced: Punto reducido por UMAP (1, n_components)
            k: Número de vecinos a considerar
            
        Returns:
            cluster_id: ID del cluster más votado por los vecinos
        """
        # Si no tenemos datos de entrenamiento, fallback a approximate_predict
        if self.X_train_reduced is None or self.y_train_clusters is None:
            print("   ⚠️  No hay datos de entrenamiento, usando approximate_predict...")
            cluster_labels, _ = hdbscan.approximate_predict(self.clusterer, X_reduced)
            return int(cluster_labels[0])
        
        # Usar KNN para encontrar vecinos más cercanos
        knn = NearestNeighbors(n_neighbors=min(k, len(self.X_train_reduced)))
        knn.fit(self.X_train_reduced)
        
        # Encontrar los k vecinos más cercanos
        distances, indices = knn.kneighbors(X_reduced)
        
        # Obtener los clusters de los vecinos
        neighbor_clusters = self.y_train_clusters[indices[0]]
        
        # Filtrar ruido (-1) si hay suficientes clusters válidos
        valid_clusters = neighbor_clusters[neighbor_clusters != -1]
        
        if len(valid_clusters) > 0:
            # Votar por el cluster más común (excluyendo ruido)
            cluster_id = stats.mode(valid_clusters, keepdims=False)[0]
        else:
            # Si todos son ruido, usar -1
            cluster_id = -1
        
        return int(cluster_id)
    
    
    def _get_cluster_info(self, cluster_id: int, refugee: RefugeeInput) -> Tuple[str, str]:
        """
        Obtiene información descriptiva del cluster
        
        Esta función asigna etiquetas basadas en el cluster_id y características del refugiado
        """
        # Mapeo de clusters (esto debería ajustarse según análisis post-entrenamiento)
        cluster_labels = {
            -1: "Sin clasificar (ruido)",
            0: "Individuos jóvenes sin familia",
            1: "Familias numerosas con niños",
            2: "Personas con necesidades médicas",
            3: "Adultos mayores",
            4: "Familias pequeñas estables",
        }
        
        # Obtener label
        label = cluster_labels.get(cluster_id, f"Cluster {cluster_id + 1}")
        
        # Calcular nivel de vulnerabilidad
        vulnerability_score = refugee.vulnerability_score or 5.0
        
        if refugee.has_disability or refugee.requires_medical_facilities:
            vulnerability_score += 2
        if refugee.has_children and refugee.family_size and refugee.family_size > 4:
            vulnerability_score += 1
        if refugee.age < 18 or refugee.age > 65:
            vulnerability_score += 1.5
        
        # Normalizar
        vulnerability_score = min(vulnerability_score, 10.0)
        
        # Clasificar nivel
        if vulnerability_score >= 8:
            level = "critical"
        elif vulnerability_score >= 6:
            level = "high"
        elif vulnerability_score >= 4:
            level = "medium"
        else:
            level = "low"
        
        return label, level
    
    
    def calculate_shelter_compatibility(
        self, 
        refugee: RefugeeInput, 
        shelter: Shelter,
        cluster_id: int,
        vulnerability_level: str
    ) -> Tuple[float, List[str]]:
        """
        Calcula el score de compatibilidad entre un refugiado y un refugio
        
        Returns:
            tuple: (compatibility_score, matching_reasons)
        """
        score = 0.0
        reasons = []
        
        # 1. DISPONIBILIDAD (0-25 puntos)
        available_space = shelter.max_capacity - shelter.current_occupancy
        occupancy_rate = shelter.current_occupancy / shelter.max_capacity if shelter.max_capacity > 0 else 1.0
        
        if available_space >= (refugee.family_size or 1):
            availability_score = 25 * (1 - occupancy_rate)
            score += availability_score
            if occupancy_rate < 0.5:
                reasons.append(f"✓ High availability ({available_space} spaces available)")
            elif occupancy_rate < 0.8:
                reasons.append(f"✓ Moderate availability ({available_space} spaces)")
            else:
                reasons.append(f"⚠ Limited availability ({available_space} spaces)")
        else:
            reasons.append("✗ Insufficient capacity for entire family")
            return 0.0, reasons  # No compatible si no hay espacio
        
        # 2. MEDICAL NEEDS (0-30 points)
        if refugee.requires_medical_facilities or (refugee.medical_conditions and refugee.medical_conditions.lower() != "none"):
            if shelter.has_medical_facilities:
                score += 30
                reasons.append("✓ Medical facilities available (required)")
            else:
                score -= 20
                reasons.append("✗ Lacks required medical facilities")
        elif shelter.has_medical_facilities:
            score += 10
            reasons.append("✓ Has medical facilities")
        
        # 3. CHILDREN AND CHILDCARE (0-25 points)
        if refugee.has_children and refugee.children_count and refugee.children_count > 0:
            if shelter.has_childcare:
                score += 25
                reasons.append(f"✓ Childcare services for {refugee.children_count} child(ren)")
            else:
                score -= 10
                reasons.append(f"⚠ No childcare (family with {refugee.children_count} children)")
        
        # 4. DISABILITY ACCESSIBILITY (0-20 points)
        if refugee.has_disability:
            if shelter.has_disability_access:
                score += 20
                reasons.append("✓ Disability accessible (required)")
            else:
                score -= 30
                reasons.append("✗ Not disability accessible (critical)")
        elif shelter.has_disability_access:
            score += 5
            reasons.append("✓ Disability accessible")
        
        # 5. LANGUAGES (0-15 points)
        if refugee.languages_spoken and shelter.languages_spoken:
            refugee_langs = set(lang.strip().lower() for lang in refugee.languages_spoken.split(','))
            shelter_langs = set(lang.strip().lower() for lang in shelter.languages_spoken.split(','))
            common_langs = refugee_langs & shelter_langs
            
            if common_langs:
                lang_score = 15 * (len(common_langs) / len(refugee_langs))
                score += lang_score
                langs_str = ', '.join(common_langs)
                reasons.append(f"✓ Staff speaks {langs_str}")
            else:
                score -= 5
                reasons.append("⚠ Possible language barrier")
        
        # 6. SHELTER TYPE BY VULNERABILITY (0-15 points)
        if shelter.shelter_type:
            if vulnerability_level in ['critical', 'high']:
                if shelter.shelter_type in ['long-term', 'permanent']:
                    score += 15
                    reasons.append(f"✓ Long-term shelter suitable for high vulnerability")
                elif shelter.shelter_type == 'temporary':
                    score += 8
                    reasons.append(f"✓ Temporary shelter available")
            elif vulnerability_level == 'medium':
                if shelter.shelter_type in ['temporary', 'long-term']:
                    score += 12
                    reasons.append(f"✓ Appropriate shelter type")
            else:  # low vulnerability
                score += 10
                reasons.append(f"✓ Refugio {shelter.shelter_type} disponible")
        
        # Normalizar score a 0-100
        score = max(0, min(100, score))
        
        return score, reasons
    
    
    def recommend_shelters(
        self, 
        refugee: RefugeeInput, 
        available_shelters: List[Shelter],
        top_k: int = None
    ) -> List[ShelterRecommendation]:
        """
        Genera recomendaciones de refugios para un refugiado
        
        Args:
            refugee: Datos del refugiado
            available_shelters: Lista de refugios disponibles
            top_k: Número de recomendaciones a retornar
        
        Returns:
            Lista de recomendaciones ordenadas por compatibilidad
        """
        if top_k is None:
            top_k = settings.TOP_K_RECOMMENDATIONS
        
        # Predecir cluster
        cluster_id, cluster_label, vulnerability_level = self.predict_cluster(refugee)
        
        # Calcular compatibilidad con cada refugio
        recommendations = []
        
        for shelter in available_shelters:
            compatibility_score, reasons = self.calculate_shelter_compatibility(
                refugee, shelter, cluster_id, vulnerability_level
            )
            
            # Solo incluir refugios con score > 0
            if compatibility_score > 0:
                available_space = shelter.max_capacity - shelter.current_occupancy
                occupancy_rate = (shelter.current_occupancy / shelter.max_capacity * 100) if shelter.max_capacity > 0 else 100
                
                # Generar explicación completa
                explanation = self._generate_explanation(
                    refugee, shelter, compatibility_score, vulnerability_level, reasons
                )
                
                recommendation = ShelterRecommendation(
                    shelter_id=shelter.id,
                    shelter_name=shelter.name,
                    address=shelter.address,
                    compatibility_score=round(compatibility_score, 2),
                    priority_score=refugee.vulnerability_score or 5.0,
                    max_capacity=shelter.max_capacity,
                    current_occupancy=shelter.current_occupancy,
                    available_space=available_space,
                    occupancy_rate=round(occupancy_rate, 1),
                    has_medical_facilities=shelter.has_medical_facilities or False,
                    has_childcare=shelter.has_childcare or False,
                    has_disability_access=shelter.has_disability_access or False,
                    languages_spoken=shelter.languages_spoken,
                    shelter_type=shelter.shelter_type,
                    services_offered=shelter.services_offered,
                    explanation=explanation,
                    matching_reasons=reasons
                )
                
                recommendations.append(recommendation)
        
        # Ordenar por compatibilidad descendente
        recommendations.sort(key=lambda x: x.compatibility_score, reverse=True)
        
        # Retornar top K
        return recommendations[:top_k]
    
    
    def _generate_explanation(
        self,
        refugee: RefugeeInput,
        shelter: Shelter,
        score: float,
        vulnerability_level: str,
        reasons: List[str]
    ) -> str:
        """
        Generate a natural language explanation of the recommendation
        """
        explanation = f"This shelter has a {score:.0f}% compatibility match with the refugee profile. "
        
        # Highlight most important points
        key_points = []
        
        if refugee.requires_medical_facilities and shelter.has_medical_facilities:
            key_points.append("has required medical facilities")
        
        if refugee.has_children and shelter.has_childcare:
            key_points.append(f"offers childcare for {refugee.children_count} children")
        
        if refugee.has_disability and shelter.has_disability_access:
            key_points.append("is disability accessible")
        
        if key_points:
            explanation += "Especially recommended because it " + ", ".join(key_points) + ". "
        
        # Add capacity information
        available = shelter.max_capacity - shelter.current_occupancy
        explanation += f"Currently has {available} spaces available."
        
        return explanation


# Instancia global del predictor (se inicializa en main.py)
predictor: Optional[ShelterPredictor] = None


def get_predictor() -> ShelterPredictor:
    """Dependency para obtener el predictor"""
    if predictor is None:
        raise RuntimeError("Predictor no inicializado")
    return predictor
