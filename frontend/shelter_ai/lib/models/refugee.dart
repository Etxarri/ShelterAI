class Refugee {
  final int? id;
  final String firstName;
  final String lastName;
  final int age;
  final String? gender;
  final String? nationality;
  final String? languagesSpoken;
  final String? medicalConditions;
  final bool hasDisability;
  final double vulnerabilityScore;
  final String? specialNeeds;
  final int? familyId;
  final String? phoneNumber;
  final String? email;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Refugee({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    this.gender,
    this.nationality,
    this.languagesSpoken,
    this.medicalConditions,
    this.hasDisability = false,
    this.vulnerabilityScore = 0.0,
    this.specialNeeds,
    this.familyId,
    this.phoneNumber,
    this.email,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory Refugee.fromJson(Map<String, dynamic> json) {
    return Refugee(
      id: _parseInt(json['id']),
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      age: _parseInt(json['age']) ?? 0,
      gender: json['gender']?.toString(),
      nationality: json['nationality']?.toString(),
      languagesSpoken: json['languages_spoken']?.toString(),
      medicalConditions: json['medical_conditions']?.toString(),
      hasDisability: json['has_disability'] == true || json['has_disability'] == 'true',
      vulnerabilityScore: _parseDouble(json['vulnerability_score']) ?? 0.0,
      specialNeeds: json['special_needs']?.toString(),
      familyId: _parseInt(json['family_id']),
      phoneNumber: json['phone_number']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString()) 
          : null,
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

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'age': age,
      'gender': gender,
      'nationality': nationality,
      'languages_spoken': languagesSpoken,
      'medical_conditions': medicalConditions,
      'has_disability': hasDisability,
      'vulnerability_score': vulnerabilityScore,
      'special_needs': specialNeeds,
      'family_id': familyId,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
    };
  }

  String get fullName => '$firstName $lastName';
  String get ageDisplay => '$age años';
}
