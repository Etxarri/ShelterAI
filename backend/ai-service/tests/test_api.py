from unittest.mock import MagicMock, patch
from inference_api.schemas import ShelterRecommendation

def test_read_root(client):
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["service"] == "ShelterAI Recommendation API"

def test_health_check(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["ml_model_loaded"] is True
    assert data["database_connected"] is True

def test_recommend_shelter_success(client, mock_predictor, mock_db):
    # Setup mock data
    refugee_input = {
        "first_name": "Test",
        "last_name": "User",
        "age": 30,
        "gender": "M",
        "nationality": "Test",
        "family_size": 1,
        "has_children": False,
        "children_count": 0,
        "medical_conditions": "none",
        "requires_medical_facilities": False,
        "languages_spoken": "English",
        "vulnerability_score": 5.0
    }
    
    # Use real ShelterRecommendation instead of MagicMock
    mock_rec = ShelterRecommendation(
        shelter_id=1,
        shelter_name="Test Shelter",
        compatibility_score=95.5,
        address="Test Address",
        priority_score=5.0,
        max_capacity=100,
        current_occupancy=10,
        available_space=90,
        occupancy_rate=10.0,
        has_medical_facilities=True,
        has_childcare=False,
        has_disability_access=True,
        languages_spoken="English",
        shelter_type="long-term",
        services_offered="General",
        explanation="Good match",
        matching_reasons=["reason1"]
    )

    mock_predictor.recommend_shelters.return_value = [mock_rec]
    mock_predictor.predict_cluster.return_value = (1, "Test Cluster", "high")

    response = client.post("/api/recommend", json=refugee_input)
    
    assert response.status_code == 200
    data = response.json()
    assert data["cluster_id"] == 1
    assert data["cluster_label"] == "Test Cluster"
    assert len(data["recommendations"]) == 1
    assert data["recommendations"][0]["shelter_name"] == "Test Shelter"

def test_recommend_shelter_no_shelters(client, mock_predictor, mock_db):
    # Mocking get_available_shelters to return empty list
    with patch("inference_api.main.get_available_shelters", return_value=[]):
        refugee_input = {
            "first_name": "Test",
            "last_name": "User",
            "age": 30,
            "gender": "M",
            "nationality": "Test",
            "family_size": 1
        }
        response = client.post("/api/recommend", json=refugee_input)
        assert response.status_code == 404
        assert "No hay refugios disponibles" in response.json()["detail"]

def test_recommend_shelter_exception(client, mock_predictor):
    # Mock an unexpected error
    mock_predictor.predict_cluster.side_effect = Exception("Predictor error")
    
    refugee_input = {
        "first_name": "Test", "last_name": "User", "age": 30, "gender": "M", "nationality": "Test"
    }
    response = client.post("/api/recommend", json=refugee_input)
    assert response.status_code == 500
    assert "detail" in response.json()

def test_recommend_shelter_no_recommendations(client, mock_predictor, mock_db):
    # Mock zero recommendations returned
    mock_predictor.recommend_shelters.return_value = []
    
    with patch("inference_api.main.get_available_shelters", return_value=[MagicMock()]):
        refugee_input = {
            "first_name": "Test", "last_name": "User", "age": 30, "gender": "M", "nationality": "Test"
        }
        response = client.post("/api/recommend", json=refugee_input)
        assert response.status_code == 404
        assert "No se encontraron refugios compatibles" in response.json()["detail"]

def test_404_handler(client):
    response = client.get("/non-existent-endpoint")
    assert response.status_code == 404
    assert response.json()["error"] == "Not Found"

def test_stats(client, mock_predictor):
    # Mock database functions for stats
    
    mock_shelter = MagicMock()
    mock_shelter.max_capacity = 100
    mock_shelter.current_occupancy = 40
    
    with patch("inference_api.main.get_all_shelters", return_value=[mock_shelter]), \
         patch("inference_api.main.get_available_shelters", return_value=[mock_shelter]):
        
        response = client.get("/api/stats")
        assert response.status_code == 200
        data = response.json()
        assert data["shelters"]["total"] == 1
        assert data["capacity"]["total"] == 100
        assert data["capacity"]["occupied"] == 40
        assert data["capacity"]["occupancy_rate"] == 40.0
