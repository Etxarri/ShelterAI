import 'refugee.dart';
import 'assignment.dart';

class RefugeeAssignmentResponse {
  final Refugee refugee;
  final Assignment assignment;

  RefugeeAssignmentResponse({
    required this.refugee,
    required this.assignment,
  });

  factory RefugeeAssignmentResponse.fromJson(Map<String, dynamic> json) {
    return RefugeeAssignmentResponse(
      refugee: Refugee.fromJson(json['refugee']),
      assignment: Assignment.fromJson(json['assignment']),
    );
  }
}
