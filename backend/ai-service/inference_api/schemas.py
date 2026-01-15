from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

# ===== INPUT SCHEMAS =====

class ShelterSelectionRequest(BaseModel):
    """Request para seleccionar un refugio de las recomendaciones"""
    refugee_id: int = Field(..., ge=1, description="ID del refugiado")
    shelter_id: int = Field(..., ge=1, description="ID del refugio seleccionado")


class RefugeeInput(BaseModel):
    """Datos del refugiado para recomendación de refugio"""
    
    # Información básica
    first_name: str = Field(..., description="Nombre")
    last_name: str = Field(..., description="Apellido")
    age: int = Field(..., ge=0, le=120, description="Edad")
    gender: str = Field(..., description="Género: M/F/Other")
    nationality: str = Field(..., description="Nacionalidad")
    
    # Familia
    family_size: Optional[int] = Field(None, ge=1, description="Tamaño de la familia")
    has_children: Optional[bool] = Field(None, description="¿Tiene niños?")
    children_count: Optional[int] = Field(0, ge=0, description="Número de niños")
    
    # Salud y necesidades especiales
    medical_conditions: Optional[str] = Field(None, description="Condiciones médicas")
    has_disability: Optional[bool] = Field(False, description="¿Tiene discapacidad?")
    psychological_distress: Optional[bool] = Field(False, description="¿Tiene angustia psicológica?")
    requires_medical_facilities: Optional[bool] = Field(False, description="¿Requiere instalaciones médicas?")
    
    # Idiomas
    languages_spoken: Optional[str] = Field(None, description="Idiomas que habla (separados por comas)")
    
    # Situación
    status: Optional[str] = Field("refugee", description="Estado: refugee/idp/returnee")
    special_needs: Optional[str] = Field(None, description="Necesidades especiales adicionales")
    
    # Prioridad calculada (puede venir del sistema o calcularse)
    vulnerability_score: Optional[float] = Field(None, ge=0, le=10, description="Puntuación de vulnerabilidad (0-10)")
    
    class Config:
        json_schema_extra = {
            "example": {
                "first_name": "Ahmed",
                "last_name": "Al-Hassan",
                "age": 42,
                "gender": "M",
                "nationality": "Syrian",
                "family_size": 5,
                "has_children": True,
                "children_count": 3,
                "medical_conditions": "Diabetes",
                "has_disability": False,
                "psychological_distress": True,
                "requires_medical_facilities": True,
                "languages_spoken": "Arabic,English",
                "status": "refugee",
                "special_needs": "Needs regular medication",
                "vulnerability_score": 7.5
            }
        }


# ===== OUTPUT SCHEMAS =====

class ShelterRecommendation(BaseModel):
    """Recomendación de un refugio específico"""
    
    shelter_id: int = Field(..., description="ID del refugio")
    shelter_name: str = Field(..., description="Nombre del refugio")
    address: Optional[str] = Field(None, description="Dirección")
    
    # Puntuaciones
    compatibility_score: float = Field(..., ge=0, le=100, description="Puntuación de compatibilidad (0-100)")
    priority_score: float = Field(..., description="Puntuación de prioridad")
    
    # Información del refugio
    max_capacity: int = Field(..., description="Capacidad máxima")
    current_occupancy: int = Field(..., description="Ocupación actual")
    available_space: int = Field(..., description="Espacios disponibles")
    occupancy_rate: float = Field(..., description="Tasa de ocupación (%)")
    
    # Servicios
    has_medical_facilities: bool
    has_childcare: bool
    has_disability_access: bool
    languages_spoken: Optional[str]
    shelter_type: Optional[str]
    services_offered: Optional[str]
    
    # Explicación
    explanation: str = Field(..., description="Explicación de por qué se recomienda este refugio")
    matching_reasons: List[str] = Field(..., description="Razones específicas de compatibilidad")
    
    class Config:
        json_schema_extra = {
            "example": {
                "shelter_id": 1,
                "shelter_name": "Centro Acogida Madrid Norte",
                "address": "Calle Alcalá 123, Madrid",
                "compatibility_score": 92.5,
                "priority_score": 8.5,
                "max_capacity": 150,
                "current_occupancy": 45,
                "available_space": 105,
                "occupancy_rate": 30.0,
                "has_medical_facilities": True,
                "has_childcare": True,
                "has_disability_access": True,
                "languages_spoken": "Spanish,English,Arabic,French",
                "shelter_type": "long-term",
                "services_offered": "Medical,Education,Legal Aid,Childcare",
                "explanation": "Este refugio es altamente compatible debido a que cuenta con instalaciones médicas necesarias para la diabetes, ofrece cuidado infantil para los 3 niños de la familia, y tiene personal que habla árabe e inglés.",
                "matching_reasons": [
                    "✓ Instalaciones médicas disponibles (requerido por condición médica)",
                    "✓ Servicio de cuidado infantil para 3 niños",
                    "✓ Personal que habla árabe e inglés",
                    "✓ Alta disponibilidad (70% espacios libres)",
                    "✓ Refugio de largo plazo apropiado para familias"
                ]
            }
        }


class RecommendationResponse(BaseModel):
    """Respuesta completa con recomendaciones de refugios"""
    
    # Información del refugiado
    refugee_info: dict = Field(..., description="Información básica del refugiado procesado")
    
    # Clasificación
    cluster_id: int = Field(..., description="Cluster asignado por el modelo")
    cluster_label: str = Field(..., description="Etiqueta descriptiva del cluster")
    vulnerability_level: str = Field(..., description="Nivel de vulnerabilidad: low/medium/high/critical")
    
    # Recomendaciones
    recommendations: List[ShelterRecommendation] = Field(..., description="Lista de refugios recomendados")
    total_shelters_analyzed: int = Field(..., description="Total de refugios analizados")
    
    # Metadata
    timestamp: datetime = Field(default_factory=datetime.now, description="Timestamp de la recomendación")
    ml_model_version: str = Field(..., description="Versión del modelo usado")
    
    class Config:
        json_schema_extra = {
            "example": {
                "refugee_info": {
                    "name": "Ahmed Al-Hassan",
                    "age": 42,
                    "nationality": "Syrian",
                    "family_size": 5
                },
                "cluster_id": 2,
                "cluster_label": "Familias con necesidades médicas",
                "vulnerability_level": "high",
                "recommendations": [],  # Se llenaría con ejemplos de ShelterRecommendation
                "total_shelters_analyzed": 5,
                "timestamp": "2026-01-07T10:30:00",
                "model_version": "1.0"
            }
        }


class HealthCheck(BaseModel):
    """Estado de salud de la API"""
    status: str
    ml_model_loaded: bool
    database_connected: bool
    timestamp: datetime
    
    model_config = {"protected_namespaces": ()}
