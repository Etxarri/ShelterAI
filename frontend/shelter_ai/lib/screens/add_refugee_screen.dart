import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shelter_ai/models/refugee.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/screens/qr_scan_screen.dart';
import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/widgets/custom_snackbar.dart';
import 'package:shelter_ai/widgets/refugee_form_fields.dart';

class AddRefugeeScreen extends StatefulWidget {
  const AddRefugeeScreen({super.key});

  @override
  State<AddRefugeeScreen> createState() => _AddRefugeeScreenState();
}

class _AddRefugeeScreenState extends State<AddRefugeeScreen> {
  final _formKey = GlobalKey<FormState>();

  late final RefugeeFormControllers _controllers;
  late RefugeeFormData _formData;

  bool _argsApplied = false;

  @override
  void initState() {
    super.initState();
    _controllers = RefugeeFormControllers(
      firstNameCtrl: TextEditingController(),
      lastNameCtrl: TextEditingController(),
      ageCtrl: TextEditingController(),
      familyIdCtrl: TextEditingController(),
      phoneNumberCtrl: TextEditingController(),
      emailCtrl: TextEditingController(),
      addressCtrl: TextEditingController(),
    );
    _formData = RefugeeFormData();
  }

  @override
  void dispose() {
    _controllers.dispose();
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
      _controllers.firstNameCtrl.text = (map['first_name'] ?? '').toString();
      _controllers.lastNameCtrl.text = (map['last_name'] ?? '').toString();
      _controllers.ageCtrl.text = (map['age'] ?? '').toString();

      final gender = (map['gender'] ?? 'Male').toString();
      final nationality = (map['nationality'] ?? '').toString().isEmpty
          ? null
          : (map['nationality'] ?? '').toString();
      final languagesValue = (map['languages_spoken'] ?? '').toString();
      final languages = languagesValue.isEmpty
          ? <String>[]
          : languagesValue
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      _controllers.emailCtrl.text = (map['email'] ?? '').toString();

      final medicalCondition =
          (map['medical_conditions'] ?? '').toString().isEmpty
              ? null
              : (map['medical_conditions'] ?? '').toString();
      final hasDisability =
          (map['has_disability'] == true || map['has_disability'] == 'true');
      final specialNeedsValue = (map['special_needs'] ?? '').toString();
      final specialNeeds = specialNeedsValue.isEmpty
          ? <String>[]
          : specialNeedsValue
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      _controllers.familyIdCtrl.text = (map['family_id'] ?? '').toString();
      _controllers.phoneNumberCtrl.text =
          (map['phone_number'] ?? '').toString();
      _controllers.addressCtrl.text = (map['address'] ?? '').toString();

      setState(() {
        _formData = RefugeeFormData(
          gender: gender,
          nationality: nationality,
          languages: languages,
          medicalCondition: medicalCondition,
          hasDisability: hasDisability,
          specialNeeds: specialNeeds,
        );
      });

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
      'first_name': _controllers.firstNameCtrl.text.trim(),
      'last_name': _controllers.lastNameCtrl.text.trim(),
      'age': int.tryParse(_controllers.ageCtrl.text.trim()) ?? 0,
      'gender': _formData.gender,
      'nationality': _formData.nationality,
      'languages_spoken': _formData.languages.isNotEmpty
          ? _formData.languages.join(', ')
          : null,
      'phone_number': _controllers.phoneNumberCtrl.text.trim().isEmpty
          ? null
          : _controllers.phoneNumberCtrl.text.trim(),
      'email': _controllers.emailCtrl.text.trim().isEmpty
          ? null
          : _controllers.emailCtrl.text.trim(),
      'address': _controllers.addressCtrl.text.trim().isEmpty
          ? null
          : _controllers.addressCtrl.text.trim(),
      'family_id': _controllers.familyIdCtrl.text.isEmpty
          ? null
          : int.tryParse(_controllers.familyIdCtrl.text.trim()),
      'medical_conditions': _formData.medicalCondition,
      'special_needs': _formData.specialNeeds.isNotEmpty
          ? _formData.specialNeeds.join(', ')
          : null,
      'vulnerability_score': 0,
      'has_disability': _formData.hasDisability,
    };

    try {
      // Register refugee (without automatic assignment)
      final response = await ApiService.addRefugeeWithAssignment(payload);

      if (response == null) {
        throw Exception('El servidor no devolvió una respuesta válida.');
      }

      // Extract refugee data from response
      final Map<String, dynamic> refugeeData = response['data'] ?? response;
      final refugee = Refugee.fromJson(refugeeData);

      setState(() => _isLoading = false);

      if (!mounted) return;

      // Show success dialog with registered refugee info
      _showSuccessDialog(refugee);
    } catch (e, stackTrace) {
      print("ERROR DETECTADO: $e");
      print("STACK TRACE: $stackTrace");

      setState(() => _isLoading = false);
      if (!mounted) return;

      CustomSnackBar.showError(
        context,
        'Error al registrar refugiado: $e',
        duration: const Duration(seconds: 7),
      );
    }
  }

  void _showSuccessDialog(Refugee refugee) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Expanded(child: Text('Refugiado Registrado')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${refugee.firstName} ${refugee.lastName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'El refugiado ha sido registrado exitosamente en el sistema.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(true); // Return to list
            },
            child: Text('Aceptar'),
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
              RefugeeFormFields(
                controllers: _controllers,
                data: _formData,
                onDataChanged: (newData) => setState(() => _formData = newData),
                instructionText:
                    'Fill out the form to register and assign the refugee. You can upload data from a QR code if they have one.',
                showFamilyInfo: true,
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
}
