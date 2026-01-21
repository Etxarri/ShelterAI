import 'package:flutter/material.dart';
import 'package:shelter_ai/utils/refugee_constants.dart';
import 'package:shelter_ai/widgets/refugee_form_widgets.dart';

/// Container for all form controllers used in refugee forms
class RefugeeFormControllers {
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController ageCtrl;
  final TextEditingController familyIdCtrl;
  final TextEditingController phoneNumberCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController addressCtrl;

  RefugeeFormControllers({
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.ageCtrl,
    required this.familyIdCtrl,
    required this.phoneNumberCtrl,
    required this.emailCtrl,
    required this.addressCtrl,
  });

  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    ageCtrl.dispose();
    familyIdCtrl.dispose();
    phoneNumberCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
  }
}

/// Data class for refugee form state
class RefugeeFormData {
  String gender;
  String? nationality;
  List<String> languages;
  String? medicalCondition;
  bool hasDisability;
  List<String> specialNeeds;

  RefugeeFormData({
    this.gender = 'Male',
    this.nationality,
    this.languages = const [],
    this.medicalCondition,
    this.hasDisability = false,
    this.specialNeeds = const [],
  });
}

/// Reusable refugee form fields widget
class RefugeeFormFields extends StatelessWidget {
  final RefugeeFormControllers controllers;
  final RefugeeFormData data;
  final ValueChanged<RefugeeFormData> onDataChanged;
  final String? instructionText;
  final bool showFamilyInfo;

  const RefugeeFormFields({
    super.key,
    required this.controllers,
    required this.data,
    required this.onDataChanged,
    this.instructionText,
    this.showFamilyInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (instructionText != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              instructionText!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 18),
        ],
        const RefugeeSectionHeader(title: 'Basic Data'),
        const SizedBox(height: 10),
        TextFormField(
          controller: controllers.firstNameCtrl,
          decoration: const InputDecoration(labelText: 'First Name'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controllers.lastNameCtrl,
          decoration: const InputDecoration(labelText: 'Last Name'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controllers.ageCtrl,
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
          value: data.gender,
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: (v) => onDataChanged(RefugeeFormData(
            gender: v ?? 'Male',
            nationality: data.nationality,
            languages: data.languages,
            medicalCondition: data.medicalCondition,
            hasDisability: data.hasDisability,
            specialNeeds: data.specialNeeds,
          )),
          decoration: const InputDecoration(labelText: 'Gender'),
        ),
        const SizedBox(height: 18),
        const RefugeeSectionHeader(title: 'Language and nationality'),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: data.nationality,
          items: RefugeeConstants.nationalities
              .map((n) => DropdownMenuItem(value: n, child: Text(n)))
              .toList(),
          onChanged: (v) => onDataChanged(RefugeeFormData(
            gender: data.gender,
            nationality: v,
            languages: data.languages,
            medicalCondition: data.medicalCondition,
            hasDisability: data.hasDisability,
            specialNeeds: data.specialNeeds,
          )),
          decoration: const InputDecoration(
            labelText: 'Nationality (optional)',
          ),
        ),
        const SizedBox(height: 10),
        RefugeeMultiSelectDropdown(
          title: 'Languages (optional)',
          items: RefugeeConstants.languages,
          selectedItems: data.languages,
          onChanged: (selected) => onDataChanged(RefugeeFormData(
            gender: data.gender,
            nationality: data.nationality,
            languages: selected,
            medicalCondition: data.medicalCondition,
            hasDisability: data.hasDisability,
            specialNeeds: data.specialNeeds,
          )),
        ),
        const SizedBox(height: 18),
        const RefugeeSectionHeader(title: 'Contact'),
        const SizedBox(height: 10),
        TextFormField(
          controller: controllers.phoneNumberCtrl,
          decoration: const InputDecoration(
            labelText: 'Phone number (optional)',
            helperText: 'E.g: +34 123456789',
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controllers.emailCtrl,
          decoration: const InputDecoration(
            labelText: 'Email (optional)',
            helperText: 'E.g: usuario@gmail.com',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controllers.addressCtrl,
          decoration: const InputDecoration(
            labelText: 'Address (optional)',
            helperText: 'Current address or shelter area',
          ),
        ),
        const SizedBox(height: 18),
        const RefugeeSectionHeader(title: 'Care and companions'),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: data.medicalCondition,
          items: RefugeeConstants.medicalConditions
              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
              .toList(),
          onChanged: (v) => onDataChanged(RefugeeFormData(
            gender: data.gender,
            nationality: data.nationality,
            languages: data.languages,
            medicalCondition: v,
            hasDisability: data.hasDisability,
            specialNeeds: data.specialNeeds,
          )),
          decoration: const InputDecoration(
            labelText: 'Medical conditions (optional)',
          ),
        ),
        SwitchListTile(
          title: const Text('Has disability or reduced mobility'),
          value: data.hasDisability,
          onChanged: (v) => onDataChanged(RefugeeFormData(
            gender: data.gender,
            nationality: data.nationality,
            languages: data.languages,
            medicalCondition: data.medicalCondition,
            hasDisability: v,
            specialNeeds: data.specialNeeds,
          )),
        ),
        const SizedBox(height: 10),
        RefugeeMultiSelectDropdown(
          title: 'Special needs (optional)',
          items: RefugeeConstants.specialNeedsList,
          selectedItems: data.specialNeeds,
          onChanged: (selected) => onDataChanged(RefugeeFormData(
            gender: data.gender,
            nationality: data.nationality,
            languages: data.languages,
            medicalCondition: data.medicalCondition,
            hasDisability: data.hasDisability,
            specialNeeds: selected,
          )),
        ),
        if (showFamilyInfo) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controllers.familyIdCtrl,
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
                onPressed: () => FamilyIdInfoModal.show(context),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
