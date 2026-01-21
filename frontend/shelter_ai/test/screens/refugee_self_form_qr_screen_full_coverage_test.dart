// test/screens/refugee_self_form_qr_screen_full_coverage_test.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/screens/refugee_self_form_qr_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel printingChannel = MethodChannel('net.nfet.printing');

  setUpAll(() {
    // Mock del plugin printing para que no intente abrir platform channels reales
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(printingChannel, (call) async {
      // printing.sharePdf(...)
      if (call.method == 'sharePdf') {
        return true;
      }
      // otros métodos del plugin (por si acaso)
      return true;
    });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(printingChannel, null);
  });

  Widget _wrapWithApp({
    required AuthState auth,
  }) {
    return AuthScope(
      state: auth,
      child: MaterialApp(
        routes: {
          '/login': (_) => const Scaffold(body: Center(child: Text('LOGIN'))),
          '/refugee-login': (_) => const Scaffold(body: Center(child: Text('LOGIN'))),
        },
        home: const RefugeeSelfFormQrScreen(),
      ),
    );
  }

  // Helpers por índice (no usamos decoration para evitar el error)
  Finder _tf(int index) => find.byType(TextFormField).at(index);

  Finder _generateBtn() => find.widgetWithText(ElevatedButton, 'Generate and save my QR');
  Finder _familyInfoIcon() => find.byTooltip('What is Family ID?');

  testWidgets('Prefill: carga datos desde AuthState en los controllers', (tester) async {
    final auth = AuthState();
    auth.login(
      UserRole.refugee,
      userId: 1,
      token: 't',
      userName: 'John Doe',
      firstName: 'John',
      lastName: 'Doe',
      age: 33,
      gender: 'Female',
      nationality: 'Syrian',
      email: 'john@doe.com',
      phoneNumber: '+34 600000000',
      address: 'Fake Street 1',
    );

    await tester.pumpWidget(_wrapWithApp(auth: auth));
    await tester.pumpAndSettle();

    // Orden de TextFormField en tu pantalla:
    // 0 First Name
    // 1 Last Name
    // 2 Age
    // 3 Phone
    // 4 Email
    // 5 Address
    // 6 Family ID
    final firstName = tester.widget<TextFormField>(_tf(0)).controller!.text;
    final lastName = tester.widget<TextFormField>(_tf(1)).controller!.text;
    final age = tester.widget<TextFormField>(_tf(2)).controller!.text;
    final phone = tester.widget<TextFormField>(_tf(3)).controller!.text;
    final email = tester.widget<TextFormField>(_tf(4)).controller!.text;
    final address = tester.widget<TextFormField>(_tf(5)).controller!.text;

    expect(firstName, 'John');
    expect(lastName, 'Doe');
    expect(age, '33');
    expect(phone, '+34 600000000');
    expect(email, 'john@doe.com');
    expect(address, 'Fake Street 1');

    // Logout existe en AppBar
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });



  

  

  testWidgets('Logout: hace logout y navega a /login', (tester) async {
    final auth = AuthState();
    auth.login(
      UserRole.refugee,
      userId: 1,
      token: 't',
      userName: 'User',
      firstName: 'A',
      lastName: 'B',
    );

    await tester.pumpWidget(_wrapWithApp(auth: auth));
    await tester.pumpAndSettle();

    expect(auth.isAuthenticated, isTrue);

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsOneWidget);
    expect(auth.isAuthenticated, isFalse);
  });
}
