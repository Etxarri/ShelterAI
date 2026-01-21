import 'package:flutter/material.dart';
import 'package:shelter_ai/widgets/form_card_container.dart';

/// Scaffold reutilizable para pantallas de autenticación
class AuthScreenScaffold extends StatelessWidget {
  final String? title;
  final bool showAppBar;
  final VoidCallback? onBackPressed;
  final bool isLoading;
  final Widget child;

  const AuthScreenScaffold({
    super.key,
    this.title,
    this.showAppBar = false,
    this.onBackPressed,
    this.isLoading = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => showAppBar,
      child: Scaffold(
        appBar: showAppBar
            ? AppBar(
                title: title != null ? Text(title!) : null,
                leading: onBackPressed != null
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: isLoading ? null : onBackPressed,
                      )
                    : null,
              )
            : null,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FormCardContainer(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget reutilizable para el encabezado de formularios de autenticación
class AuthFormHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthFormHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Widget reutilizable para botones de navegación en formularios
class AuthNavigationButton extends StatelessWidget {
  final String text;
  final String route;
  final bool isLoading;
  final bool isPrimary;

  const AuthNavigationButton({
    super.key,
    required this.text,
    required this.route,
    this.isLoading = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: isLoading
          ? null
          : () => Navigator.pushReplacementNamed(context, route),
      child: Text(
        text,
        style: isPrimary ? TextStyle(color: color.primary) : null,
      ),
    );
  }
}
