from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
import uvicorn

app = FastAPI(
    title="ShelterAI - Inference API",
    description="API para asignación inteligente de refugiados a refugios",
    version="0.1.0"
)

# Configurar CORS para permitir peticiones desde Node-RED
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especificar dominios concretos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Modelos de datos
class ShelterInfo(BaseModel):
    """Información de un refugio disponible"""
    id: int
    name: str
    max_capacity: int
    current_occupancy: int
    has_medical_facilities: Optional[bool] = False
    has_childcare: Optional[bool] = False
    has_disability_access: Optional[bool] = False
    languages_spoken: Optional[str] = None


class RefugeeData(BaseModel):
    """Datos del refugiado para la asignación"""
    first_name: str
    last_name: str
    age: int
    gender: Optional[str] = None
    nationality: Optional[str] = None
    languages_spoken: Optional[str] = None
    medical_conditions: Optional[str] = None
    has_disability: Optional[bool] = False
    vulnerability_score: Optional[float] = 0.0
    special_needs: Optional[str] = None
    family_id: Optional[int] = None


class AssignmentRequest(BaseModel):
    """Request con el refugiado y refugios disponibles"""
    refugee: RefugeeData
    available_shelters: List[ShelterInfo]


class ShelterRecommendation(BaseModel):
    """Respuesta con la recomendación de refugio"""
    shelter_id: int
    shelter_name: str
    confidence_score: float
    priority_score: float
    explanation: str
    alternative_shelters: Optional[List[dict]] = None


class HealthResponse(BaseModel):
    """Respuesta del health check"""
    status: str
    version: str
    model_loaded: bool


# Endpoint de health check
@app.get("/", response_model=HealthResponse)
@app.get("/health", response_model=HealthResponse)
async def health_check():
    """
    Endpoint para verificar que el servicio está funcionando
    """
    return {
        "status": "healthy",
        "version": "0.1.0",
        "model_loaded": False  # Cambiar a True cuando el modelo esté cargado
    }


# Endpoint principal de asignación con refugios disponibles
@app.post("/api/assign-shelter", response_model=ShelterRecommendation)
async def assign_shelter(request: AssignmentRequest):
    """
    Asigna un refugio a un refugiado basándose en sus características
    y los refugios disponibles en la base de datos.
    """
    if not request.available_shelters:
        raise HTTPException(
            status_code=400,
            detail="No hay refugios disponibles en este momento"
        )
    
    # Calcular prioridad del refugiado
    priority_score = calculate_priority(request.refugee)
    
    # Encontrar el mejor refugio de los disponibles
    shelter_assignment = find_best_shelter(
        request.refugee, 
        request.available_shelters, 
        priority_score
    )
    
    return shelter_assignment


def calculate_priority(refugee: RefugeeData) -> float:
    """
    Calcula la puntuación de prioridad del refugiado
    Escala: 0-100 (mayor = más prioritario)
    """
    priority = 0.0
    
    # Vulnerabilidad base
    if refugee.vulnerability_score:
        priority += refugee.vulnerability_score * 0.4
    
    # Edad (menores y mayores tienen prioridad)
    if refugee.age < 18:
        priority += 30
    elif refugee.age > 65:
        priority += 20
    
    # Condiciones médicas
    if refugee.medical_conditions and refugee.medical_conditions.strip():
        priority += 25
    
    # Discapacidad
    if refugee.has_disability:
        priority += 25
    
    # Necesidades especiales
    if refugee.special_needs and refugee.special_needs.strip():
        priority += 15
    
    # Normalizar a 0-100
    return min(priority, 100.0)


def find_best_shelter(
    refugee: RefugeeData, 
    shelters: List[ShelterInfo], 
    priority_score: float
) -> ShelterRecommendation:
    """
    Encuentra el mejor refugio entre los disponibles según las necesidades del refugiado
    """
    best_shelter = None
    best_score = -1
    
    for shelter in shelters:
        score = calculate_match_score(refugee, shelter)
        if score > best_score:
            best_score = score
            best_shelter = shelter
    
    if not best_shelter:
        raise HTTPException(
            status_code=404,
            detail="No se pudo encontrar un refugio adecuado"
        )
    
    # Calcular confianza basada en el score de compatibilidad
    confidence = min(best_score / 100.0, 0.95)
    
    # Generar explicación
    explanation = generate_explanation(refugee, best_shelter, priority_score, best_score)
    
    # Buscar alternativas
    alternatives = []
    for shelter in shelters:
        if shelter.id != best_shelter.id:
            alt_score = calculate_match_score(refugee, shelter)
            if alt_score > 50:  # Solo incluir alternativas razonables
                alternatives.append({
                    "shelter_id": shelter.id,
                    "shelter_name": shelter.name,
                    "confidence_score": round(alt_score / 100.0, 2)
                })
    
    # Ordenar alternativas por score
    alternatives.sort(key=lambda x: x["confidence_score"], reverse=True)
    
    return ShelterRecommendation(
        shelter_id=best_shelter.id,
        shelter_name=best_shelter.name,
        confidence_score=round(confidence, 2),
        priority_score=round(priority_score, 1),
        explanation=explanation,
        alternative_shelters=alternatives[:2]  # Máximo 2 alternativas
    )


def calculate_match_score(refugee: RefugeeData, shelter: ShelterInfo) -> float:
    """
    Calcula una puntuación de compatibilidad entre refugiado y refugio
    """
    score = 0.0
    
    # 1. Capacidad disponible (peso: 30%)
    if shelter.max_capacity > 0:
        occupancy_rate = shelter.current_occupancy / shelter.max_capacity
        score += (1.0 - occupancy_rate) * 30.0
    
    # 2. Facilidades médicas si el refugiado tiene condiciones médicas (peso: 25%)
    if refugee.medical_conditions and refugee.medical_conditions.strip():
        if shelter.has_medical_facilities:
            score += 25.0
    
    # 3. Acceso para discapacitados (peso: 20%)
    if refugee.has_disability:
        if shelter.has_disability_access:
            score += 20.0
    
    # 4. Cuidado infantil para niños (peso: 15%)
    if refugee.age < 18:
        if shelter.has_childcare:
            score += 15.0
    
    # 5. Idiomas compartidos (peso: 10%)
    if has_common_language_shelter(refugee, shelter):
        score += 10.0
    
    return score


def has_common_language_shelter(refugee: RefugeeData, shelter: ShelterInfo) -> bool:
    """
    Verifica si hay idiomas en común
    """
    if not refugee.languages_spoken or not shelter.languages_spoken:
        return False
    
    refugee_langs = [l.strip().lower() for l in refugee.languages_spoken.split(",")]
    shelter_langs = [l.strip().lower() for l in shelter.languages_spoken.split(",")]
    
    return any(rl in shelter_langs for rl in refugee_langs)


def generate_explanation(
    refugee: RefugeeData, 
    shelter: ShelterInfo, 
    priority_score: float,
    match_score: float
) -> str:
    """
    Genera una explicación legible de la asignación
    """
    explanation = []
    explanation.append(f"Refugio asignado: {shelter.name}")
    explanation.append(f"Prioridad del refugiado: {priority_score:.1f}/100")
    explanation.append(f"Compatibilidad: {match_score:.1f}/100")
    explanation.append(f"Ocupación actual: {shelter.current_occupancy}/{shelter.max_capacity}")
    explanation.append("\nFactores considerados:")
    
    if refugee.medical_conditions and refugee.medical_conditions.strip():
        if shelter.has_medical_facilities:
            explanation.append("✓ Tiene facilidades médicas necesarias")
        else:
            explanation.append("⚠ No tiene facilidades médicas")
    
    if refugee.has_disability:
        if shelter.has_disability_access:
            explanation.append("✓ Acceso para personas con discapacidad")
        else:
            explanation.append("⚠ Acceso limitado para discapacidad")
    
    if refugee.age < 18:
        if shelter.has_childcare:
            explanation.append("✓ Servicios de cuidado infantil disponibles")
    
    if has_common_language_shelter(refugee, shelter):
        explanation.append("✓ Idiomas compartidos disponibles")
    
    explanation.append("\n[Sistema temporal - será mejorado con IA]")
    
    return "\n".join(explanation)


def assign_by_rules(refugee: RefugeeData, priority_score: float) -> ShelterRecommendation:
    """
    Asigna un refugio basándose en reglas temporales
    
    ESTRATEGIA TEMPORAL:
    - Alta prioridad (>70) -> Refugio 1 (mejor equipado)
    - Media prioridad (40-70) -> Refugio 2 (estándar)
    - Baja prioridad (<40) -> Refugio 3 (básico)
    """
    
    explanation_parts = []
    
    # Determinar refugio según prioridad
    if priority_score >= 70:
        shelter_id = 1
        shelter_name = "Refugio Principal - Alta Prioridad"
        confidence = 0.85
        explanation_parts.append("Alta prioridad detectada")
        
    elif priority_score >= 40:
        shelter_id = 2
        shelter_name = "Refugio Central - Prioridad Media"
        confidence = 0.75
        explanation_parts.append("Prioridad media")
        
    else:
        shelter_id = 3
        shelter_name = "Refugio Temporal - Prioridad Estándar"
        confidence = 0.65
        explanation_parts.append("Prioridad estándar")
    
    # Añadir factores a la explicación
    if refugee.age < 18:
        explanation_parts.append(f"Menor de edad ({refugee.age} años)")
    elif refugee.age > 65:
        explanation_parts.append(f"Persona mayor ({refugee.age} años)")
    
    if refugee.medical_conditions and refugee.medical_conditions.strip():
        explanation_parts.append("Condiciones médicas presentes")
    
    if refugee.has_disability:
        explanation_parts.append("Requiere acceso para discapacidad")
    
    if refugee.special_needs and refugee.special_needs.strip():
        explanation_parts.append("Necesidades especiales")
    
    # Generar explicación
    explanation = (
        f"Asignación basada en reglas temporales.\n"
        f"Puntuación de prioridad: {priority_score:.1f}/100\n"
        f"Factores considerados: {', '.join(explanation_parts) if explanation_parts else 'Ninguno destacado'}\n\n"
        f"⚠️ SISTEMA TEMPORAL: Esta asignación será mejorada con el modelo de IA."
    )
    
    # Alternativas (mock)
    alternatives = []
    if shelter_id != 2:
        alternatives.append({
            "shelter_id": 2,
            "shelter_name": "Refugio Central",
            "confidence_score": confidence - 0.15
        })
    
    return ShelterRecommendation(
        shelter_id=shelter_id,
        shelter_name=shelter_name,
        confidence_score=confidence,
        priority_score=priority_score,
        explanation=explanation,
        alternative_shelters=alternatives
    )


# Endpoint para cuando el modelo esté listo
@app.post("/api/assign-shelter-ml")
async def assign_shelter_ml(refugee: RefugeeData):
    """
    Endpoint futuro para el modelo de Machine Learning
    """
    raise HTTPException(
        status_code=501,
        detail="Modelo de ML aún no implementado. Use /api/assign-shelter para el sistema temporal."
    )


if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
