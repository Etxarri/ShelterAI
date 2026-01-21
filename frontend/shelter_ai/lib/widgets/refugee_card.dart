import 'package:flutter/material.dart';
import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/models/refugee_assignment_response.dart';
import 'package:shelter_ai/models/recommendation_response.dart';
import 'package:shelter_ai/screens/assignment_detail_screen.dart';
import 'package:shelter_ai/screens/recommendation_selection_screen.dart';
import 'package:shelter_ai/widgets/custom_snackbar.dart';

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
    
    // Check if refugee is assigned
    final isAssigned = data['assigned_shelter_id'] != null && 
                       data['status'] == 'assigned';
    final shelterName = data['shelter_name']?.toString() ?? '';
    final shelterAddress = data['shelter_address']?.toString() ?? '';
    
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
          backgroundColor: isAssigned ? Colors.green : Colors.blue,
          child: Text(
            firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          displayName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isAssigned 
            ? '📍 $shelterName${shelterAddress.isNotEmpty ? ' • $shelterAddress' : ''}'
            : 'Age: $age • Needs: $displayNeeds'
        ),
        trailing: IconButton(
          icon: Icon(
            isAssigned ? Icons.location_on : Icons.analytics_outlined,
            color: isAssigned ? Colors.green : Colors.blue,
          ),
          tooltip: isAssigned ? 'View assignment' : 'Assign shelter',
          onPressed: () => isAssigned 
            ? _viewAssignedShelter(context)
            : _viewAssignment(context),
        ),
      ),
    );
  }

  Future<void> _viewAssignedShelter(BuildContext context) async {
    final refugeeId = data['id'];
    final shelterName = data['shelter_name']?.toString() ?? 'Assigned Shelter';
    final shelterAddress = data['shelter_address']?.toString() ?? '';
    
    if (refugeeId == null) {
      CustomSnackBar.showError(
        context,
        'Cannot view assignment',
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
                Text('Loading details...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Get assignment details
      final assignments = await ApiService.getAssignments(refugeeId.toString());
      
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading
      
      if (assignments.isNotEmpty) {
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
        // Fallback: show simple dialog with shelter info
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.home, color: Colors.green),
                SizedBox(width: 8),
                Expanded(child: Text('Shelter Assigned ')),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shelterName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (shelterAddress.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          shelterAddress,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading
      
      CustomSnackBar.showError(
        context,
        'Error al cargar detalles: $e',
        duration: const Duration(seconds: 7),
      );
    }
  }

  Future<void> _viewAssignment(BuildContext context) async {
    final refugeeId = data['id'];
    
    if (refugeeId == null) {
      CustomSnackBar.showError(
        context,
        'No se puede obtener la asignación',
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
        final recommendationJson = await ApiService.getAIRecommendation(refugeeId.toString());
        
        if (!context.mounted) return;
        Navigator.of(context).pop(); // Close loading
        
        // Debug: Print the JSON response
        print('===== RECOMMENDATION JSON =====');
        print(recommendationJson);
        print('Recommendations count: ${recommendationJson['recommendations']?.length ?? 0}');
        print('===============================');
        
        // Create RecommendationResponse object
        final recommendationResponse = RecommendationResponse.fromJson(recommendationJson);

        print('===== PARSED RESPONSE =====');
        print('Recommendations in object: ${recommendationResponse.recommendations.length}');
        print('===========================');

        // Convert refugeeId to int
        final refugeeIdInt = int.parse(refugeeId.toString());

        // Navigate to the recommendation selection screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RecommendationSelectionScreen(
              recommendationResponse: recommendationResponse,
              refugeeId: refugeeIdInt,
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading
      
      CustomSnackBar.showError(
        context,
        'Error al obtener la asignación: $e',
        duration: const Duration(seconds: 7),
      );
    }
  }
}
