import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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
        pageFormat: pw.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              'ShelterAI - Código QR',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 24),
            pw.Container(
              color: pw.PdfColors.white,
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
              'Guárdalo en tu móvil y muéstralo al llegar al centro.',
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
            title: const Text('Tu código QR'),
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
                    'Guárdalo y muéstralo al trabajador para evitar colas.',
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
                                content: Text('No se pudo descargar el PDF: $e'),
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
                        : const Text('Descargar PDF'),
              ),
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cerrar'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro del Refugiado'),
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
              TextFormField(
                controller: _firstNameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator:
                    (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastNameCtrl,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator:
                    (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
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
                  DropdownMenuItem(
                    value: 'Masculino',
                    child: Text('Masculino'),
                  ),
                  DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                  DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'Masculino'),
                decoration: const InputDecoration(labelText: 'Género'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nationalityCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nacionalidad (opcional)',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _languagesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Idiomas (separados por comas)',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _medicalCtrl,
                decoration: const InputDecoration(
                  labelText: 'Condiciones médicas (opcional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Tiene discapacidad'),
                value: _hasDisability,
                onChanged: (v) => setState(() => _hasDisability = v),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _specialNeedsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Necesidades especiales (opcional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _familyIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'ID de familia (opcional)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _generateQr,
                icon: const Icon(Icons.qr_code),
                label: const Text('Generar QR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
