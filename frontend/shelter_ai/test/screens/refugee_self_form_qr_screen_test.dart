import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/screens/refugee_self_form_qr_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // -------------------- Helpers --------------------
  Future<void> _setLargeScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
  }

  Widget _wrapWithAuth(Widget child) {
    return MaterialApp(
      routes: {
        '/login': (_) => const Scaffold(body: Text('LOGIN_SCREEN')),
      },
      home: AuthScope(
        state: AuthState(),
        child: child,
      ),
    );
  }

  Future<void> _pumpScreen(WidgetTester tester) async {
    await _setLargeScreen(tester);
    await tester.pumpWidget(_wrapWithAuth(const RefugeeSelfFormQrScreen()));
    await tester.pumpAndSettle();
  }

  Finder _generateButton() => find.text('Generate and save my QR');

  // En tu pantalla los 3 primeros TextFormField son:
  // 0 = First Name, 1 = Last Name, 2 = Age
  Finder _firstNameField() => find.byType(TextFormField).at(0);
  Finder _lastNameField() => find.byType(TextFormField).at(1);
  Finder _ageField() => find.byType(TextFormField).at(2);

  Future<void> _fillRequiredBasics(
    WidgetTester tester, {
    String first = 'John',
    String last = 'Doe',
    String age = '20',
  }) async {
    await tester.enterText(_firstNameField(), first);
    await tester.enterText(_lastNameField(), last);
    await tester.enterText(_ageField(), age);
    await tester.pumpAndSettle();
  }

  Future<void> _tapGenerate(WidgetTester tester) async {
    final btn = _generateButton();
    await tester.ensureVisible(btn);
    await tester.tap(btn, warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  Finder _logoutButton() {
    final byTooltip = find.byTooltip('Logout');
    if (byTooltip.evaluate().isNotEmpty) return byTooltip;
    return find.byIcon(Icons.logout);
  }

  group('RefugeeSelfFormQrScreen coverage', () {
    testWidgets('Renderiza pantalla, header y boton Generate',
        (WidgetTester tester) async {
      await _pumpScreen(tester);

      expect(find.text('Quick registration'), findsOneWidget);
      expect(_logoutButton(), findsOneWidget);
      expect(_generateButton(), findsOneWidget);

      expect(find.text('Your basic data'), findsOneWidget);
      expect(find.text('Language and nationality'), findsOneWidget);
      expect(find.text('Care and companions'), findsOneWidget);
    });

    testWidgets('Validacion: generate vacio -> Required',
        (WidgetTester tester) async {
      await _pumpScreen(tester);

      await _tapGenerate(tester);

      expect(find.text('Required'), findsAtLeastNWidgets(1));
    });

    testWidgets('Validacion: edad invalida -> Invalid age',
        (WidgetTester tester) async {
      await _pumpScreen(tester);

      await _fillRequiredBasics(tester, age: '-1');
      await _tapGenerate(tester);

      expect(find.text('Invalid age'), findsOneWidget);
    });

    testWidgets(
        'MultiSelect: seleccionar 1 item no falla y cierra el menu',
        (WidgetTester tester) async {
      await _pumpScreen(tester);

      // hay 2 PopupMenuButton (Languages y Special needs)
      final popups = find.byType(PopupMenuButton<String>);
      expect(popups, findsAtLeastNWidgets(1));

      // abrimos el primero (Languages)
      await tester.ensureVisible(popups.first);
      await tester.tap(popups.first);
      await tester.pumpAndSettle();

      // elegimos un item marcando el primer checkbox
      final cb = find.byType(Checkbox).first;
      expect(cb, findsOneWidget);

      await tester.tap(cb);
      await tester.pumpAndSettle();

      // al marcar, tu código hace Navigator.pop(context) -> el menú debe cerrarse
      expect(find.byType(PopupMenuItem<String>), findsNothing);

      // y suele aparecer algún "selected" en el widget cerrado, pero no lo hacemos obligatorio
      // (porque hay 2 multiselect y uno seguirá mostrando "Select items...")
      expect(find.byType(PopupMenuButton<String>), findsAtLeastNWidgets(1));
    });

    testWidgets('Family ID info: abre bottomsheet y se cierra con Got it',
        (WidgetTester tester) async {
      await _pumpScreen(tester);

      final infoBtn = find.byIcon(Icons.info_outline);
      await tester.ensureVisible(infoBtn);
      await tester.tap(infoBtn);
      await tester.pumpAndSettle();

      expect(find.text('What is Family ID?'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(find.text('What is Family ID?'), findsNothing);
    });

    testWidgets('Generate OK: abre dialog QR y Close cierra',
        (WidgetTester tester) async {
      await _pumpScreen(tester);

      await _fillRequiredBasics(tester, first: 'John', last: 'Doe', age: '22');
      await _tapGenerate(tester);

      expect(find.text('Your QR Code'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Your QR Code'), findsNothing);
    });

    testWidgets('Logout navega a /login', (WidgetTester tester) async {
      await _pumpScreen(tester);

      await tester.tap(_logoutButton());
      await tester.pumpAndSettle();

      expect(find.text('LOGIN_SCREEN'), findsOneWidget);
    });
  });
}
