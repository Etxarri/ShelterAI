"""
ShelterAI - Cluster Decision Support API
FastAPI service to assign a person to a cluster and explain:
- Top person features (vs global + vs cluster)
- Cluster profile (top defining features vs global)
"""

from __future__ import annotations

from typing import Any, Dict, Optional, List
from datetime import datetime

from fastapi import FastAPI, HTTPException, Body, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from .config import settings
from .schemas import HealthCheck
from .predictor import ShelterPredictor


app = FastAPI(
    title="ShelterAI - Cluster Decision Support API",
    description=(
        "API to assign a person to a needs/vulnerability cluster and return explanations "
        "(no shelter recommendations; staff decides manually)."
    ),
    version="2.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# -------------------------
# Startup
# -------------------------
@app.on_event("startup")
async def startup_event():
    print("\n" + "=" * 60)
    print("STARTING SHELTERAI API (CLUSTER DECISION SUPPORT)")
    print("=" * 60)

    try:
        app.state.predictor = ShelterPredictor(settings.MODEL_PATH)
        print("✅ ML model loaded successfully")

        display_host = "localhost" if settings.API_HOST == "0.0.0.0" else settings.API_HOST
        print("=" * 60)
        print(f"API:  http://{display_host}:{settings.API_PORT}")
        print(f"Docs: http://{display_host}:{settings.API_PORT}/docs")
        print("=" * 60 + "\n")
    except Exception as e:
        print(f"❌ Startup error: {e}")
        raise


def get_predictor(request: Request) -> ShelterPredictor:
    pred = getattr(request.app.state, "predictor", None)
    if pred is None:
        raise RuntimeError("Predictor not initialized")
    return pred


# -------------------------
# Helpers
# -------------------------
def _safe_get_cluster_profile(predictor: ShelterPredictor, cluster_id: int) -> Optional[Dict[str, Any]]:
    try:
        return predictor.get_cluster_profile(cluster_id)
    except Exception:
        return None


# -------------------------
# Endpoints
# -------------------------
@app.get("/", tags=["General"])
async def root():
    return {
        "service": "ShelterAI - Cluster Decision Support API",
        "version": app.version,
        "status": "running",
        "endpoints": {
            "health": "/health",
            "cluster": "/api/cluster",
            "features": "/api/features",
            "clusters": "/api/clusters",
            "cluster_detail": "/api/clusters/{cluster_id}",
            "docs": "/docs",
        },
    }


@app.get("/health", response_model=HealthCheck, tags=["General"])
async def health_check(request: Request):
    predictor = get_predictor(request)
    model_loaded = predictor is not None
    return HealthCheck(
        status="healthy" if model_loaded else "degraded",
        ml_model_loaded=model_loaded,
        timestamp=datetime.now(),
    )


@app.get("/api/features", tags=["Decision Support"])
async def list_expected_features(request: Request):
    predictor = get_predictor(request)
    return {
        "n_features": len(predictor.feature_names),
        "feature_names": predictor.feature_names,
        "timestamp": datetime.now().isoformat(),
    }

@app.post("/api/recommend", tags=["Decision Support"])
async def recommend_alias(
    request: Request,
    payload: Dict[str, Any] = Body(..., description="Alias for /api/cluster (raw features)"),
):
    # Backwards compatible alias
    return await assign_cluster(request=request, payload=payload)



@app.post("/api/cluster", tags=["Decision Support"])
async def assign_cluster(
    request: Request,
    payload: Dict[str, Any] = Body(..., description="Raw feature dict (one-hot columns) + optional person_id"),
):
    """
    Input: JSON dict with keys = trained feature names (the 555 columns)
    Optional: person_id

    Output:
    - cluster_id
    - top 8 person features (vs global + vs cluster)
    - cluster profile (top defining features vs global)
    """
    try:
        predictor = get_predictor(request)

        # Optional metadata field (doesn't affect clustering)
        person_id = payload.get("person_id")

        # Everything except person_id is treated as feature input
        features = dict(payload)
        features.pop("person_id", None)

        # Align + predict
        _, input_meta = predictor.align_features(features)
        cluster_id, confidence = predictor.predict_cluster(features, k_neighbors=25)

        person_top = predictor.top_person_features(features, cluster_id=cluster_id, top_n=8)
        profile = _safe_get_cluster_profile(predictor, cluster_id)

        return {
            "person_id": person_id,
            "cluster": {
                "cluster_id": cluster_id,
                "vote_confidence": round(confidence, 4),
            },
            "person_top_features": person_top,
            "cluster_profile": profile,
            "input_summary": input_meta,
            "model": {
                "version": predictor.model_version,
                "n_clusters": predictor.n_clusters,
                "n_features": len(predictor.feature_names),
            },
            "timestamp": datetime.now().isoformat(),
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal error during clustering: {str(e)}")


@app.get("/api/clusters", tags=["Decision Support"])
async def list_clusters(request: Request):
    predictor = get_predictor(request)
    return {
        "n_clusters": predictor.n_clusters,
        "clusters": predictor.get_clusters_index(),
        "timestamp": datetime.now().isoformat(),
    }


@app.get("/api/clusters/{cluster_id}", tags=["Decision Support"])
async def cluster_detail(cluster_id: int, request: Request):
    predictor = get_predictor(request)
    profile = _safe_get_cluster_profile(predictor, cluster_id)
    if profile is None:
        raise HTTPException(status_code=404, detail="Cluster profile not found in artifacts.")
    return {
        "cluster_id": cluster_id,
        "profile": profile,
        "timestamp": datetime.now().isoformat(),
    }


# -------------------------
# Error handlers
# -------------------------
@app.exception_handler(404)
async def not_found_handler(request: Request, exc):
    return JSONResponse(
        status_code=404,
        content={
            "error": "Not Found",
            "detail": str(getattr(exc, "detail", "Resource not found")),
            "status_code": 404,
        },
    )


@app.exception_handler(500)
async def internal_error_handler(request: Request, exc):
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal Server Error",
            "detail": "An internal error occurred. Please contact support.",
            "status_code": 500,
        },
    )
