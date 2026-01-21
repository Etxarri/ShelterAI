import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({
    super.key,
    this.scannerSupportedOverride,
    this.onScanned,
  });

  /// SOLO para tests: fuerza la rama scanner o fallback.
  /// - null => comportamiento real (android/ios/web soportado, desktop no)
  /// - true => fuerza scanner branch
  /// - false => fuerza fallback branch
  final bool? scannerSupportedOverride;

  /// SOLO para tests / reutilización:
  /// si se pasa, en vez de Navigator.pop devuelve el raw por aquí.
  final ValueChanged<String>? onScanned;

  /// Puro y testeable: NO usa variables globales.
  @visibleForTesting
  static bool isScannerSupportedFor({
    required bool isWeb,
    required TargetPlatform platform,
  }) {
    if (isWeb) return true;
    return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
  }

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  bool _handled = false;

  bool get _isScannerSupported {
    if (widget.scannerSupportedOverride != null) {
      return widget.scannerSupportedOverride!;
    }

    // Soportado en Android/iOS y Web. Evitamos invocar el plugin en desktop.
    return QrScanScreen.isScannerSupportedFor(
      isWeb: kIsWeb,
      platform: defaultTargetPlatform,
    );
  }

  @visibleForTesting
  void handleRaw(String raw) {
    if (_handled) return;
    if (raw.isEmpty) return;

    _handled = true;

    // Para test / reutilización
    if (widget.onScanned != null) {
      widget.onScanned!(raw);
      return;
    }

    // Comportamiento real: devolver resultado a pantalla anterior
    Navigator.pop(context, raw);
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;

    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final raw = barcode?.rawValue;

    if (raw != null && raw.isNotEmpty) {
      handleRaw(raw);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: _isScannerSupported
          ? Stack(
              children: [
                MobileScanner(onDetect: _onDetect),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.black54,
                    child: const Text(
                      'Point the camera at the refugee\'s QR code',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.desktop_windows, size: 56),
                    const SizedBox(height: 16),
                    const Text(
                      'Camera scanning is not available on this device.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You can use the Web app or an Android/iOS device to scan the QR.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back'),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
