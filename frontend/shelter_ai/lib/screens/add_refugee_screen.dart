import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shelter_ai/models/refugee_assignment_response.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/screens/assignment_detail_screen.dart';
import 'package:shelter_ai/screens/qr_scan_screen.dart';
import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/widgets/custom_snackbar.dart';

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
  String _gender = 'Male';
  String? _nationality;
  List<String> _languages = [];
  String? _medicalCondition;
  bool _hasDisability = false;
  List<String> _specialNeeds = [];
  final TextEditingController _familyIdCtrl = TextEditingController();
  final TextEditingController _phoneNumberCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();

  bool _argsApplied = false;

  // Predefined lists reused from refugee self-registration form
  static const List<String> nationalities = [
    'Afghan',
    'Syrian',
    'Palestinian',
    'Somali',
    'Sudanese',
    'Turkish',
    'Indian',
    'Pakistani',
    'Vietnamese',
    'Congolese',
    'Eritrean',
    'Ethiopian',
    'Iraqi',
    'Iranian',
    'Lebanese',
    'Yemeni',
    'Ukrainian',
    'Venezuelan',
    'Haitian',
    'Other'
  ];

  static const List<String> languages = [
    'Arabic',
    'Spanish',
    'English',
    'French',
    'Chinese',
    'Russian',
    'Hindi',
    'Bengali',
    'Portuguese',
    'German',
    'Japanese',
    'Turkish',
    'Pashto',
    'Kurdish',
    'Dari',
    'Swahili',
    'Vietnamese',
    'Somali',
    'Ukrainian',
    'Other'
  ];

  static const List<String> medicalConditions = [
    'Asthma',
    'Diabetes',
    'Hypertension',
    'Heart disease',
    'Arthritis',
    'Cancer',
    'HIV/AIDS',
    'Tuberculosis',
    'Pregnancy',
    'Mental health condition',
    'Physical disability',
    'Visual impairment',
    'Hearing impairment',
    'Chronic pain',
    'Medication dependent',
    'Allergies',
    'Other'
  ];

  static const List<String> specialNeedsList = [
    'Psychological support',
    'Family space',
    'Privacy',
    'Wheelchair accessibility',
    'Childcare',
    'Medical supervision',
    'Language interpreter',
    'Legal assistance',
    'Educational support',
    'Religious accommodation',
    'Dietary restrictions',
    'Other'
  ];

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _ageCtrl.dispose();
    _familyIdCtrl.dispose();
    _phoneNumberCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // ignore: unused_field
  bool _isLoading = false;

  Future<void> _scanQr() async {
    final auth = AuthScope.of(context);
    if (auth.role != UserRole.worker) {
      CustomSnackBar.showWarning(
        context,
        'Solo los trabajadores pueden escanear códigos QR',
      );
      return;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
    if (result is String) {
      _applyQrData(result);
    }
  }

  void _applyQrData(String data) {
    try {
      final Map<String, dynamic> map = jsonDecode(data) as Map<String, dynamic>;
      _firstNameCtrl.text = (map['first_name'] ?? '').toString();
      _lastNameCtrl.text = (map['last_name'] ?? '').toString();
      _ageCtrl.text = (map['age'] ?? '').toString();
      _gender = (map['gender'] ?? 'Male').toString();
      _nationality = (map['nationality'] ?? '').toString().isEmpty
        ? null
        : (map['nationality'] ?? '').toString();
      final languagesValue = (map['languages_spoken'] ?? '').toString();
      _languages = languagesValue.isEmpty
        ? []
        : languagesValue.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      _emailCtrl.text = (map['email'] ?? '').toString();
      _medicalCondition = (map['medical_conditions'] ?? '').toString().isEmpty
        ? null
        : (map['medical_conditions'] ?? '').toString();
      _hasDisability =
          (map['has_disability'] == true || map['has_disability'] == 'true');
      final specialNeedsValue = (map['special_needs'] ?? '').toString();
      _specialNeeds = specialNeedsValue.isEmpty
        ? []
        : specialNeedsValue.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      _familyIdCtrl.text = (map['family_id'] ?? '').toString();
      _phoneNumberCtrl.text = (map['phone_number'] ?? '').toString();
      _addressCtrl.text = (map['address'] ?? '').toString();
      setState(() {});
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        CustomSnackBar.showSuccess(
          context,
          'Datos cargados desde código QR exitosamente',
        );
      });
    } catch (e) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        CustomSnackBar.showError(
          context,
          'Código QR inválido: $e',
        );
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final Map<String, dynamic> payload = {
      'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(),
      'age': int.tryParse(_ageCtrl.text.trim()) ?? 0,
      'gender': _gender,
      'nationality': _nationality,
      'languages_spoken': _languages.isNotEmpty ? _languages.join(', ') : null,
      'phone_number':
        _phoneNumberCtrl.text.trim().isEmpty
          ? null
          : _phoneNumberCtrl.text.trim(),
      'email': _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      'address':
        _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      'family_id':
          _familyIdCtrl.text.isEmpty
              ? null
              : int.tryParse(_familyIdCtrl.text.trim()),
      'medical_conditions': _medicalCondition,
      'special_needs':
        _specialNeeds.isNotEmpty ? _specialNeeds.join(', ') : null,
      'vulnerability_score': 0,
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
      CustomSnackBar.showError(
        context,
        'Error saving: $e',
        duration: const Duration(seconds: 7),
      );
    }
  }

  void _showSuccessDialog(RefugeeAssignmentResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          Text(
                            'Assigned Shelter:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        response.assignment.shelterName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade800,
                        ),
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
                      builder:
                          (context) =>
                              AssignmentDetailScreen(response: response),
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
      appBar: AppBar(
        title: const Text('Add Refugee'),
        actions: [
          if (AuthScope.of(context).role == UserRole.worker)
            IconButton(
              tooltip: 'Scan QR',
              onPressed: _scanQr,
              icon: const Icon(Icons.qr_code_scanner),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Fill out the form to register and assign the refugee. You can upload data from a QR code if they have one.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 18),
              const _SectionHeader(title: 'Basic Data'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator:
                    (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _lastNameCtrl,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator:
                    (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _gender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              const SizedBox(height: 18),
              const _SectionHeader(title: 'Idioma y nacionalidad'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _nationality,
                items: nationalities
                    .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                    .toList(),
                onChanged: (v) => setState(() => _nationality = v),
                decoration: const InputDecoration(
                  labelText: 'Nationality (optional)',
                ),
              ),
              const SizedBox(height: 10),
              _MultiSelectDropdown(
                title: 'Languages (optional)',
                items: languages,
                selectedItems: _languages,
                onChanged: (selected) => setState(() => _languages = selected),
              ),
              const SizedBox(height: 18),
              const _SectionHeader(title: 'Contacto'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneNumberCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone number (optional)',
                  helperText: 'E.g: +34 123456789',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  helperText: 'E.g: usuario@gmail.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Address (optional)',
                  helperText: 'Current address or shelter area',
                ),
              ),
              const SizedBox(height: 18),
              const _SectionHeader(title: 'Cuidados y acompañantes'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _medicalCondition,
                items: medicalConditions
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _medicalCondition = v),
                decoration: const InputDecoration(
                  labelText: 'Medical conditions (optional)',
                ),
              ),
              SwitchListTile(
                title: const Text('Has disability or reduced mobility'),
                value: _hasDisability,
                onChanged: (v) => setState(() => _hasDisability = v),
              ),
              const SizedBox(height: 10),
              _MultiSelectDropdown(
                title: 'Special needs (optional)',
                items: specialNeedsList,
                selectedItems: _specialNeeds,
                onChanged: (selected) => setState(() => _specialNeeds = selected),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _familyIdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Family ID (if available)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    tooltip: 'What is Family ID?',
                    onPressed: _showFamilyIdInfo,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                label: const Text('Save and assign'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadArgumentsData();
  }

  void _loadArgumentsData() {
    if (_argsApplied) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _applyQrData(jsonEncode(args));
      _argsApplied = true;
    }
  }

  void _showFamilyIdInfo() {
    final color = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.family_restroom, size: 28, color: color.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'What is Family ID?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'A Family ID links relatives in the shelter system. Use the same ID to keep family members together.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'How to get a Family ID:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const _InfoBullet(
                number: '1',
                text: 'If this is the first registration, leave it empty.',
              ),
              const SizedBox(height: 8),
              const _InfoBullet(
                number: '2',
                text: 'If a relative already registered, ask for their Family ID (visible on their QR).',
              ),
              const SizedBox(height: 8),
              const _InfoBullet(
                number: '3',
                text: 'Enter that Family ID to link them.',
              ),
              const SizedBox(height: 8),
              const _InfoBullet(
                number: '4',
                text: 'If registering together for the first time, leave it empty and request linking on arrival.',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}

class _MultiSelectDropdown extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onChanged;

  const _MultiSelectDropdown({
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
  });

  @override
  State<_MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<_MultiSelectDropdown> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: PopupMenuButton<String>(
            itemBuilder: (context) {
              return widget.items.map((item) {
                final isSelected = widget.selectedItems.contains(item);
                return PopupMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (v) {
                          setState(() {
                            if (isSelected) {
                              widget.selectedItems.remove(item);
                            } else {
                              widget.selectedItems.add(item);
                            }
                            widget.onChanged(widget.selectedItems);
                          });
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(child: Text(item)),
                    ],
                  ),
                );
              }).toList();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.selectedItems.isEmpty
                          ? 'Select items...'
                          : '${widget.selectedItems.length} selected',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),
        if (widget.selectedItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 4,
              children: widget.selectedItems
                  .map(
                    (item) => Chip(
                      label: Text(item, style: const TextStyle(fontSize: 12)),
                      onDeleted: () {
                        setState(() {
                          widget.selectedItems.remove(item);
                          widget.onChanged(widget.selectedItems);
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _InfoBullet extends StatelessWidget {
  final String number;
  final String text;

  const _InfoBullet({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
      ],
    );
  }
}
