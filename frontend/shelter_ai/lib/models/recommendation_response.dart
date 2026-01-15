import 'recommendation.dart';

class RecommendationResponse {
  final String refugeeName;
  final int refugeeAge;
  final String refugeeNationality;
  final int refugeeFamilySize;
  final String refugeeGender;
  final List<Recommendation> recommendations;
  final int clusterId;
  final String clusterLabel;
  final String vulnerabilityLevel;
  final int totalSheltersAnalyzed;
  final String mlModelVersion;

  RecommendationResponse({
    required this.refugeeName,
    required this.refugeeAge,
    required this.refugeeNationality,
    required this.refugeeFamilySize,
    required this.refugeeGender,
    required this.recommendations,
    required this.clusterId,
    required this.clusterLabel,
    required this.vulnerabilityLevel,
    required this.totalSheltersAnalyzed,
    required this.mlModelVersion,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    var recommendations = <Recommendation>[];
    
    // Check if we have the new format with 'recommendations' key
    if (json['recommendations'] != null) {
      recommendations = (json['recommendations'] as List)
          .map((rec) => Recommendation.fromJson(rec))
          .toList();
    } 
    // Check if we have the Node-RED format with 'assignment' + 'alternative_shelters'
    else if (json['assignment'] != null) {
      final assignment = json['assignment'] as Map<String, dynamic>;
      
      // Add the main assignment as the first recommendation
      recommendations.add(Recommendation(
        shelterId: assignment['shelter_id'] ?? 0,
        shelterName: assignment['shelter_name']?.toString() ?? '',
        address: assignment['address']?.toString() ?? '',
        compatibilityScore: assignment['compatibility_score'] ?? 0.0,
        priorityScore: assignment['priority_score'] ?? 0.0,
        maxCapacity: assignment['max_capacity'] ?? 0,
        currentOccupancy: assignment['current_occupancy'] ?? 0,
        availableSpace: assignment['available_space'] ?? 0,
        occupancyRate: assignment['occupancy_rate'] ?? 0.0,
        hasMedicalFacilities: assignment['has_medical_facilities'] == true || assignment['has_medical_facilities'] == 'true',
        hasChildcare: assignment['has_childcare'] == true || assignment['has_childcare'] == 'true',
        hasDisabilityAccess: assignment['has_disability_access'] == true || assignment['has_disability_access'] == 'true',
        languagesSpoken: assignment['languages_spoken']?.toString(),
        shelterType: assignment['shelter_type']?.toString(),
        servicesOffered: assignment['services_offered']?.toString(),
        explanation: assignment['explanation']?.toString() ?? '',
        matchingReasons: (assignment['matching_reasons'] as List?)
                ?.map((r) => r.toString())
                .toList() ?? [],
      ));
      
      // Add alternatives if they exist (they might be inside assignment)
      if (assignment['alternative_shelters'] != null) {
        recommendations.addAll(
          (assignment['alternative_shelters'] as List)
              .map((alt) => Recommendation.fromJson(alt))
              .toList(),
        );
      }
      // Or check at the root level
      else if (json['alternative_shelters'] != null) {
        recommendations.addAll(
          (json['alternative_shelters'] as List)
              .map((alt) => Recommendation.fromJson(alt))
              .toList(),
        );
      }
    }

    // Parse refugee_info or refugee data
    final refugeeInfo = json['refugee_info'] as Map<String, dynamic>? ?? 
                       json['refugee'] as Map<String, dynamic>? ?? {};

    return RecommendationResponse(
      refugeeName: refugeeInfo['name']?.toString() ?? 
                  refugeeInfo['first_name']?.toString() ?? 'Unknown',
      refugeeAge: refugeeInfo['age'] ?? 0,
      refugeeNationality: refugeeInfo['nationality']?.toString() ?? 'Unknown',
      refugeeFamilySize: refugeeInfo['family_size'] ?? 1,
      refugeeGender: refugeeInfo['gender']?.toString() ?? 'Unknown',
      recommendations: recommendations,
      clusterId: json['cluster_id'] ?? json['assignment']?['cluster_id'] ?? 0,
      clusterLabel: json['cluster_label']?.toString() ?? json['assignment']?['cluster_label']?.toString() ?? 'Unknown',
      vulnerabilityLevel: json['vulnerability_level']?.toString() ?? json['assignment']?['vulnerability_level']?.toString() ?? 'low',
      totalSheltersAnalyzed: json['total_shelters_analyzed'] ?? 0,
      mlModelVersion: json['ml_model_version']?.toString() ?? '1.0',
    );
  }
}
