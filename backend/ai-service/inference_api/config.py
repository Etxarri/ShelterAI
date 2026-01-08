# Configuración de variables de entorno
import os
from typing import Optional

class Settings:
    # Base de datos
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql://root:root@localhost:5432/shelterai"
    )
    
    # Modelo
    MODEL_PATH: str = os.getenv(
        "MODEL_PATH",
        "../models/shelter_model.pkl"
    )
    
    # API
    API_HOST: str = os.getenv("API_HOST", "0.0.0.0")
    API_PORT: int = int(os.getenv("API_PORT", "8000"))
    
    # CORS
    CORS_ORIGINS: list = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://localhost:1880",  # Node-RED
    ]
    
    # Recomendaciones
    TOP_K_RECOMMENDATIONS: int = 3
    MIN_CAPACITY_THRESHOLD: float = 0.1  # 10% capacidad mínima disponible

settings = Settings()
