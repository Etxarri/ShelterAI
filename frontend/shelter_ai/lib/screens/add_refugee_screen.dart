import 'package:flutter/material.dart';
import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/models/refugee_assignment_response.dart';
import 'package:shelter_ai/screens/assignment_detail_screen.dart';

class AddRefugeeScreen extends StatefulWidget {
  const AddRefugeeScreen({super.key});

  @override
  State<AddRefugeeScreen> createState() => _AddRefugeeScreenState();
}

class _AddRefugeeScreenState extends State<AddRefugeeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _ageCtrl = TextEditingController();
  String _gender = 'Masculino';
  final TextEditingController _nationalityCtrl = TextEditingController();
  final TextEditingController _languagesCtrl = TextEditingController();
  final TextEditingController _medicalCtrl = TextEditingController();
  bool _hasDisability = false;
  final TextEditingController _vulnerabilityCtrl = TextEditingController();
  final TextEditingController _specialNeedsCtrl = TextEditingController();
  final TextEditingController _familyIdCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _ageCtrl.dispose();
    _nationalityCtrl.dispose();
    _languagesCtrl.dispose();
    _medicalCtrl.dispose();
    _vulnerabilityCtrl.dispose();
    _specialNeedsCtrl.dispose();
    _familyIdCtrl.dispose();
    super.dispose();
  }

  // ignore: unused_field
  bool _isLoading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final Map<String, dynamic> payload = {
      'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(),
      'age': int.tryParse(_ageCtrl.text.trim()) ?? 0,
      'gender': _gender,
      'nationality': _nationalityCtrl.text.trim(),
      'languages_spoken': _languagesCtrl.text.trim(),
      'family_id': _familyIdCtrl.text.isEmpty ? null : int.tryParse(_familyIdCtrl.text.trim()),
      'medical_conditions': _medicalCtrl.text.trim().isEmpty ? null : _medicalCtrl.text.trim(),
      'special_needs': _specialNeedsCtrl.text.trim().isEmpty ? null : _specialNeedsCtrl.text.trim(),
      'vulnerability_score': int.tryParse(_vulnerabilityCtrl.text.trim()) ?? 0,
      'has_disability': _hasDisability,
    };

    try {
      // Use the endpoint with automatic assignment
      final response = await ApiService.addRefugeeWithAssignment(payload);
      final assignmentResponse = RefugeeAssignmentResponse.fromJson(response);
      
      setState(() => _isLoading = false);
      
      if (!mounted) return;
      
      // Show result and navigate to detail screen
      _showSuccessDialog(assignmentResponse);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog(RefugeeAssignmentResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Expanded(child: Text('Refugee Registered')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${response.refugee.fullName}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.home, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text('Assigned Shelter:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    response.assignment.shelterName,
                    style: TextStyle(fontSize: 16, color: Colors.blue.shade800),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildScoreCard(
                    'Priority',
                    response.assignment.priorityScore,
                    response.assignment.priorityColor,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildScoreCard(
                    'Confidence',
                    response.assignment.confidencePercentage,
                    Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(true); // Return to list
            },
            child: Text('Close'),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.info_outline),
            label: Text('View Details'),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => AssignmentDetailScreen(
                    response: response,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String label, double value, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(0)}${label == 'Confidence' ? '%' : ''}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Refugee')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastNameCtrl,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ageCtrl,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final n = int.tryParse(v);
                  if (n == null || n < 0) return 'Invalid age';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _gender,
                items: const [
                  DropdownMenuItem(value: 'Masculino', child: Text('Male')),
                  DropdownMenuItem(value: 'Femenino', child: Text('Female')),
                  DropdownMenuItem(value: 'Otro', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'Masculino'),
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              const SizedBox(height: 8),
              TextFormField(controller: _nationalityCtrl, decoration: const InputDecoration(labelText: 'Nationality')),
              const SizedBox(height: 8),
              TextFormField(controller: _languagesCtrl, decoration: const InputDecoration(labelText: 'Languages (comma separated)')),
              const SizedBox(height: 8),
              TextFormField(
                controller: _medicalCtrl,
                decoration: const InputDecoration(labelText: 'Medical Conditions'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Has Disability'),
                value: _hasDisability,
                onChanged: (v) => setState(() => _hasDisability = v),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _vulnerabilityCtrl,
                decoration: const InputDecoration(labelText: 'Vulnerability Score'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextFormField(controller: _specialNeedsCtrl, decoration: const InputDecoration(labelText: 'Special Needs'), maxLines: 2),
              const SizedBox(height: 8),
              TextFormField(
                controller: _familyIdCtrl,
                decoration: const InputDecoration(labelText: 'Family ID (optional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _save,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}