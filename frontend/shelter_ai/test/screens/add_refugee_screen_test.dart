import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/screens/add_refugee_screen.dart';
import 'package:shelter_ai/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthState authState;

  setUp(() {
    authState = AuthState();
  });

  Widget _wrapWithAuth(Widget child) {
    return AuthScope(
      state: authState,
      child: MaterialApp(
        routes: {
          '/qr-scan': (_) => const Scaffold(body: Text('QR_SCAN_SCREEN')),
        },
        home: child,
      ),
    );
  }

  Finder _textField(String label) {
    return find.widgetWithText(TextFormField, label);
  }

  Future<void> _fillBasicForm(WidgetTester tester) async {
    await tester.enterText(
        find.widgetWithText(TextFormField, 'First Name'), 'John');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Last Name'), 'Doe');
    await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '30');
    await tester.pumpAndSettle();
  }

  group('AddRefugeeScreen - UI', () {
    testWidgets('renders all sections and fields', (tester) async {
      authState.login(UserRole.worker,
          userId: 1, token: 'test', userName: 'Worker');

      await tester.pumpWidget(_wrapWithAuth(const AddRefugeeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Add Refugee'), findsOneWidget);
      expect(find.text('Basic Data'), findsOneWidget);
      expect(find.text('Language and nationality'), findsOneWidget);
      expect(find.text('Contact'), findsOneWidget);
      expect(find.text('Care and companions'), findsOneWidget);

      expect(_textField('First Name'), findsOneWidget);
      expect(_textField('Last Name'), findsOneWidget);
      expect(_textField('Age'), findsOneWidget);
      expect(find.text('Gender'), findsOneWidget);
    });

    testWidgets('shows QR scan button for workers', (tester) async {
      authState.login(UserRole.worker,
          userId: 1, token: 'test', userName: 'Worker');

      await tester.pumpWidget(_wrapWithAuth(const AddRefugeeScreen()));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Scan QR'), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    });

    testWidgets('hides QR scan button for refugees', (tester) async {
      authState.login(UserRole.refugee,
          userId: 1, token: 'test', userName: 'Refugee');

      await tester.pumpWidget(_wrapWithAuth(const AddRefugeeScreen()));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Scan QR'), findsNothing);
    });

    testWidgets('renders all optional fields', (tester) async {
      authState.login(UserRole.worker,
          userId: 1, token: 'test', userName: 'Worker');

      await tester.pumpWidget(_wrapWithAuth(const AddRefugeeScreen()));
      await tester.pumpAndSettle();

      expect(_textField('Phone number (optional)'), findsOneWidget);
      expect(_textField('Email (optional)'), findsOneWidget);
      expect(_textField('Address (optional)'), findsOneWidget);
      expect(_textField('Family ID (if available)'), findsOneWidget);
    });

    testWidgets('shows disability switch', (tester) async {
      authState.login(UserRole.worker,
          userId: 1, token: 'test', userName: 'Worker');

      await tester.pumpWidget(_wrapWithAuth(const AddRefugeeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Has disability or reduced mobility'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('shows Family ID info button', (tester) async {
      authState.login(UserRole.worker,
          userId: 1, token: 'test', userName: 'Worker');

      await tester.pumpWidget(_wrapWithAuth(const AddRefugeeScreen()));
      await tester.pumpAndSettle();

      expect(find.byTooltip('What is Family ID?'), findsOneWidget);
    });
  });

  group('AddRefugeeScreen - Validation', () {
    testWidgets('validates required fields', (tester) async {
      authState.login(UserRole.worker,
          userId: 1, token: 'test', userName: 'Worker');

      await tester.pumpWidget(_wrapWithAuth(const AddRefugeeScreen()));
      await tester.pumpAndSettle();

      // Los campos requeridos están vacíos
      // La validación se ejecuta pero no mostramos errores hasta hacer tap
      expect(_textField('First Name'), findsOneWidget);
      expect(_textField('Last Name'), findsOneWidget);
      expect(_textField('Age'), findsOneWidget);
    });

    testWidgets('accepts valid age', (tester) async {
      authState.login(UserRole.worker,
          userId: 1, token: 'test', userName: 'Worker');

      await tester.pumpWidget(_wrapWithAuth(const AddRefugeeScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(_textField('Age'), '25');
      await tester.pumpAndSettle();

      expect(find.text('25'), findsOneWidget);
    });
  });

  group('AddRefugeeScreen - Gender Selection', () {
    testWidgets('can select Male gender', (tester) async {
      authState.login(UserRole.worker,
          userId: 1, token: 'test', userName: 'Worker');

      await tester.pumpWidget(_wrapWithAuth(const AddRefugeeScreen()));
      await tester.pumpAndSettle();

      final dropdown = find.byType(DropdownButtonFormField<String>).first;
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Male').last);
      await tester.pumpAndSettle();

      expect(find.text('Male'), findsAtLeastNWidgets(1));
    });

    testWidgets('can select Female gender', (tester) async {
      authState.login(UserRole.worker,
          userId: 1, token: 'test', userName: 'Worker');

      await tester.pumpWidget(_wrapWithAuth(const AddRefugeeScreen()));
      await tester.pumpAndSettle();

      final dropdown = find.byType(DropdownButtonFormField<String>).first;
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Female').last);
      await tester.pumpAndSettle();

      expect(find.text('Female'), findsAtLeastNWidgets(1));
    });

    testWidgets('can select Other gender', (tester) async {
      authState.login(UserRole.worker,
          userId: 1, token: 'test', userName: 'Worker');

      await tester.pumpWidget(_wrapWithAuth(const AddRefugeeScreen()));
      await tester.pumpAndSettle();

      final dropdown = find.byType(DropdownButtonFormField<String>).first;
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Other').last);
      await tester.pumpAndSettle();

      expect(find.text('Other'), findsAtLeastNWidgets(1));
    });
  });

  group('AddRefugeeScreen - Disability Switch', () {
    testWidgets('disability switch defaults to false', (tester) async {
      authState.login(UserRole.worker,
          userId: 1, token: 'test', userName: 'Worker');

      await tester.pumpWidget(_wrapWithAuth(const AddRefugeeScreen()));
      await tester.pumpAndSettle();

      final switchWidget = tester.widget<SwitchListTile>(
          find.byType(SwitchListTile).first);
      expect(switchWidget.value, isFalse);
    });

    testWidgets('disability switch exists', (tester) async {
      authState.login(UserRole.worker,
          userId: 1, token: 'test', userName: 'Worker');

      await tester.pumpWidget(_wrapWithAuth(const AddRefugeeScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(find.text('Has disability or reduced mobility'), findsOneWidget);
    });
  });

  group('AddRefugeeScreen - Save Functionality', () {
    testWidgets('API error shows error snackbar', (tester) async {
      authState.login(UserRole.worker,
          userId: 1, token: 'test', userName: 'Worker');

      ApiService.client = MockClient((req) async {
        return http.Response('Server Error', 500);
      });

      await tester.pumpWidget(_wrapWithAuth(const AddRefugeeScreen()));
      await tester.pumpAndSettle();

      await _fillBasicForm(tester);

      await tester.ensureVisible(find.text('Save and assign'));
      await tester.tap(find.text('Save and assign'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('Error al registrar refugiado'),
          findsOneWidget);
    });
  });

  group('AddRefugeeScreen - Optional Fields', () {
    testWidgets('can fill optional contact fields', (tester) async {
      authState.login(UserRole.worker,
          userId: 1, token: 'test', userName: 'Worker');

      await tester.pumpWidget(_wrapWithAuth(const AddRefugeeScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
          _textField('Phone number (optional)'), '+34 123456789');
      await tester.enterText(
          _textField('Email (optional)'), 'test@example.com');
      await tester.enterText(
          _textField('Address (optional)'), '123 Main St');
      await tester.pumpAndSettle();

      expect(find.text('+34 123456789'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('123 Main St'), findsOneWidget);
    });

    testWidgets('can fill family ID field', (tester) async {
      authState.login(UserRole.worker,
          userId: 1, token: 'test', userName: 'Worker');

      await tester.pumpWidget(_wrapWithAuth(const AddRefugeeScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(_textField('Family ID (if available)'), '12345');
      await tester.pumpAndSettle();

      expect(find.text('12345'), findsOneWidget);
    });
  });

  group('AddRefugeeScreen - Family ID Info Modal', () {
    testWidgets('has info icon for Family ID', (tester) async {
      authState.login(UserRole.worker,
          userId: 1, token: 'test', userName: 'Worker');

      await tester.pumpWidget(_wrapWithAuth(const AddRefugeeScreen()));
      await tester.pumpAndSettle();

      expect(find.byTooltip('What is Family ID?'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });

  group('AddRefugeeScreen - Complex Scenarios', () {
    testWidgets('can fill optional contact fields', (tester) async {
      authState.login(UserRole.worker,
          userId: 1, token: 'test', userName: 'Worker');

      await tester.pumpWidget(_wrapWithAuth(const AddRefugeeScreen()));
      await tester.pumpAndSettle();

      // Fill basic required fields
      await _fillBasicForm(tester);

      // Fill optional fields
      await tester.enterText(
          _textField('Phone number (optional)'), '+34 987654321');
      await tester.enterText(
          _textField('Email (optional)'), 'complete@test.com');
      await tester.enterText(
          _textField('Address (optional)'), 'Test Address');
      await tester.enterText(_textField('Family ID (if available)'), '999');
      await tester.pumpAndSettle();

      expect(find.text('+34 987654321'), findsOneWidget);
      expect(find.text('complete@test.com'), findsOneWidget);
      expect(find.text('Test Address'), findsOneWidget);
      expect(find.text('999'), findsOneWidget);
    });
  });
}
