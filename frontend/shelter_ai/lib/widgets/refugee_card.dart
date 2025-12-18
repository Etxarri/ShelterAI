import 'package:flutter/material.dart';
import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/models/refugee_assignment_response.dart';
import 'package:shelter_ai/screens/assignment_detail_screen.dart';

class RefugeeCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const RefugeeCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Build full name
    final firstName = data['first_name'] ?? '';
    final lastName = data['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    final displayName = fullName.isEmpty ? 'No name' : fullName;
    
    // Build needs information
    final age = data['age']?.toString() ?? '-';
    final specialNeeds = data['special_needs'] ?? '';
    final medicalConditions = data['medical_conditions'] ?? '';
    final hasDisability = data['has_disability'] == true ? 'Disability' : '';
    
    // Combine needs
    final needs = [specialNeeds, medicalConditions, hasDisability]
        .where((s) => s.isNotEmpty)
        .join(', ');
    final displayNeeds = needs.isEmpty ? 'None' : needs;
    
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          displayName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Age: $age • Needs: $displayNeeds'),
        trailing: IconButton(
          icon: Icon(Icons.analytics_outlined, color: Colors.blue),
          tooltip: 'View AI Assignment',
          onPressed: () => _viewAssignment(context),
        ),
      ),
    );
  }

  Future<void> _viewAssignment(BuildContext context) async {
    final refugeeId = data['id'];
    
    if (refugeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot get assignment')),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Getting assignment...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Get refugee assignments
      final assignments = await ApiService.getAssignments(refugeeId.toString());
      
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading

      if (assignments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This refugee has no assignment yet'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Take the first assignment (the most recent)
      final assignmentData = assignments.first;
      
      // Create the response object
      final response = RefugeeAssignmentResponse.fromJson({
        'refugee': data,
        'assignment': assignmentData,
      });

      // Navigate to the detail screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AssignmentDetailScreen(response: response),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting assignment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
