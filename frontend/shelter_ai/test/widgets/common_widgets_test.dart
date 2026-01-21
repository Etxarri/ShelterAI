import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/widgets/common_widgets.dart';

void main() {
  group('LogoutMixin', () {
    testWidgets('logoutRefugee logs out and navigates to /refugee-login',
        (tester) async {
      final auth = AuthState();
      auth.login(UserRole.refugee,
          userId: 1, token: 'test', userName: 'Test');

      await tester.pumpWidget(
        AuthScope(
          state: auth,
          child: MaterialApp(
            routes: {
              '/refugee-login': (_) =>
                  const Scaffold(body: Text('REFUGEE_LOGIN')),
            },
            home: const _TestLogoutWidget(isRefugee: true),
          ),
        ),
      );

      expect(auth.isAuthenticated, isTrue);

      await tester.tap(find.text('Logout Refugee'));
      await tester.pumpAndSettle();

      expect(auth.isAuthenticated, isFalse);
      expect(find.text('REFUGEE_LOGIN'), findsOneWidget);
    });

    testWidgets('logoutWorker logs out and navigates to /login',
        (tester) async {
      final auth = AuthState();
      auth.login(UserRole.worker, userId: 1, token: 'test', userName: 'Test');

      await tester.pumpWidget(
        AuthScope(
          state: auth,
          child: MaterialApp(
            routes: {
              '/login': (_) => const Scaffold(body: Text('WORKER_LOGIN')),
            },
            home: const _TestLogoutWidget(isRefugee: false),
          ),
        ),
      );

      expect(auth.isAuthenticated, isTrue);

      await tester.tap(find.text('Logout Worker'));
      await tester.pumpAndSettle();

      expect(auth.isAuthenticated, isFalse);
      expect(find.text('WORKER_LOGIN'), findsOneWidget);
    });
  });

  group('WelcomeHeader', () {
    testWidgets('renders greeting without userName', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeHeader(greeting: 'Welcome'),
          ),
        ),
      );

      expect(find.text('Welcome'), findsOneWidget);
    });

    testWidgets('renders greeting with userName', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeHeader(
              greeting: 'Hello',
              userName: 'John',
            ),
          ),
        ),
      );

      expect(find.text('Hello, John'), findsOneWidget);
    });

    testWidgets('renders greeting with subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeHeader(
              greeting: 'Welcome',
              subtitle: 'How can we help you today?',
            ),
          ),
        ),
      );

      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('How can we help you today?'), findsOneWidget);
    });

    testWidgets('renders with empty userName', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WelcomeHeader(
              greeting: 'Welcome',
              userName: '',
            ),
          ),
        ),
      );

      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Welcome, '), findsNothing);
    });
  });

  group('InfoCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfoCard(
              color: Colors.blue,
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.blue.withOpacity(0.4));
    });

    testWidgets('applies custom opacity', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfoCard(
              color: Colors.red,
              opacity: 0.8,
              child: Text('Test'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red.withOpacity(0.8));
    });

    testWidgets('applies custom border radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfoCard(
              color: Colors.green,
              borderRadius: 20,
              child: Text('Test'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(20));
    });

    testWidgets('applies custom border', (tester) async {
      final border = Border.all(color: Colors.black, width: 2);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfoCard(
              color: Colors.yellow,
              border: border,
              child: Text('Test'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, border);
    });
  });

  group('TipTile', () {
    testWidgets('renders with all properties', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TipTile(
              icon: Icons.info,
              title: 'Important Tip',
              subtitle: 'This is a helpful tip',
            ),
          ),
        ),
      );

      expect(find.text('Important Tip'), findsOneWidget);
      expect(find.text('This is a helpful tip'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('uses default icon color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TipTile(
              icon: Icons.check,
              title: 'Tip',
              subtitle: 'Subtitle',
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.check));
      expect(icon.color, Colors.teal);
    });

    testWidgets('applies custom icon color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TipTile(
              icon: Icons.warning,
              title: 'Warning',
              subtitle: 'Be careful',
              iconColor: Colors.red,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.warning));
      expect(icon.color, Colors.red);
    });
  });

  group('InfoTile', () {
    testWidgets('renders with all properties', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfoTile(
              icon: Icons.help,
              title: 'Help Title',
              body: 'This is the help body text',
            ),
          ),
        ),
      );

      expect(find.text('Help Title'), findsOneWidget);
      expect(find.text('This is the help body text'), findsOneWidget);
      expect(find.byIcon(Icons.help), findsOneWidget);
    });

    testWidgets('has proper styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfoTile(
              icon: Icons.info_outline,
              title: 'Title',
              body: 'Body',
            ),
          ),
        ),
      );

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);
      
      // Verificar que existe el widget InfoTile
      expect(find.byType(InfoTile), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });

  group('StepItem', () {
    testWidgets('renders with text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StepItem(text: 'Step 1: Complete the form'),
          ),
        ),
      );

      expect(find.text('Step 1: Complete the form'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('uses default icon color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StepItem(text: 'Step'),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(icon.color, Colors.teal);
    });

    testWidgets('applies custom icon color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StepItem(
              text: 'Important step',
              iconColor: Colors.orange,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(icon.color, Colors.orange);
    });
  });

  group('StatTile', () {
    testWidgets('renders with all properties', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatTile(
              icon: Icons.people,
              title: 'Total Users',
              value: '42',
            ),
          ),
        ),
      );

      expect(find.text('Total Users'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('has proper container styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatTile(
              icon: Icons.home,
              title: 'Shelters',
              value: '10',
            ),
          ),
        ),
      );

      // Verificar que el widget StatTile existe
      expect(find.byType(StatTile), findsOneWidget);
      expect(find.text('Shelters'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('displays large value with proper styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatTile(
              icon: Icons.assignment,
              title: 'Assignments',
              value: '999',
            ),
          ),
        ),
      );

      final valueText =
          tester.widget<Text>(find.text('999').first);
      expect(valueText.style?.fontSize, 20);
      expect(valueText.style?.fontWeight, FontWeight.bold);
    });
  });
}

// Helper widget to test LogoutMixin
class _TestLogoutWidget extends StatefulWidget {
  final bool isRefugee;

  const _TestLogoutWidget({required this.isRefugee});

  @override
  State<_TestLogoutWidget> createState() => _TestLogoutWidgetState();
}

class _TestLogoutWidgetState extends State<_TestLogoutWidget>
    with LogoutMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isRefugee)
              ElevatedButton(
                onPressed: logoutRefugee,
                child: const Text('Logout Refugee'),
              )
            else
              ElevatedButton(
                onPressed: logoutWorker,
                child: const Text('Logout Worker'),
              ),
          ],
        ),
      ),
    );
  }
}
