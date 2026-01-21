import 'package:flutter_test/flutter_test.dart';
// Asegúrate de que este import apunte a donde tienes tu archivo recommendation.dart
// Si lo tienes separado en dos archivos, importa ambos.
import 'package:shelter_ai/models/recommendation.dart'; 
import 'package:shelter_ai/models/recommendation_response.dart'; 
// NOTA: Si en tu proyecto RecommendationResponse y Recommendation están en el mismo archivo, 
// solo necesitas un import.

void main() {
  group('RecommendationResponse Tests', () {
    
    // CASO 1: Formato Nuevo (Lista de recomendaciones explícita)
    test('fromJson parsea correctamente el formato nuevo con lista de recomendaciones', () {
      final json = {
        'refugee_info': {
          'name': 'Aiman',
          'age': 25,
          'nationality': 'Spanish',
          'family_size': 1,
          'gender': 'Male'
        },
        'cluster_id': 1,
        'cluster_label': 'High Priority',
        'vulnerability_level': 'high',
        'recommendations': [
          {
            'shelter_id': 101,
            'shelter_name': 'Refugio Centro',
            'compatibility_score': 95.5,
            'explanation': 'Buen match'
          },
          {
            'shelter_id': 102,
            'shelter_name': 'Refugio Norte',
            'compatibility_score': 80.0
          }
        ]
      };

      final response = RecommendationResponse.fromJson(json);

      expect(response.refugeeName, 'Aiman');
      expect(response.clusterLabel, 'High Priority');
      expect(response.recommendations.length, 2);
      expect(response.recommendations.first.shelterName, 'Refugio Centro');
    });

    // CASO 2: Formato Node-RED (Assignment + Alternatives dentro)
    test('fromJson parsea formato Node-RED (assignment + alternative_shelters)', () {
      final json = {
        'refugee': {'first_name': 'Maria', 'age': 30}, // Usa 'refugee' y 'first_name'
        'assignment': {
          'shelter_id': 200,
          'shelter_name': 'Refugio Principal',
          'compatibility_score': 90.0,
          'alternative_shelters': [
            {'shelter_id': 201, 'shelter_name': 'Alternativa 1'}
          ]
        }
      };

      final response = RecommendationResponse.fromJson(json);

      expect(response.refugeeName, 'Maria');
      // Debe haber 2: 1 del assignment principal + 1 de alternativas
      expect(response.recommendations.length, 2); 
      expect(response.recommendations[0].shelterName, 'Refugio Principal');
      expect(response.recommendations[1].shelterName, 'Alternativa 1');
    });

    // CASO 3: Formato Node-RED (Alternatives en la raíz)
    test('fromJson parsea alternatives en la raíz del JSON', () {
      final json = {
        'assignment': {'shelter_id': 300, 'shelter_name': 'Main'},
        'alternative_shelters': [ // <-- En la raíz
          {'shelter_id': 301, 'shelter_name': 'Root Alt'}
        ]
      };

      final response = RecommendationResponse.fromJson(json);

      expect(response.recommendations.length, 2);
      expect(response.recommendations[1].shelterName, 'Root Alt');
    });

    // CASO 4: Valores por defecto y nulos
    test('Maneja valores nulos y aplica defaults correctamente', () {
      final json = <String, dynamic>{}; // JSON vacío

      final response = RecommendationResponse.fromJson(json);

      expect(response.refugeeName, 'Unknown');
      expect(response.refugeeAge, 0);
      expect(response.recommendations, isEmpty);
      expect(response.mlModelVersion, '1.0');
    });
  });

  group('Recommendation Model Logic Tests', () {
    
    // CASO 5: Conversión de Tipos (_parseInt y _parseDouble)
    // Probamos que el modelo sea robusto si la API devuelve Strings en vez de Números
    test('Parsea tipos mixtos (String/Int/Double) correctamente', () {
      final json = {
        'shelter_id': '500',          // String numérico
        'max_capacity': 50.0,         // Double donde espera int
        'compatibility_score': '88.5',// String double
        'priority_score': 10,         // Int donde espera double
        'has_medical_facilities': 'true', // String boolean
        'has_childcare': true,        // Boolean real
        'explanation': null,
        'matching_reasons': ['Reason 1', 123] // Lista mixta
      };

      final rec = Recommendation.fromJson(json);

      expect(rec.shelterId, 500); // String -> Int
      expect(rec.maxCapacity, 50); // Double -> Int
      expect(rec.compatibilityScore, 88.5); // String -> Double
      expect(rec.priorityScore, 10.0); // Int -> Double
      expect(rec.hasMedicalFacilities, true); // String 'true' -> true
      expect(rec.hasChildcare, true); // Boolean true -> true
      expect(rec.explanation, 'Refugio recomendado'); // Default
      expect(rec.matchingReasons.length, 2);
      expect(rec.matchingReasons.last, '123'); // Convertido a string
    });
    
    // CASO 6: Helper _parseInt y _parseDouble con nulls
    test('Maneja nulls en campos numéricos devolviendo 0', () {
      final json = {
        'shelter_id': null,
        'compatibility_score': null,
      };
      
      final rec = Recommendation.fromJson(json);
      
      expect(rec.shelterId, 0);
      expect(rec.compatibilityScore, 0.0);
    });
  });
}