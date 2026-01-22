import 'package:flutter_test/flutter_test.dart';
import 'package:shelter_ai/models/recommendation.dart'; 
import 'package:shelter_ai/models/recommendation_response.dart'; 

void main() {
  group('RecommendationResponse Tests', () {
    
    test('fromJson parsea correctamente el formato nuevo', () {
      final json = {
        'refugee_name': 'Carlos Pérez',
        'cluster_id': 5,
        'cluster_label': 'Estándar',
        'vulnerability_level': 'Standard',
        'message': 'Refugios encontrados',
        'recommendations': [
          {
            'shelter_id': 1,
            'shelter_name': 'Refugio Central Madrid',
            'address': 'Calle Atocha 12',
            'compatibility_score': 95,
            'available_space': 50,
            'has_medical_facilities': false,
            'has_disability_access': false,
            'explanation': 'Asignación por disponibilidad general',
            'matching_reasons': ['✓ Refugio general con disponibilidad']
          },
          {
            'shelter_id': 2,
            'shelter_name': 'Centro Sanitario Cruz Roja',
            'address': 'Av. Reina Victoria 45',
            'compatibility_score': 95,
            'available_space': 10,
            'has_medical_facilities': true,
            'has_disability_access': true,
            'explanation': 'Asignación por disponibilidad general',
            'matching_reasons': ['✓ Cuenta con instalaciones médicas', '✓ Tiene accesibilidad para personas con discapacidad']
          }
        ]
      };

      final response = RecommendationResponse.fromJson(json);

      expect(response.refugeeName, 'Carlos Pérez');
      expect(response.clusterId, 5);
      expect(response.clusterLabel, 'Estándar');
      expect(response.vulnerabilityLevel, 'Standard');
      expect(response.message, 'Refugios encontrados');
      expect(response.recommendations.length, 2);
      expect(response.recommendations.first.shelterName, 'Refugio Central Madrid');
      expect(response.recommendations.first.compatibilityScore, 95);
      expect(response.recommendations.first.matchingReasons.length, 1);
      expect(response.recommendations[1].matchingReasons.length, 2);
    });

    test('Maneja valores nulos y aplica defaults correctamente', () {
      final json = <String, dynamic>{}; // JSON vacío

      final response = RecommendationResponse.fromJson(json);

      expect(response.refugeeName, 'Unknown');
      expect(response.clusterId, 0);
      expect(response.clusterLabel, 'Unknown');
      expect(response.vulnerabilityLevel, 'Standard');
      expect(response.message, 'Refugios encontrados');
      expect(response.recommendations, isEmpty);
    });

    test('Parsea recomendaciones con diferentes compatibilityScores', () {
      final json = {
        'refugee_name': 'Test User',
        'cluster_id': 1,
        'cluster_label': 'Test',
        'vulnerability_level': 'High',
        'recommendations': [
          {
            'shelter_id': 100,
            'shelter_name': 'Shelter A',
            'address': 'Address A',
            'compatibility_score': '92.5', // String
            'available_space': 30,
            'has_medical_facilities': 'true', // String
            'has_disability_access': false,
            'explanation': 'Good match'
          }
        ]
      };

      final response = RecommendationResponse.fromJson(json);
      final rec = response.recommendations.first;

      expect(rec.shelterId, 100);
      expect(rec.compatibilityScore, 92.5); // Convertido de String
      expect(rec.hasMedicalFacilities, true); // Convertido de String
      expect(rec.availableSpace, 30);
    });
  });

  group('Recommendation Model Tests', () {
    
    test('fromJson parsea correctamente los campos simplificados', () {
      final json = {
        'shelter_id': '101',
        'shelter_name': 'Test Shelter',
        'address': 'Test Address',
        'compatibility_score': '85.5',
        'available_space': 45,
        'has_medical_facilities': true,
        'has_disability_access': false,
        'explanation': 'Perfect match',
        'matching_reasons': ['Reason 1', 'Reason 2']
      };

      final rec = Recommendation.fromJson(json);

      expect(rec.shelterId, 101);
      expect(rec.shelterName, 'Test Shelter');
      expect(rec.address, 'Test Address');
      expect(rec.compatibilityScore, 85.5);
      expect(rec.availableSpace, 45);
      expect(rec.hasMedicalFacilities, true);
      expect(rec.hasDisabilityAccess, false);
      expect(rec.explanation, 'Perfect match');
      expect(rec.matchingReasons.length, 2);
      expect(rec.matchingReasons.first, 'Reason 1');
    });
    
    test('Maneja valores nulos con defaults', () {
      final json = {
        'shelter_id': null,
        'shelter_name': null,
        'address': null,
        'compatibility_score': null,
        'available_space': null,
        'has_medical_facilities': null,
        'has_disability_access': null,
        'explanation': null,
        'matching_reasons': null,
      };
      
      final rec = Recommendation.fromJson(json);
      
      expect(rec.shelterId, 0);
      expect(rec.shelterName, '');
      expect(rec.address, '');
      expect(rec.compatibilityScore, 0.0);
      expect(rec.availableSpace, 0);
      expect(rec.hasMedicalFacilities, false);
      expect(rec.hasDisabilityAccess, false);
      expect(rec.explanation, 'Refugio recomendado');
      expect(rec.matchingReasons, isEmpty);
    });
  });
}