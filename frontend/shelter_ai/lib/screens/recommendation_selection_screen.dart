import 'package:flutter/material.dart';
import 'package:shelter_ai/models/recommendation_response.dart';
import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/providers/auth_state.dart';

class RecommendationSelectionScreen extends StatefulWidget {
  final RecommendationResponse recommendationResponse;
  final int refugeeId;

  const RecommendationSelectionScreen({
    super.key,
    required this.recommendationResponse,
    required this.refugeeId,
  });

  @override
  State<RecommendationSelectionScreen> createState() =>
      _RecommendationSelectionScreenState();
}

class _RecommendationSelectionScreenState
    extends State<RecommendationSelectionScreen> {
  int? _selectedShelterId;
  bool _isLoading = false;

  Future<void> _selectShelter(int shelterId) async {
    setState(() {
      _isLoading = true;
      _selectedShelterId = shelterId;
    });

    try {
      final response = await ApiService.selectShelterFromRecommendation(
        widget.refugeeId.toString(),
        shelterId,
      );

      if (!context.mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shelter assigned successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Wait a moment for the user to see the message
      await Future.delayed(const Duration(seconds: 1));

      if (!context.mounted) return;

      // Return to previous screen with successful result
      Navigator.of(context).pop(true);

    } catch (e) {
      if (!context.mounted) return;
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error assigning shelter: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final response = widget.recommendationResponse;
    final recommendations = response.recommendations;
    final refugeeName = response.refugeeName;
    final refugeeAge = response.refugeeAge;
    final refugeeNationality = response.refugeeNationality;
    
    final auth = AuthScope.of(context);
    final isRefugee = auth.role == UserRole.refugee;
    final canSelect = true; // Both refugees and workers can select

    return WillPopScope(
      onWillPop: () async => !_isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Select Shelter for $refugeeName'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with refugee information
              Container(
                color: Colors.blue.shade50,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue,
                      child: Text(
                        refugeeName.isNotEmpty
                            ? refugeeName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      refugeeName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$refugeeAge years • $refugeeNationality',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              // Information banner
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: canSelect ? Colors.blue.shade100 : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: canSelect ? Colors.blue.shade300 : Colors.orange.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue.shade800,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isRefugee
                            ? 'Select the shelter you prefer. We will assign you to your choice.'
                            : 'Select one of these shelters to assign to the refugee.',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Recommendations title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${recommendations.length} Recommended Shelters',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Message if no recommendations
              if (recommendations.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No compatible shelters found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please contact an administrator for assistance.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              // Lista de recomendaciones
              ...recommendations.asMap().entries.map((entry) {
                int index = entry.key;
                final recommendation = entry.value;
                final isSelected = _selectedShelterId == recommendation.shelterId;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: isSelected ? 4 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: (canSelect && !_isLoading)
                          ? () => _selectShelter(recommendation.shelterId)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Número de opción y nombre del refugio
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        recommendation.shelterName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        recommendation.address,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Compatibility score
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Compatibility',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: LinearProgressIndicator(
                                                value: recommendation
                                                        .compatibilityScore /
                                                    100,
                                                minHeight: 6,
                                                backgroundColor:
                                                    Colors.grey.shade300,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  _getScoreColor(recommendation
                                                      .compatibilityScore),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${recommendation.compatibilityScore.toStringAsFixed(1)}%',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: _getScoreColor(
                                                recommendation
                                                    .compatibilityScore,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Capacity and facilities
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoChip(
                                    icon: Icons.group,
                                    label: 'Capacity',
                                    value:
                                        '${recommendation.availableSpace}/${recommendation.maxCapacity}',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildInfoChip(
                                    icon: Icons.medical_services,
                                    label: 'Medical',
                                    value: recommendation.hasMedicalFacilities
                                        ? '✓'
                                        : '✗',
                                    valueColor:
                                        recommendation.hasMedicalFacilities
                                            ? Colors.green
                                            : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildInfoChip(
                                    icon: Icons.child_care,
                                    label: 'Childcare',
                                    value: recommendation.hasChildcare
                                        ? '✓'
                                        : '✗',
                                    valueColor: recommendation.hasChildcare
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Explanation (expandable)
                            ExpansionTile(
                              title: const Text(
                                'Why this shelter is recommended',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              childrenPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              children: [
                                Text(
                                  recommendation.explanation,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                    height: 1.5,
                                  ),
                                ),
                                if (recommendation.matchingReasons
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  ...recommendation.matchingReasons
                                      .map((reason) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.green.shade700,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              reason.replaceFirst('✓ ', ''),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade700,
                                                height: 1.4,
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

                            // Selection button or loading indicator
                            const SizedBox(height: 8),
                            if (canSelect && _selectedShelterId == recommendation.shelterId)
                              Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Colors.green.shade700),
                                          const SizedBox(width: 8),
                                          Text(
                                                'Assigning...',
                                            style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            // Show "best option" indicator for the first shelter
                            if (index == 0)
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Text(
                                    '⭐ Best option',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
