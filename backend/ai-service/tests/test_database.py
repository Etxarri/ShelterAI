import pytest
from unittest.mock import MagicMock, patch
from inference_api.database import get_db, get_available_shelters, get_shelter_by_id, check_database_connection, get_all_shelters, Shelter

def test_get_db():
    with patch("inference_api.database.SessionLocal") as mock_session_local:
        mock_db = MagicMock()
        mock_session_local.return_value = mock_db
        
        db_gen = get_db()
        db = next(db_gen)
        
        assert db == mock_db
        
        # Test generator finalization
        try:
            next(db_gen)
        except StopIteration:
            pass
        
        mock_db.close.assert_called_once()

def test_get_available_shelters():
    mock_db = MagicMock()
    s1 = Shelter(id=1, max_capacity=10, current_occupancy=5)
    s2 = Shelter(id=2, max_capacity=10, current_occupancy=10)
    
    # Mock SQLAlchemy query
    mock_db.query.return_value.filter.return_value.all.return_value = [s1]
    
    result = get_available_shelters(mock_db)
    assert len(result) == 1
    assert result[0].id == 1

def test_get_shelter_by_id():
    mock_db = MagicMock()
    s1 = Shelter(id=1)
    
    mock_db.query.return_value.filter.return_value.first.return_value = s1
    
    result = get_shelter_by_id(mock_db, 1)
    assert result.id == 1

def test_get_all_shelters():
    mock_db = MagicMock()
    s1 = Shelter(id=1)
    s2 = Shelter(id=2)
    
    mock_db.query.return_value.all.return_value = [s1, s2]
    
    result = get_all_shelters(mock_db)
    assert len(result) == 2

def test_check_database_connection_success():
    with patch("inference_api.database.SessionLocal") as mock_session_local:
        mock_db = MagicMock()
        mock_session_local.return_value = mock_db
        
        assert check_database_connection() is True
        mock_db.execute.assert_called()
        mock_db.close.assert_called()

def test_check_database_connection_failure():
    with patch("inference_api.database.SessionLocal") as mock_session_local:
        mock_db = MagicMock()
        mock_db.execute.side_effect = Exception("Connection error")
        mock_session_local.return_value = mock_db
        
        assert check_database_connection() is False
        mock_db.close.assert_not_called() # It fails before closing or it's in a way it doesn't close if fail at execute? 
        # Actually the code doesn't have a finally block for close there.
