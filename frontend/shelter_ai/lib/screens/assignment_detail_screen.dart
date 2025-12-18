import 'package:flutter/material.dart';
import 'package:shelter_ai/models/refugee_assignment_response.dart';

class AssignmentDetailScreen extends StatelessWidget {
  final RefugeeAssignmentResponse response;

  const AssignmentDetailScreen({
    super.key,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    final refugee = response.refugee;
    final assignment = response.assignment;

    return Scaffold(
      appBar: AppBar(
        title: Text('Assignment for ${refugee.fullName}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with refugee information
            Container(
              color: Colors.blue.shade50,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Text(
                      refugee.firstName[0].toUpperCase(),
                      style: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    refugee.fullName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${refugee.ageDisplay} • ${refugee.nationality ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            // Assigned shelter
            Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.home, color: Colors.blue, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Assigned Shelter',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          assignment.shelterName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(assignment.statusIcon, 
                               color: assignment.statusColor, 
                               size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Status: ${assignment.statusDisplay}',
                            style: TextStyle(
                              color: assignment.statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Scores
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildScoreCard(
                      context,
                      'Priority',
                      assignment.priorityScore,
                      assignment.priorityLevel,
                      assignment.priorityColor,
                      Icons.priority_high,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildScoreCard(
                      context,
                      'Confidence',
                      assignment.confidencePercentage,
                      '${assignment.confidencePercentage.toStringAsFixed(0)}%',
                      Colors.teal,
                      Icons.speed,
                    ),
                  ),
                ],
              ),
            ),

            // Detailed explanation
            Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Assignment Reason',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Text(
                          assignment.explanation,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Available alternatives
            if (assignment.alternativeShelters.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(16),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.alt_route, color: Colors.purple),
                            SizedBox(width: 8),
                            Text(
                                'Available Alternatives',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        ...assignment.alternativeShelters.map((alt) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.purple.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    alt.shelterName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${alt.confidencePercentage.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),

            // Refugee information
            Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Refugee Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      _buildInfoRow('Languages', refugee.languagesSpoken ?? 'N/A'),
                      if (refugee.medicalConditions != null && refugee.medicalConditions!.isNotEmpty)
                        _buildInfoRow('Medical Conditions', refugee.medicalConditions!),
                      if (refugee.specialNeeds != null && refugee.specialNeeds!.isNotEmpty)
                        _buildInfoRow('Special Needs', refugee.specialNeeds!),
                      _buildInfoRow(
                        'Disability',
                        refugee.hasDisability ? 'Yes' : 'No',
                        icon: refugee.hasDisability ? Icons.accessible : Icons.check_circle,
                        iconColor: refugee.hasDisability ? Colors.orange : Colors.green,
                      ),
                      _buildInfoRow(
                        'Vulnerability Score',
                        '${refugee.vulnerabilityScore.toStringAsFixed(0)}/100',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'Back',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(
    BuildContext context,
    String label,
    double value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon, Color? iconColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: iconColor ?? Colors.grey),
            SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
