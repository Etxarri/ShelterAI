"""
ShelterAI - API de Recomendación de Refugios
FastAPI service para recomendar refugios basado en clustering ML
"""

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime

# Imports locales
from .config import settings
from .schemas import (
    RefugeeInput, 
    RecommendationResponse, 
    ShelterRecommendation,
    HealthCheck,
    ShelterSelectionRequest
)
from .database import get_db, get_available_shelters, check_database_connection, Refugee, Shelter, Assignment
from .predictor import ShelterPredictor, get_predictor
from . import predictor as predictor_module

# ===== INICIALIZACIÓN DE FASTAPI =====

app = FastAPI(
    title="ShelterAI - Refugee Recommendation API",
    description="API para recomendar refugios a refugiados basado en clustering y matching inteligente",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configurar CORS para Node-RED y frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ===== EVENTOS DE INICIO/APAGADO =====

@app.on_event("startup")
async def startup_event():
    """
    Se ejecuta al iniciar la API
    Carga el modelo de ML
    """
    print("\n" + "="*60)
    print("INICIANDO SHELTER AI API")
    print("="*60)
    
    try:
        # Cargar modelo
        predictor_module.predictor = ShelterPredictor(settings.MODEL_PATH)
        print("✅ Modelo de ML cargado exitosamente")
        
        # Verificar conexión a BD
        if check_database_connection():
            print("Conexión a base de datos establecida")
        else:
            print("Advertencia: No se pudo conectar a la base de datos")
        
        print("="*60)
        print(f"API disponible en: http://{settings.API_HOST}:{settings.API_PORT}")
        print(f"Documentación: http://{settings.API_HOST}:{settings.API_PORT}/docs")
        print("="*60 + "\n")
        
    except Exception as e:
        print(f"Error al iniciar la API: {e}")
        raise


@app.on_event("shutdown")
async def shutdown_event():
    """
    Se ejecuta al apagar la API
    """
    print("\nApagando ShelterAI API...")


# ===== ENDPOINTS =====

@app.get("/", tags=["General"])
async def root():
    """
    Endpoint raíz - Información básica de la API
    """
    return {
        "service": "ShelterAI Recommendation API",
        "version": "1.0.0",
        "status": "running",
        "endpoints": {
            "health": "/health",
            "recommend": "/api/recommend",
            "docs": "/docs"
        }
    }


@app.get("/health", response_model=HealthCheck, tags=["General"])
async def health_check(predictor: ShelterPredictor = Depends(get_predictor)):
    """
    Health check - Verifica el estado del servicio
    """
    db_connected = check_database_connection()
    model_loaded = predictor is not None
    
    return HealthCheck(
        status="healthy" if (db_connected and model_loaded) else "degraded",
        ml_model_loaded=model_loaded,
        database_connected=db_connected,
        timestamp=datetime.now()
    )


@app.post("/api/recommend", response_model=RecommendationResponse, tags=["Recommendations"])
async def recommend_shelter(
    refugee: RefugeeInput,
    db: Session = Depends(get_db),
    predictor: ShelterPredictor = Depends(get_predictor)
):
    """
    **Recomienda refugios para un refugiado**
    
    Este endpoint:
    1. Recibe los datos del refugiado
    2. Predice su cluster de vulnerabilidad usando ML
    3. Consulta refugios disponibles en la base de datos
    4. Calcula compatibilidad entre refugiado y cada refugio
    5. Retorna top 3 refugios recomendados con explicaciones
    
    **Proceso:**
    - Clustering HDBSCAN para clasificación de vulnerabilidad
    - Algoritmo de matching multi-criterio
    - Generación automática de explicaciones
    
    **Ejemplo de uso desde Node-RED:**
    ```javascript
    POST /api/recommend
    {
      "first_name": "Ahmed",
      "last_name": "Al-Hassan",
      "age": 42,
      "gender": "M",
      "nationality": "Syrian",
      "family_size": 5,
      "has_children": true,
      "children_count": 3,
      "medical_conditions": "Diabetes",
      "requires_medical_facilities": true,
      "languages_spoken": "Arabic,English",
      "vulnerability_score": 7.5
    }
    ```
    """
    try:
        print(f"\n" + "="*60)
        print(f"NUEVA PETICIÓN DE RECOMENDACIÓN")
        print(f"="*60)
        print(f"Refugiado: {refugee.first_name} {refugee.last_name}")
        print(f"Edad: {refugee.age}, Género: {refugee.gender}")
        print(f"Familia: {refugee.family_size} miembros, Niños: {refugee.children_count}")
        
        # 1. Predecir cluster
        print(f"\nPrediciendo cluster...")
        cluster_id, cluster_label, vulnerability_level = predictor.predict_cluster(refugee)
        
        print(f"\nRESULTADO DE CLASIFICACIÓN")
        print(f"   Cluster: {cluster_id} ({cluster_label})")
        print(f"   Vulnerabilidad: {vulnerability_level}")
        
        # 2. Obtener refugios disponibles
        available_shelters = get_available_shelters(db)
        
        if not available_shelters:
            raise HTTPException(
                status_code=404,
                detail="No hay refugios disponibles en este momento"
            )
        
        print(f"   Refugios analizados: {len(available_shelters)}")
        
        # 3. Generar recomendaciones
        recommendations = predictor.recommend_shelters(
            refugee=refugee,
            available_shelters=available_shelters,
            top_k=settings.TOP_K_RECOMMENDATIONS
        )
        
        if not recommendations:
            raise HTTPException(
                status_code=404,
                detail="No se encontraron refugios compatibles para este refugiado. "
                       "Esto puede deberse a requisitos muy específicos o falta de capacidad."
            )
        
        print(f"   ✅ {len(recommendations)} recomendaciones generadas")
        for i, rec in enumerate(recommendations, 1):
            print(f"      {i}. {rec.shelter_name} (score: {rec.compatibility_score:.1f})")
        
        # 4. Construir respuesta
        response = RecommendationResponse(
            refugee_info={
                "name": f"{refugee.first_name} {refugee.last_name}",
                "age": refugee.age,
                "nationality": refugee.nationality,
                "family_size": refugee.family_size or 1,
                "gender": refugee.gender
            },
            cluster_id=cluster_id,
            cluster_label=cluster_label,
            vulnerability_level=vulnerability_level,
            recommendations=recommendations,
            total_shelters_analyzed=len(available_shelters),
            ml_model_version=predictor.model_version
        )
        
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error procesando recomendación: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error interno al procesar la recomendación: {str(e)}"
        )


def _build_assignment_response(db: Session, refugee_id: int):
    """Construye la respuesta de asignación para un refugiado."""
    try:
        # Buscar asignación activa del refugiado
        assignment = db.query(Assignment).filter(
            Assignment.refugee_id == refugee_id
        ).first()

        if not assignment:
            return {
                "has_assignment": False,
                "refugee_id": refugee_id,
                "assignment": None
            }

        # Obtener información del refugio asignado
        shelter = db.query(Shelter).filter(
            Shelter.id == assignment.shelter_id
        ).first()

        return {
            "has_assignment": True,
            "refugee_id": refugee_id,
            "assignment": {
                "id": assignment.id,
                "shelter_id": assignment.shelter_id,
                "shelter_name": shelter.name if shelter else None,
                "assigned_at": assignment.assigned_at.isoformat() if assignment.assigned_at else None,
                "status": assignment.status if hasattr(assignment, 'status') else "assigned"
            }
        }
    except Exception as e:
        print(f"Error en _build_assignment_response: {e}")
        import traceback
        traceback.print_exc()
        raise


@app.get("/api/refugee/{refugee_id}/assignment", tags=["Assignments"])
async def get_refugee_assignment(
    refugee_id: int,
    db: Session = Depends(get_db),
):
    """
    Verifica si un refugiado ya tiene una asignación de refugio (ruta clásica)
    """
    try:
        return _build_assignment_response(db, refugee_id)
    except Exception as e:
        print(f"Error al verificar asignación: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error al verificar asignación: {str(e)}"
        )


@app.get("/api/ai/refugee/{refugee_id}/assignment", tags=["Assignments"])
async def get_refugee_assignment_ai(
    refugee_id: int,
    db: Session = Depends(get_db),
):
    """
    Ruta usada por el proxy /api/ai/* para evitar 404 desde Node-RED
    """
    try:
        return _build_assignment_response(db, refugee_id)
    except Exception as e:
        print(f"Error al verificar asignación: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error al verificar asignación: {str(e)}"
        )


# Ruta sin el prefijo /api por si el proxy Node-RED reescribe
@app.get("/ai/refugee/{refugee_id}/assignment", tags=["Assignments"])
async def get_refugee_assignment_ai_alt(
    refugee_id: int,
    db: Session = Depends(get_db),
):
    try:
        return _build_assignment_response(db, refugee_id)
    except Exception as e:
        print(f"Error al verificar asignación (alt): {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error al verificar asignación: {str(e)}"
        )


@app.post("/api/select-shelter", tags=["Recommendations"])
async def select_shelter_from_recommendation(
    request: ShelterSelectionRequest,
    db: Session = Depends(get_db),
):
    """
    **Selecciona un refugio de las recomendaciones para asignar a un refugiado**
    
    Este endpoint:
    1. Recibe el ID del refugiado y el ID del refugio seleccionado
    2. Crea una asignación en la base de datos
    3. Retorna los detalles de la asignación
    
    **Request Body:**
    ```json
    {
      "refugee_id": 1,
      "shelter_id": 3
    }
    ```
    
    **Response:** Objeto de asignación con detalles completos
    """
    try:
        refugee_id = request.refugee_id
        shelter_id = request.shelter_id
        
        print(f"\n" + "="*60)
        print(f"SELECCIÓN DE REFUGIO DESDE RECOMENDACIONES")
        print(f"="*60)
        print(f"Refugiado ID: {refugee_id}")
        print(f"Refugio seleccionado: {shelter_id}")
        
        # Obtener refugiado
        refugee = db.query(Refugee).filter(Refugee.id == refugee_id).first()
        if not refugee:
            raise HTTPException(
                status_code=404,
                detail=f"Refugiado con ID {refugee_id} no encontrado"
            )
        
        # Obtener refugio
        shelter = db.query(Shelter).filter(Shelter.id == shelter_id).first()
        if not shelter:
            raise HTTPException(
                status_code=404,
                detail=f"Refugio con ID {shelter_id} no encontrado"
            )
        
        print(f"Refugiado: {refugee.first_name} {refugee.last_name}")
        print(f"Refugio: {shelter.name}")
        
        # Crear asignación
        assignment = Assignment(
            refugee_id=refugee_id,
            shelter_id=shelter_id,
            status="pending",
            assigned_at=datetime.now(),
            notes=f"Asignación seleccionada por el usuario desde recomendaciones"
        )
        db.add(assignment)
        db.commit()
        db.refresh(assignment)
        
        print(f"✅ Asignación creada con ID: {assignment.id}")
        
        # Construir respuesta
        response = {
            "refugee": {
                "id": refugee.id,
                "first_name": refugee.first_name,
                "last_name": refugee.last_name,
                "age": refugee.age,
                "gender": refugee.gender,
                "nationality": refugee.nationality,
            },
            "assignment": {
                "id": assignment.id,
                "shelter_id": shelter.id,
                "shelter_name": shelter.name,
                "address": shelter.address,
                "status": assignment.status,
                "assigned_at": assignment.assigned_at.isoformat(),
                "priority_score": refugee.vulnerability_score or 5.0,
                "confidence_score": 1.0,
                "explanation": f"El usuario seleccionó {shelter.name} de las opciones recomendadas.",
                "matching_reasons": [
                    "✓ Seleccionado por el usuario de las recomendaciones",
                    f"✓ Refugio: {shelter.name}",
                    f"✓ Disponibilidad: {shelter.max_capacity - shelter.current_occupancy}/{shelter.max_capacity} espacios libres"
                ],
                "match_details": {
                    "user_selected": True,
                    "shelter_capacity": shelter.max_capacity,
                    "current_occupancy": shelter.current_occupancy,
                    "available_space": shelter.max_capacity - shelter.current_occupancy
                }
            }
        }
        
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error al seleccionar refugio: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error interno al procesar la selección: {str(e)}"
        )


@app.get("/api/stats", tags=["Statistics"])
async def get_statistics(
    db: Session = Depends(get_db),
    predictor: ShelterPredictor = Depends(get_predictor)
):
    """
    Obtiene estadísticas generales del sistema
    """
    from database import get_all_shelters
    
    shelters = get_all_shelters(db)
    available = get_available_shelters(db)
    
    total_capacity = sum(s.max_capacity for s in shelters if s.max_capacity)
    total_occupancy = sum(s.current_occupancy for s in shelters if s.current_occupancy)
    
    return {
        "shelters": {
            "total": len(shelters),
            "available": len(available),
            "full": len(shelters) - len(available)
        },
        "capacity": {
            "total": total_capacity,
            "occupied": total_occupancy,
            "available": total_capacity - total_occupancy,
            "occupancy_rate": round(total_occupancy / total_capacity * 100, 1) if total_capacity > 0 else 0
        },
        "model": {
            "version": predictor.model_version,
            "clusters": predictor.n_clusters,
            "features": len(predictor.feature_names)
        }
    }


# ===== MANEJO DE ERRORES =====

@app.exception_handler(404)
async def not_found_handler(request, exc):
    return {
        "error": "Not Found",
        "detail": str(exc.detail) if hasattr(exc, 'detail') else "Resource not found",
        "status_code": 404
    }


@app.exception_handler(500)
async def internal_error_handler(request, exc):
    return {
        "error": "Internal Server Error",
        "detail": "An internal error occurred. Please contact support.",
        "status_code": 500
    }


# ===== PUNTO DE ENTRADA =====

if __name__ == "__main__":
    import uvicorn
    
    print("\nIniciando sin modo reload para debugging...")
    
    uvicorn.run(
        app,  # Pasar la app directamente, no como string
        host=settings.API_HOST,
        port=settings.API_PORT,
        reload=False,  # Desactivar reload para debugging
        log_level="info"
    )
