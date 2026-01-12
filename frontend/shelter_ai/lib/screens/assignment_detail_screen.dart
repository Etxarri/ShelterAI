import 'package:flutter/material.dart';
import 'package:shelter_ai/models/refugee_assignment_response.dart';

class AssignmentDetailScreen extends StatelessWidget {
  final RefugeeAssignmentResponse response;
  final bool isRecommendation;

  const AssignmentDetailScreen({
    super.key,
    required this.response,
    this.isRecommendation = false,
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
            // Recommendation banner
            if (isRecommendation)
              Container(
                color: Colors.amber.shade100,
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade900),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This is an AI recommendation. No assignment has been created yet.',
                        style: TextStyle(
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
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

            // Detailed explanation with match details
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              assignment.explanation,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            if (assignment.matchingReasons.isNotEmpty) ...[
                              SizedBox(height: 16),
                              Divider(color: Colors.orange.shade300),
                              SizedBox(height: 12),
                              Text(
                                'Why this shelter?',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                              SizedBox(height: 12),
                              ...assignment.matchingReasons.map((reason) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green.shade700,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          reason.replaceFirst('✓ ', ''),
                                          style: TextStyle(
                                            fontSize: 14,
                                            height: 1.4,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                            if (assignment.matchDetails != null && assignment.matchDetails!.isNotEmpty) ...[
                              SizedBox(height: 16),
                              Divider(color: Colors.orange.shade300),
                              SizedBox(height: 12),
                              Text(
                                'Match Criteria Analysis:',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                              SizedBox(height: 12),
                              ...assignment.matchDetails!.entries.map((entry) {
                                String criteriaName = _formatCriteriaName(entry.key);
                                double score = 0.0;
                                if (entry.value is num) {
                                  score = (entry.value as num).toDouble();
                                }
                                
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            criteriaName,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getScoreColor(score).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: _getScoreColor(score),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              '${score.toStringAsFixed(0)} pts',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: _getScoreColor(score),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: score / 100,
                                          minHeight: 8,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            _getScoreColor(score),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

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

  String _formatCriteriaName(String key) {
    // Mapping of technical names to friendly names in English
    const Map<String, String> criteriaNames = {
      'availability': 'Availability',
      'medical_facilities': 'Medical Facilities',
      'childcare': 'Childcare',
      'disability_access': 'Disability Access',
      'languages': 'Languages',
      'shelter_type': 'Shelter Type',
    };
    
    return criteriaNames[key] ?? key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

    Color _getScoreColor(double score) {
      if (score >= 80) return Colors.green.shade700;
      if (score >= 60) return Colors.lightGreen.shade700;
      if (score >= 40) return Colors.orange.shade700;
      if (score >= 20) return Colors.deepOrange.shade700;
      return Colors.red.shade700;
    }
  }
