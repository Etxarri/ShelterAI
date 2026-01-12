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
      nationality:
          _nationalityCtrl.text.trim().isEmpty
              ? null
              : _nationalityCtrl.text.trim(),
      languagesSpoken:
          _languagesCtrl.text.trim().isEmpty
              ? null
              : _languagesCtrl.text.trim(),
      medicalConditions:
          _medicalCtrl.text.trim().isEmpty ? null : _medicalCtrl.text.trim(),
      hasDisability: _hasDisability,
      vulnerabilityScore:
          double.tryParse(_vulnerabilityCtrl.text.trim()) ?? 0.0,
      specialNeeds:
          _specialNeedsCtrl.text.trim().isEmpty
              ? null
              : _specialNeedsCtrl.text.trim(),
      familyId:
          _familyIdCtrl.text.trim().isEmpty
              ? null
              : int.tryParse(_familyIdCtrl.text.trim()),
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
              TextFormField(
                controller: _nationalityCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nationality (optional)',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _languagesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Languages (comma separated)',
                  helperText: 'E.g: Spanish, English',
                ),
              ),
              const SizedBox(height: 18),
              const _SectionHeader(title: 'Care and companions'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _medicalCtrl,
                decoration: const InputDecoration(
                  labelText: 'Medical conditions (optional)',
                  hintText: 'Medications, allergies, pregnancy, etc.',
                ),
                maxLines: 2,
              ),
              SwitchListTile(
                title: const Text('I have a disability or reduced mobility'),
                value: _hasDisability,
                onChanged: (v) => setState(() => _hasDisability = v),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _specialNeedsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Special needs (optional)',
                  hintText: 'Psychological support, family space, privacy',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _familyIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'Family ID (if you have one)',
                ),
                keyboardType: TextInputType.number,
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
