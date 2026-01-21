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
import 'package:shelter_ai/widgets/refugee_form_fields.dart';
import 'package:shelter_ai/widgets/common_widgets.dart';

class RefugeeSelfFormQrScreen extends StatefulWidget {
  const RefugeeSelfFormQrScreen({super.key});

  @override
  State<RefugeeSelfFormQrScreen> createState() =>
      _RefugeeSelfFormQrScreenState();
}

class _RefugeeSelfFormQrScreenState extends State<RefugeeSelfFormQrScreen>
    with LogoutMixin {
  final _formKey = GlobalKey<FormState>();

  late final RefugeeFormControllers _controllers;
  late RefugeeFormData _formData;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  /// Carga los datos del usuario registrado en los campos del formulario
  void _loadUserData() {
    final auth = AuthScope.of(context);

    if (auth.firstName.isNotEmpty) {
      _controllers.firstNameCtrl.text = auth.firstName;
    }
    if (auth.lastName.isNotEmpty) {
      _controllers.lastNameCtrl.text = auth.lastName;
    }
    if (auth.age != null && auth.age! > 0) {
      _controllers.ageCtrl.text = auth.age.toString();
    }
    if (auth.email != null && auth.email!.isNotEmpty) {
      _controllers.emailCtrl.text = auth.email!;
    }
    if (auth.phoneNumber != null && auth.phoneNumber!.isNotEmpty) {
      _controllers.phoneNumberCtrl.text = auth.phoneNumber!;
    }
    if (auth.address != null && auth.address!.isNotEmpty) {
      _controllers.addressCtrl.text = auth.address!;
    }

    setState(() {
      _formData = RefugeeFormData(
        gender: auth.gender.isNotEmpty ? auth.gender : 'Male',
        nationality: auth.nationality,
      );
    });
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
    final imageData =
        await painter.toImageData(1024, format: ui.ImageByteFormat.png);
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
      firstName: _controllers.firstNameCtrl.text.trim(),
      lastName: _controllers.lastNameCtrl.text.trim(),
      age: int.tryParse(_controllers.ageCtrl.text.trim()) ?? 0,
      gender: _formData.gender,
      nationality: _formData.nationality,
      languagesSpoken: _formData.languages.isNotEmpty
          ? _formData.languages.join(', ')
          : null,
      medicalConditions: _formData.medicalCondition,
      hasDisability: _formData.hasDisability,
      vulnerabilityScore: 0.0,
      specialNeeds: _formData.specialNeeds.isNotEmpty
          ? _formData.specialNeeds.join(', ')
          : null,
      familyId: _controllers.familyIdCtrl.text.trim().isEmpty
          ? null
          : int.tryParse(_controllers.familyIdCtrl.text.trim()),
      phoneNumber: _controllers.phoneNumberCtrl.text.trim().isEmpty
          ? null
          : _controllers.phoneNumberCtrl.text.trim(),
      email: _controllers.emailCtrl.text.trim().isEmpty
          ? null
          : _controllers.emailCtrl.text.trim(),
      address: _controllers.addressCtrl.text.trim().isEmpty
          ? null
          : _controllers.addressCtrl.text.trim(),
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
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Could not download PDF: $e'),
                              ),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setDialogState(() => isSaving = false);
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Download PDF'),
              ),
              TextButton(
                onPressed: isSaving
                    ? null
                    : () {
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick registration'),
        actions: [
          IconButton(onPressed: logoutRefugee, icon: const Icon(Icons.logout)),
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
                    'We only ask for what is necessary to locate you safely. You can come back later; your QR will keep working.',
                showFamilyInfo: true,
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
