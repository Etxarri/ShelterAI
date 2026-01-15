import pytest
from unittest.mock import MagicMock, patch
import pandas as pd
import numpy as np
from inference_api.predictor import ShelterPredictor
from inference_api.schemas import RefugeeInput
from inference_api.database import Shelter

@pytest.fixture
def mock_artifacts():
    return {
        'clusterer': MagicMock(),
        'umap_reducer': MagicMock(),
        'scaler': MagicMock(),
        'numeric_imputer': MagicMock(),
        'categorical_imputer': MagicMock(),
        'feature_names': [
            'head_age_group', 
            'gender_male', 
            'gender_female', 
            'what_is_sizeyour_famil',
            'have_children_yes',
            'hh_info_medical_condition',
            'has_disability_column',
            'psychological_distress_column',
            'status_refugee'
        ],
        'numeric_cols': ['head_age_group', 'what_is_sizeyour_famil'],
        'categorical_cols': ['gender_male', 'gender_female'],
        'n_clusters': 5,
        'model_version': '1.0'
    }

@pytest.fixture
def predictor(mock_artifacts):
    with patch("joblib.load", return_value=mock_artifacts), \
         patch("os.path.exists", return_value=True):
        return ShelterPredictor("dummy_path.joblib")

def test_preprocess_refugee_data_all_features(predictor):
    # Test path with all features enabled
    refugee = RefugeeInput(
        first_name="Jane",
        last_name="Smith",
        age=25,
        gender="F",
        nationality="Syrian",
        family_size=5,
        has_children=True,
        children_count=3,
        medical_conditions="Diabetes",
        requires_medical_facilities=True,
        has_disability=True,
        psychological_distress=True,
        status="refugee"
    )
    
    processed_data = predictor.preprocess_refugee_data(refugee)
    
    # Check specific mappings (indices based on mock_artifacts.feature_names)
    assert processed_data[0][0] == 25  # age
    assert processed_data[0][2] == 1   # gender_female (now fixed)
    assert processed_data[0][1] == 0   # gender_male
    assert processed_data[0][3] == 5   # family_size
    assert processed_data[0][4] == 1   # have_children_yes
    assert processed_data[0][5] == 1   # medical_condition_present
    assert processed_data[0][6] == 1   # has_disability_column
    assert processed_data[0][7] == 1   # psychological_distress_column
    assert processed_data[0][8] == 1   # status_refugee

def test_predict_cluster(predictor, mock_artifacts):
    refugee = RefugeeInput(
        first_name="Test", last_name="User", age=30, gender="M", nationality="Test"
    )
    
    # Mock the internal calls (9 features now)
    predictor.scaler.transform.return_value = np.zeros((1, 9))
    predictor.umap_reducer.transform.return_value = np.array([[0.5, 0.6]])
    
    with patch.object(predictor, '_predict_cluster_knn', return_value=1):
        cluster_id, label, level = predictor.predict_cluster(refugee)
        
        assert cluster_id == 1
        assert label == "Familias numerosas con niños"
        assert level == "medium"

def test_predict_cluster_knn(predictor):
    X_reduced = np.array([[0.5, 0.6]])
    
    # Mock training data for KNN
    predictor.X_train_reduced = np.array([[0.5, 0.6], [1.0, 1.1], [0.5, 0.5]])
    predictor.y_train_clusters = np.array([1, 2, 1])
    
    cluster_id = predictor._predict_cluster_knn(X_reduced)
    assert cluster_id == 1

def test_predict_cluster_knn_fallback(predictor):
    # Test fallback when no training data is available
    predictor.X_train_reduced = None
    predictor.y_train_clusters = None
    X_reduced = np.array([[0.5, 0.6]])
    
    with patch("hdbscan.approximate_predict", return_value=(np.array([2]), [0.8])):
        cluster_id = predictor._predict_cluster_knn(X_reduced)
        assert cluster_id == 2

def test_get_cluster_info_various_levels(predictor):
    # Test critical vulnerability
    refugee_critical = RefugeeInput(
        first_name="C", last_name="R", age=80, gender="F", nationality="N",
        has_disability=True, requires_medical_facilities=True, vulnerability_score=9.0
    )
    _, level = predictor._get_cluster_info(3, refugee_critical)
    assert level == "critical"

    # Test low vulnerability
    refugee_low = RefugeeInput(
        first_name="L", last_name="O", age=30, gender="M", nationality="N",
        vulnerability_score=2.0
    )
    _, level = predictor._get_cluster_info(0, refugee_low)
    assert level == "low"

def test_recommend_shelters(predictor):
    refugee = RefugeeInput(
        first_name="Test", last_name="User", age=30, gender="M", nationality="Test"
    )
    shelters = [
        Shelter(id=1, name="S1", max_capacity=10, current_occupancy=0),
        Shelter(id=2, name="S2", max_capacity=10, current_occupancy=10) # Full
    ]
    
    with patch.object(predictor, 'predict_cluster', return_value=(1, "L", "low")):
        recs = predictor.recommend_shelters(refugee, shelters)
        assert len(recs) == 1
        assert recs[0].shelter_id == 1

def test_calculate_compatibility_edge_cases(predictor):
    refugee = RefugeeInput(
        first_name="T", last_name="U", age=10, gender="M", nationality="T",
        has_children=True, children_count=2, languages_spoken="Arabic,French"
    )
    
    # Shelter with language match and childcare
    shelter = Shelter(
        id=1, name="S", max_capacity=50, current_occupancy=5,
        has_childcare=True, languages_spoken="Arabic", shelter_type="temporary"
    )
    
    score, reasons = predictor.calculate_shelter_compatibility(refugee, shelter, 1, "medium")
    assert score > 0
    # Case-insensitive check
    assert any("arabic" in r.lower() for r in reasons)
    assert any("childcare" in r.lower() for r in reasons)

def test_calculate_compatibility_disability_fail(predictor):
    refugee = RefugeeInput(
        first_name="T", last_name="U", age=30, gender="M", nationality="T",
        has_disability=True
    )
    shelter = Shelter(
        id=1, name="S", max_capacity=50, current_occupancy=5,
        has_disability_access=False
    )
    
    score, reasons = predictor.calculate_shelter_compatibility(refugee, shelter, 1, "high")
    assert any("Not disability accessible" in r for r in reasons)
    # The current implementation subtracts 30 and continues, but may still be > 0 if other points high
    # WAIT, looking at code: if has_disability and not has_disability_access, it subtracts 30.
    
def test_predictor_init_errors():
    with pytest.raises(FileNotFoundError):
        ShelterPredictor("non_existent_path.joblib")
