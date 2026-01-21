from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime

# ============================================================
# INPUT SCHEMAS
# ============================================================

class RefugeeInput(BaseModel):
    """
    Refugee/person data used to compute the cluster assignment.

    Note: These fields represent *product-level* information for the UI/workflow.
    The ML pipeline will internally map/encode/impute as needed.
    """

    # Basic info
    first_name: str = Field(..., description="First name")
    last_name: str = Field(..., description="Last name")
    age: int = Field(..., ge=0, le=120, description="Age")
    gender: str = Field(..., description="Gender: M/F/Other")
    nationality: str = Field(..., description="Nationality")

    # Family
    family_size: Optional[int] = Field(None, ge=1, description="Family size")
    has_children: Optional[bool] = Field(None, description="Has children?")
    children_count: Optional[int] = Field(0, ge=0, description="Number of children")

    # Health / special needs (high-level, optional)
    medical_conditions: Optional[str] = Field(None, description="Medical conditions (free text)")
    has_disability: Optional[bool] = Field(False, description="Has disability?")
    psychological_distress: Optional[bool] = Field(False, description="Psychological distress?")
    requires_medical_facilities: Optional[bool] = Field(False, description="Requires medical facilities?")

    # Languages
    languages_spoken: Optional[str] = Field(None, description="Languages spoken (comma-separated)")

    # Status / notes
    status: Optional[str] = Field("refugee", description="Status: refugee/idp/returnee")
    special_needs: Optional[str] = Field(None, description="Additional special needs (free text)")

    # Optional external score (if your product already has one)
    vulnerability_score: Optional[float] = Field(None, ge=0, le=10, description="Vulnerability score (0-10)")

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


# ============================================================
# OUTPUT SCHEMAS (NO SHELTER RECOMMENDATIONS)
# ============================================================

class ClusterFeatureSignal(BaseModel):
    """
    Human-readable signals that explain why this person fits the cluster.

    - feature: internal feature name (or friendly name if you map it)
    - direction: "higher" / "lower" / "present" (depending on your encoding)
    - strength: effect size / lift / contribution (your pipeline decides)
    - note: short explanation for staff
    """
    feature: str
    direction: Optional[str] = None
    strength: Optional[float] = None
    note: Optional[str] = None


class ClusterSummary(BaseModel):
    """
    Information that helps staff understand what this cluster represents.

    This should be built from your offline cluster profiling step:
    - label/title + short description
    - key needs / typical signals
    - prevalence (share of population)
    - cautions / operational notes
    """
    cluster_id: int = Field(..., description="Cluster id produced by the model")
    cluster_label: str = Field(..., description="Short descriptive label for the cluster")
    description: Optional[str] = Field(None, description="Short explanation of what this cluster represents")

    # Optional stats from training/profiling
    cluster_size: Optional[int] = Field(None, description="Number of people in this cluster in training data")
    cluster_share: Optional[float] = Field(None, ge=0, le=1, description="Share of training population (0-1)")

    # What to highlight to staff
    top_signals: List[ClusterFeatureSignal] = Field(default_factory=list, description="Key signals / needs for this cluster")
    operational_notes: Optional[List[str]] = Field(default_factory=list, description="Practical notes for staff (e.g., typical needs, cautions)")
    suggested_questions: Optional[List[str]] = Field(default_factory=list, description="Questions staff may ask to confirm needs / context")


class PersonClusterResult(BaseModel):
    """
    Full response for the staff workflow:
    - person summary
    - model assignment
    - cluster summary (precomputed profile)
    - individualized signals for this person
    """
    person: Dict[str, Any] = Field(..., description="Basic person information echoed back to the UI")

    # Assignment
    cluster_id: int = Field(..., description="Assigned cluster")
    cluster_label: str = Field(..., description="Cluster label")
    confidence: Optional[float] = Field(None, ge=0, le=1, description="Optional confidence/probability (if available)")
    assignment_method: str = Field(..., description="How the assignment was computed (e.g., 'agglomerative+nearest-centroid')")

    # Summaries
    cluster_summary: ClusterSummary = Field(..., description="Precomputed cluster profile information")
    person_signals: List[ClusterFeatureSignal] = Field(default_factory=list, description="Most important signals for this specific person")

    # Metadata
    timestamp: datetime = Field(default_factory=datetime.now, description="Response timestamp")
    ml_model_version: str = Field(..., description="Model version used")


class HealthCheck(BaseModel):
    """API health status"""
    status: str
    ml_model_loaded: bool
    timestamp: datetime

    model_config = {"protected_namespaces": ()}