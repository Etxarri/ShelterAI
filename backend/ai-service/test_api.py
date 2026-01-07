# Script de ayuda para testing rápido
# Uso: python test_api.py

import requests
import json

# URL de la API (cambiar si es necesario)
BASE_URL = "http://localhost:8000"

def test_health():
    """Prueba el health check"""
    print("\n🔍 Probando Health Check...")
    response = requests.get(f"{BASE_URL}/health")
    print(f"Status: {response.status_code}")
    print(json.dumps(response.json(), indent=2))
    return response.status_code == 200

def test_recommendation():
    """Prueba una recomendación"""
    print("\n🏠 Probando Recomendación de Refugio...")
    
    refugee_data = {
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
    
    response = requests.post(
        f"{BASE_URL}/api/recommend",
        json=refugee_data
    )
    
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"\n✅ Recomendación exitosa!")
        print(f"Cluster: {data['cluster_id']} - {data['cluster_label']}")
        print(f"Vulnerabilidad: {data['vulnerability_level']}")
        print(f"\nTop {len(data['recommendations'])} Refugios:")
        
        for i, rec in enumerate(data['recommendations'], 1):
            print(f"\n{i}. {rec['shelter_name']} (Score: {rec['compatibility_score']:.1f})")
            print(f"   Dirección: {rec['address']}")
            print(f"   Disponibilidad: {rec['available_space']}/{rec['max_capacity']} espacios")
            print(f"   Explicación: {rec['explanation'][:100]}...")
    else:
        print(f"❌ Error: {response.text}")
    
    return response.status_code == 200

def test_stats():
    """Prueba las estadísticas"""
    print("\n📊 Probando Estadísticas...")
    response = requests.get(f"{BASE_URL}/api/stats")
    print(f"Status: {response.status_code}")
    print(json.dumps(response.json(), indent=2))
    return response.status_code == 200

if __name__ == "__main__":
    print("=" * 60)
    print("🧪 TESTING SHELTERAI API")
    print("=" * 60)
    
    try:
        # Test 1: Health
        health_ok = test_health()
        
        if health_ok:
            # Test 2: Recommendation
            test_recommendation()
            
            # Test 3: Stats
            test_stats()
        else:
            print("\n❌ API no está disponible. Verificar que esté corriendo.")
    
    except requests.exceptions.ConnectionError:
        print(f"\n❌ No se pudo conectar a {BASE_URL}")
        print("   Asegúrate de que la API esté corriendo:")
        print("   - Localmente: python inference_api/main.py")
        print("   - Docker: docker compose up -d")
    except Exception as e:
        print(f"\n❌ Error: {e}")
    
    print("\n" + "=" * 60)
