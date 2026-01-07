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
                Text('Getting AI recommendation...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // First, check if refugee has existing assignments
      final assignments = await ApiService.getAssignments(refugeeId.toString());
      
      if (!context.mounted) return;
      
      if (assignments.isNotEmpty) {
        // Has existing assignment, show it
        Navigator.of(context).pop(); // Close loading
        
        final assignmentData = assignments.first;
        final response = RefugeeAssignmentResponse.fromJson({
          'refugee': data,
          'assignment': assignmentData,
        });

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AssignmentDetailScreen(response: response),
          ),
        );
      } else {
        // No assignment, get AI recommendation
        final recommendationResponse = await ApiService.getAIRecommendation(refugeeId.toString());
        
        if (!context.mounted) return;
        Navigator.of(context).pop(); // Close loading
        
        // Create response object from recommendation
        final response = RefugeeAssignmentResponse.fromJson(recommendationResponse);

        // Navigate to the detail screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AssignmentDetailScreen(
              response: response,
              isRecommendation: true,  // Flag para indicar que es solo recomendación
            ),
          ),
        );
      }
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
