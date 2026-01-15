import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shelter_ai/models/refugee.dart';
import 'package:shelter_ai/providers/auth_state.dart';

class RefugeeSelfFormQrScreen extends StatefulWidget {
  const RefugeeSelfFormQrScreen({super.key});

  @override
  State<RefugeeSelfFormQrScreen> createState() =>
      _RefugeeSelfFormQrScreenState();
}

class _RefugeeSelfFormQrScreenState extends State<RefugeeSelfFormQrScreen> {
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

  // Predefined lists
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  /// Carga los datos del usuario registrado en los campos del formulario
  void _loadUserData() {
    final auth = AuthScope.of(context);
    
    if (auth.firstName.isNotEmpty) {
      _firstNameCtrl.text = auth.firstName;
    }
    if (auth.lastName.isNotEmpty) {
      _lastNameCtrl.text = auth.lastName;
    }
    if (auth.age != null && auth.age! > 0) {
      _ageCtrl.text = auth.age.toString();
    }
    if (auth.gender.isNotEmpty) {
      _gender = auth.gender;
    }
    if (auth.nationality != null && auth.nationality!.isNotEmpty) {
      _nationality = auth.nationality;
    }
    if (auth.email != null && auth.email!.isNotEmpty) {
      _emailCtrl.text = auth.email!;
    }
    if (auth.phoneNumber != null && auth.phoneNumber!.isNotEmpty) {
      _phoneNumberCtrl.text = auth.phoneNumber!;
    }
    if (auth.address != null && auth.address!.isNotEmpty) {
      _addressCtrl.text = auth.address!;
    }
  }

  Future<Uint8List> _buildQrImageBytes(String data) async {
    final painter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: false, // deja un "quiet zone" más seguro
      color: Colors.black,
      emptyColor: Colors.white,
    );

    // Genera una imagen grande para evitar artefactos al incrustar en PDF
    final imageData = await painter.toImageData(1024, format: ui.ImageByteFormat.png);
    if (imageData == null) {
      throw Exception('No se pudo generar la imagen del QR');
    }

    return imageData.buffer.asUint8List();
  }

  Future<Uint8List> _buildQrPdf(String data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              'ShelterAI - QR Code',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 24),
            pw.Container(
              color: PdfColors.white,
              padding: const pw.EdgeInsets.all(24),
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: data,
                width: 360,
                height: 360,
                drawText: false,
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Save it on your phone and show it upon arrival at the center.',
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  Future<void> _downloadQrPdf(String data) async {
    final pdfBytes = await _buildQrPdf(data);
    await Printing.sharePdf(bytes: pdfBytes, filename: 'shelterai_qr.pdf');
  }

  void _generateQr() {
    if (!_formKey.currentState!.validate()) return;

    final refugee = Refugee(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
      gender: _gender,
      nationality: _nationality,
      languagesSpoken: _languages.isNotEmpty ? _languages.join(', ') : null,
      medicalConditions: _medicalCondition,
      hasDisability: _hasDisability,
      vulnerabilityScore: 0.0,
      specialNeeds: _specialNeeds.isNotEmpty ? _specialNeeds.join(', ') : null,
      familyId:
          _familyIdCtrl.text.trim().isEmpty
              ? null
              : int.tryParse(_familyIdCtrl.text.trim()),
      phoneNumber:
          _phoneNumberCtrl.text.trim().isEmpty
              ? null
              : _phoneNumberCtrl.text.trim(),
      email:
          _emailCtrl.text.trim().isEmpty
              ? null
              : _emailCtrl.text.trim(),
      address:
          _addressCtrl.text.trim().isEmpty
              ? null
              : _addressCtrl.text.trim(),
    );

    final jsonString = jsonEncode(refugee.toJson());

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Your QR Code'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 220.0,
                    height: 220.0,
                    child: QrImageView(
                      data: jsonString,
                      version: QrVersions.auto,
                      size: 220.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Save it and show it to the worker to avoid queues.',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        setDialogState(() => isSaving = true);
                        try {
                          await _downloadQrPdf(jsonString);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Could not download PDF: $e'),
                              ),
                            );
                          }
                        } finally {
                          setDialogState(() => isSaving = false);
                        }
                      },
                child:
                    isSaving
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Download PDF'),
              ),
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
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
                  'A Family ID is a unique identifier that connects family members in the shelter system. If you arrive with family members, you should use the same Family ID to ensure you stay together.',
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
                text: 'If this is your first time registering: Leave this field empty.',
              ),
              const SizedBox(height: 8),
              const _InfoBullet(
                number: '2',
                text: 'If a family member already registered: Ask them for their Family ID (they can see it in their QR code).',
              ),
              const SizedBox(height: 8),
              const _InfoBullet(
                number: '3',
                text: 'Enter their Family ID in this field to link yourselves.',
              ),
              const SizedBox(height: 8),
              const _InfoBullet(
                number: '4',
                text: 'If you register together for the first time, you can leave it empty and request family linking at arrival.',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade600, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber, size: 20, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Using the correct Family ID ensures your family stays together and receives appropriate accommodation.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF664D00)),
                      ),
                    ),
                  ],
                ),
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

  void _logout() {
    AuthScope.of(context).logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick registration'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
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
                  color: color.primaryContainer.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'We only ask for what is necessary to locate you safely. You can come back later; your QR will keep working.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 18),
              const _SectionHeader(title: 'Your basic data'),
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
                  DropdownMenuItem(
                    value: 'Male',
                    child: Text('Male'),
                  ),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              const SizedBox(height: 18),
              const _SectionHeader(title: 'Language and nationality'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _nationality,
                items: nationalities.map((n) {
                  return DropdownMenuItem(value: n, child: Text(n));
                }).toList(),
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
                onChanged: (selected) =>
                    setState(() => _languages = selected),
              ),
              const SizedBox(height: 18),
              const _SectionHeader(title: 'Contact information'),
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
                  helperText: 'E.g: your@email.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Address (optional)',
                  helperText: 'Your current address',
                ),
              ),
              const SizedBox(height: 18),
              const _SectionHeader(title: 'Care and companions'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _medicalCondition,
                items: medicalConditions.map((m) {
                  return DropdownMenuItem(value: m, child: Text(m));
                }).toList(),
                onChanged: (v) => setState(() => _medicalCondition = v),
                decoration: const InputDecoration(
                  labelText: 'Medical conditions (optional)',
                ),
              ),
              SwitchListTile(
                title: const Text('I have a disability or reduced mobility'),
                value: _hasDisability,
                onChanged: (v) => setState(() => _hasDisability = v),
              ),
              const SizedBox(height: 10),
              _MultiSelectDropdown(
                title: 'Special needs (optional)',
                items: specialNeedsList,
                selectedItems: _specialNeeds,
                onChanged: (selected) =>
                    setState(() => _specialNeeds = selected),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _familyIdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Family ID (if you have one)',
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
                onPressed: _generateQr,
                icon: const Icon(Icons.qr_code),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                label: const Text('Generate and save my QR'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Show it upon arrival. If you need urgent help, notify reception.',
                textAlign: TextAlign.center,
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
