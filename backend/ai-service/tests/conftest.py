import pytest
from fastapi.testclient import TestClient
from unittest.mock import MagicMock, patch
import sys
import os

# Añadir el directorio raíz al path para poder importar inference_api
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

@pytest.fixture
def mock_db():
    return MagicMock()

@pytest.fixture
def mock_predictor():
    predictor = MagicMock()
    predictor.model_version = "test-1.0"
    predictor.n_clusters = 5
    predictor.feature_names = ["feature1", "feature2"]
    
    # Mock return values for common methods
    predictor.predict_cluster.return_value = (1, "Test Cluster", "high")
    predictor.recommend_shelters.return_value = []
    return predictor

@pytest.fixture
def client(mock_predictor, mock_db):
    # Mocking various components before importing the app
    with patch("inference_api.predictor.ShelterPredictor", return_value=mock_predictor), \
         patch("inference_api.database.check_database_connection", return_value=True), \
         patch("inference_api.database.SessionLocal", return_value=mock_db):
        
        # Import the app after patches are set up
        from inference_api.main import app
        from inference_api.database import get_db
        from inference_api.predictor import get_predictor
        
        # Override dependencies
        app.dependency_overrides[get_db] = lambda: mock_db
        app.dependency_overrides[get_predictor] = lambda: mock_predictor
        
        with TestClient(app) as c:
            yield c
        
        # Clean up overrides
        app.dependency_overrides.clear()
