class Recommendation {
  final int shelterId;
  final String shelterName;
  final String address;
  final double compatibilityScore;
  final double priorityScore;
  final int maxCapacity;
  final int currentOccupancy;
  final int availableSpace;
  final double occupancyRate;
  final bool hasMedicalFacilities;
  final bool hasChildcare;
  final bool hasDisabilityAccess;
  final String? languagesSpoken;
  final String? shelterType;
  final String? servicesOffered;
  final String explanation;
  final List<String> matchingReasons;

  Recommendation({
    required this.shelterId,
    required this.shelterName,
    required this.address,
    required this.compatibilityScore,
    required this.priorityScore,
    required this.maxCapacity,
    required this.currentOccupancy,
    required this.availableSpace,
    required this.occupancyRate,
    required this.hasMedicalFacilities,
    required this.hasChildcare,
    required this.hasDisabilityAccess,
    this.languagesSpoken,
    this.shelterType,
    this.servicesOffered,
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
      priorityScore: _parseDouble(json['priority_score']) ?? 0.0,
      maxCapacity: _parseInt(json['max_capacity']) ?? _parseInt(json['max_capacity']) ?? 0,
      currentOccupancy: _parseInt(json['current_occupancy']) ?? 0,
      availableSpace: _parseInt(json['available_space']) ?? 0,
      occupancyRate: _parseDouble(json['occupancy_rate']) ?? 0.0,
      hasMedicalFacilities: json['has_medical_facilities'] == true || json['has_medical_facilities'] == 'true',
      hasChildcare: json['has_childcare'] == true || json['has_childcare'] == 'true',
      hasDisabilityAccess: json['has_disability_access'] == true || json['has_disability_access'] == 'true',
      languagesSpoken: json['languages_spoken']?.toString(),
      shelterType: json['shelter_type']?.toString(),
      servicesOffered: json['services_offered']?.toString(),
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
