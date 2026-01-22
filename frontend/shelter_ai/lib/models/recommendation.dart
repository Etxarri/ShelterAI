class Recommendation {
  final int shelterId;
  final String shelterName;
  final String address;
  final double compatibilityScore;
  final int availableSpace;
  final bool hasMedicalFacilities;
  final bool hasDisabilityAccess;
  final String explanation;
  final List<String> matchingReasons;

  Recommendation({
    required this.shelterId,
    required this.shelterName,
    required this.address,
    required this.compatibilityScore,
    required this.availableSpace,
    required this.hasMedicalFacilities,
    required this.hasDisabilityAccess,
    required this.explanation,
    required this.matchingReasons,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    var reasons = <String>[];
    if (json['matching_reasons'] != null) {
      reasons = (json['matching_reasons'] as List)
          .map((r) => r.toString())
          .toList();
    }

    return Recommendation(
      shelterId: _parseInt(json['shelter_id']) ?? 0,
      shelterName: json['shelter_name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      compatibilityScore: _parseDouble(json['compatibility_score']) ?? 0.0,
      availableSpace: _parseInt(json['available_space']) ?? 0,
      hasMedicalFacilities: json['has_medical_facilities'] == true || json['has_medical_facilities'] == 'true',
      hasDisabilityAccess: json['has_disability_access'] == true || json['has_disability_access'] == 'true',
      explanation: json['explanation']?.toString() ?? 'Refugio recomendado',
      matchingReasons: reasons,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

