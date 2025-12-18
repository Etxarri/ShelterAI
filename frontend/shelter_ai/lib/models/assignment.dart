import 'package:flutter/material.dart';

class Assignment {
  final int id;
  final int shelterId;
  final String shelterName;
  final double priorityScore;
  final double confidenceScore;
  final String explanation;
  final String status;
  final DateTime assignedAt;
  final List<AlternativeShelter> alternativeShelters;

  Assignment({
    required this.id,
    required this.shelterId,
    required this.shelterName,
    required this.priorityScore,
    required this.confidenceScore,
    required this.explanation,
    required this.status,
    required this.assignedAt,
    this.alternativeShelters = const [],
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    var alternatives = <AlternativeShelter>[];
    if (json['alternative_shelters'] != null) {
      alternatives = (json['alternative_shelters'] as List)
          .map((alt) => AlternativeShelter.fromJson(alt))
          .toList();
    }

    return Assignment(
      id: _parseInt(json['id']) ?? 0,
      shelterId: _parseInt(json['shelter_id']) ?? 0,
      shelterName: json['shelter_name']?.toString() ?? '',
      priorityScore: _parseDouble(json['priority_score']) ?? 0.0,
      confidenceScore: _parseDouble(json['confidence_score']) ?? 0.0,
      explanation: json['explanation']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      assignedAt: json['assigned_at'] != null 
          ? DateTime.parse(json['assigned_at'].toString())
          : DateTime.now(),
      alternativeShelters: alternatives,
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

  String get priorityLevel {
    if (priorityScore >= 70) return 'Alta Prioridad';
    if (priorityScore >= 40) return 'Prioridad Media';
    return 'Prioridad Estándar';
  }

  Color get priorityColor {
    if (priorityScore >= 70) return Colors.red;
    if (priorityScore >= 40) return Colors.orange;
    return Colors.green;
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmado';
      case 'completed':
        return 'Completado';
      default:
        return status;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  double get confidencePercentage => confidenceScore * 100;
}

class AlternativeShelter {
  final int shelterId;
  final String shelterName;
  final double confidenceScore;

  AlternativeShelter({
    required this.shelterId,
    required this.shelterName,
    required this.confidenceScore,
  });

  factory AlternativeShelter.fromJson(Map<String, dynamic> json) {
    return AlternativeShelter(
      shelterId: _parseInt(json['shelter_id']) ?? 0,
      shelterName: json['shelter_name']?.toString() ?? '',
      confidenceScore: _parseDouble(json['confidence_score']) ?? 0.0,
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

  double get confidencePercentage => confidenceScore * 100;
}
