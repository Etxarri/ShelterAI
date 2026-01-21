import 'recommendation.dart';

class RecommendationResponse {
  final String refugeeName;
  final int clusterId;
  final String clusterLabel;
  final String vulnerabilityLevel;
  final List<Recommendation> recommendations;
  final String message;

  RecommendationResponse({
    required this.refugeeName,
    required this.clusterId,
    required this.clusterLabel,
    required this.vulnerabilityLevel,
    required this.recommendations,
    required this.message,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    var recommendations = <Recommendation>[];
    
    // Parse the new simplified format with 'recommendations' key
    if (json['recommendations'] != null) {
      recommendations = (json['recommendations'] as List)
          .map((rec) => Recommendation.fromJson(rec))
          .toList();
    }

    return RecommendationResponse(
      refugeeName: json['refugee_name']?.toString() ?? 'Unknown',
      clusterId: json['cluster_id'] ?? 0,
      clusterLabel: json['cluster_label']?.toString() ?? 'Unknown',
      vulnerabilityLevel: json['vulnerability_level']?.toString() ?? 'Standard',
      recommendations: recommendations,
      message: json['message']?.toString() ?? 'Refugios encontrados',
    );
  }
}
