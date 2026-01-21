import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:shelter_ai/screens/qr_scan_screen.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: child);

  // ---------------------------------------------------------------------------
  // TESTS “PUROS” para subir coverage del cálculo de soporte (sin tocar debug vars)
  // ---------------------------------------------------------------------------
  test('isScannerSupportedFor: web siempre true', () {
    expect(
      QrScanScreen.isScannerSupportedFor(isWeb: true, platform: TargetPlatform.windows),
      true,
    );
    expect(
      QrScanScreen.isScannerSupportedFor(isWeb: true, platform: TargetPlatform.android),
      true,
    );
  });

  test('isScannerSupportedFor: android/ios true cuando no es web', () {
    expect(
      QrScanScreen.isScannerSupportedFor(isWeb: false, platform: TargetPlatform.android),
      true,
    );
    expect(
      QrScanScreen.isScannerSupportedFor(isWeb: false, platform: TargetPlatform.iOS),
      true,
    );
  });

  test('isScannerSupportedFor: desktop false cuando no es web', () {
    expect(
      QrScanScreen.isScannerSupportedFor(isWeb: false, platform: TargetPlatform.windows),
      false,
    );
    expect(
      QrScanScreen.isScannerSupportedFor(isWeb: false, platform: TargetPlatform.linux),
      false,
    );
    expect(
      QrScanScreen.isScannerSupportedFor(isWeb: false, platform: TargetPlatform.macOS),
      false,
    );
  });

  // ---------------------------------------------------------------------------
  // TESTS de widget (los que ya te funcionaban)
  // ---------------------------------------------------------------------------
  testWidgets('QrScanScreen: AppBar y Scaffold siempre', (tester) async {
    await tester.pumpWidget(wrap(const QrScanScreen(scannerSupportedOverride: false)));
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Scan QR Code'), findsOneWidget);
  });

  testWidgets('QrScanScreen: fallback (desktop) muestra textos + Back', (tester) async {
    await tester.pumpWidget(wrap(const QrScanScreen(scannerSupportedOverride: false)));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.desktop_windows), findsOneWidget);
    expect(find.text('Camera scanning is not available on this device.'), findsOneWidget);
    expect(
      find.text('You can use the Web app or an Android/iOS device to scan the QR.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Back'), findsOneWidget);
    expect(find.byType(Column), findsOneWidget);
  });

  testWidgets('QrScanScreen: al pulsar Back (fallback) hace pop()', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const QrScanScreen(scannerSupportedOverride: false),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(QrScanScreen), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Back'));
    await tester.pumpAndSettle();

    expect(find.byType(QrScanScreen), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('QrScanScreen: scanner branch renderiza MobileScanner + texto inferior', (tester) async {
    await tester.pumpWidget(wrap(const QrScanScreen(scannerSupportedOverride: true)));
    await tester.pumpAndSettle();

    expect(find.byType(MobileScanner), findsOneWidget);
    expect(find.text("Point the camera at the refugee's QR code"), findsOneWidget);
  });

  testWidgets('QrScanScreen: handleRaw llama onScanned solo una vez y ignora vacio', (tester) async {
    String? got;
    int calls = 0;

    await tester.pumpWidget(wrap(QrScanScreen(
      scannerSupportedOverride: true,
      onScanned: (raw) {
        calls++;
        got = raw;
      },
    )));
    await tester.pumpAndSettle();

    final state = tester.state(find.byType(QrScanScreen)) as dynamic;

    state.handleRaw('');
    await tester.pump();
    expect(calls, 0);

    state.handleRaw('QR123');
    await tester.pump();
    expect(calls, 1);
    expect(got, 'QR123');

    state.handleRaw('QR456');
    await tester.pump();
    expect(calls, 1);
    expect(got, 'QR123');
  });

  testWidgets('QrScanScreen: handleRaw sin onScanned hace pop() y devuelve resultado', (tester) async {
    late Future resultFuture;

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () {
              resultFuture = Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const QrScanScreen(scannerSupportedOverride: true),
                ),
              );
            },
            child: const Text('Go'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();
    expect(find.byType(QrScanScreen), findsOneWidget);

    final state = tester.state(find.byType(QrScanScreen)) as dynamic;
    state.handleRaw('RESULT_OK');
    await tester.pumpAndSettle();

    expect(find.byType(QrScanScreen), findsNothing);

    final res = await resultFuture;
    expect(res, 'RESULT_OK');
  });
}
