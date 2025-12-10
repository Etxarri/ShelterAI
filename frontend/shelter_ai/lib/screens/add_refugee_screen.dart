import 'package:flutter/material.dart';
// 👇 ESTA LÍNEA ES LA QUE ARREGLA EL ERROR DE CONEXIÓN
import 'package:shelter_ai/services/api_service.dart';

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
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _medicalCtrl = TextEditingController();
  bool _hasDisability = false;
  final TextEditingController _vulnerabilityCtrl = TextEditingController();
  final TextEditingController _specialNeedsCtrl = TextEditingController();
  final TextEditingController _educationCtrl = TextEditingController();
  final TextEditingController _employmentCtrl = TextEditingController();
  final TextEditingController _familyIdCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _ageCtrl.dispose();
    _nationalityCtrl.dispose();
    _languagesCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _medicalCtrl.dispose();
    _vulnerabilityCtrl.dispose();
    _specialNeedsCtrl.dispose();
    _educationCtrl.dispose();
    _employmentCtrl.dispose();
    _familyIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> payload = {
      'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(),
      'age': int.tryParse(_ageCtrl.text.trim()) ?? 0,
      'gender': _gender,
      'nationality': _nationalityCtrl.text.trim(),
      'languages_spoken': _languagesCtrl.text.trim(),
      'phone_number': _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'medical_conditions': _medicalCtrl.text.trim(),
      'has_disability': _hasDisability,
      'vulnerability_score': double.tryParse(_vulnerabilityCtrl.text.trim()) ?? 0.0,
      'special_needs': _specialNeedsCtrl.text.trim(),
      'education_level': _educationCtrl.text.trim(),
      'employment_status': _employmentCtrl.text.trim(),
      'registration_date': DateTime.now().toIso8601String().split('T')[0],
      'family_id': _familyIdCtrl.text.isEmpty ? null : int.tryParse(_familyIdCtrl.text.trim()),
    };

    try {
      await ApiService.addRefugee(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refugiado guardado')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Refugiado')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastNameCtrl,
                decoration: const InputDecoration(labelText: 'Apellidos'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ageCtrl,
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requerido';
                  final n = int.tryParse(v);
                  if (n == null || n < 0) return 'Edad inválida';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _gender,
                items: const [
                  DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                  DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                  DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'Masculino'),
                decoration: const InputDecoration(labelText: 'Género'),
              ),
              const SizedBox(height: 8),
              TextFormField(controller: _nationalityCtrl, decoration: const InputDecoration(labelText: 'Nacionalidad')),
              const SizedBox(height: 8),
              TextFormField(controller: _languagesCtrl, decoration: const InputDecoration(labelText: 'Idiomas (separados por comas)')),
              const SizedBox(height: 8),
              TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Teléfono'), keyboardType: TextInputType.phone),
              const SizedBox(height: 8),
              TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 8),
              TextFormField(controller: _medicalCtrl, decoration: const InputDecoration(labelText: 'Condiciones médicas'), maxLines: 2),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Tiene discapacidad'),
                value: _hasDisability,
                onChanged: (v) => setState(() => _hasDisability = v),
              ),
              const SizedBox(height: 8),
              TextFormField(controller: _vulnerabilityCtrl, decoration: const InputDecoration(labelText: 'Puntuación de vulnerabilidad'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 8),
              TextFormField(controller: _specialNeedsCtrl, decoration: const InputDecoration(labelText: 'Necesidades especiales'), maxLines: 2),
              const SizedBox(height: 8),
              TextFormField(controller: _educationCtrl, decoration: const InputDecoration(labelText: 'Nivel educativo')),
              const SizedBox(height: 8),
              TextFormField(controller: _employmentCtrl, decoration: const InputDecoration(labelText: 'Estado laboral')),
              const SizedBox(height: 8),
              TextFormField(controller: _familyIdCtrl, decoration: const InputDecoration(labelText: 'ID de familia (opcional)'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _save,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}