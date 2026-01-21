import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shelter_ai/screens/home_screen.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/main.dart'; // AuthScope

void main() {
  Widget createWidgetUnderTest({
    Map<String, WidgetBuilder>? routes,
  }) {
    final auth = AuthState();
    // HomeScreen muestra el botón logout si está autenticado; no molesta.
    auth.login(UserRole.refugee, userId: 1, userName: "Refugee");

    return AuthScope(
      state: auth,
      child: MaterialApp(
        home: const HomeScreen(),
        routes: routes ?? const {},
      ),
    );
  }

  group('HomeScreen Tests', () {
    testWidgets('Shows main texts and buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // AppBar
      expect(find.text('Welcome to ShelterAI'), findsOneWidget);

      // Hero section
      expect(find.text('Register without queuing'), findsOneWidget);
      expect(
        find.textContaining('We want you to feel safe'),
        findsOneWidget,
      );

      // Main actions
      expect(find.text('Register and generate my QR'), findsOneWidget);
      expect(find.text("I have my QR, what's next?"), findsOneWidget);
      expect(find.text('I need urgent help'), findsOneWidget);

      // Info section
      expect(find.text("What's important now"), findsOneWidget);
      expect(find.text('We care for you from the first step'), findsOneWidget);
      expect(find.text('If you come with family'), findsOneWidget);
      expect(find.text('Your data, in confidence'), findsOneWidget);
    });

    testWidgets('Opens Next Steps bottom sheet', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text("I have my QR, what's next?"));
      await tester.pumpAndSettle();

      // Bottom sheet content
      expect(find.text('What to do upon arrival'), findsOneWidget);
      expect(find.text('Show your QR to the worker'), findsOneWidget);
      expect(find.text('Confirm your name and come with us'), findsOneWidget);
      expect(find.text('You will receive your place and a brief guide'), findsOneWidget);
    });

    testWidgets('Opens urgent help dialog and closes it', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('I need urgent help'));
      await tester.pumpAndSettle();

      expect(find.text('Immediate help'), findsOneWidget);
      expect(find.textContaining('medical attention'), findsOneWidget);

      // Close
      await tester.tap(find.text('Understood'));
      await tester.pumpAndSettle();

      expect(find.text('Immediate help'), findsNothing);
    });

    testWidgets('Navigates to refugee self form QR screen route', (WidgetTester tester) async {
      bool visited = false;

      await tester.pumpWidget(
        createWidgetUnderTest(
          routes: {
            '/refugee-self-form-qr': (_) {
              visited = true;
              return const Scaffold(body: Text('REFUGEE SELF FORM QR'));
            },
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Register and generate my QR'));
      await tester.pumpAndSettle();

      expect(visited, true);
      expect(find.text('REFUGEE SELF FORM QR'), findsOneWidget);
    });
  });
}
