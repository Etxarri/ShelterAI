import 'package:flutter/material.dart';

/// Mixin to handle common authentication form state and controllers
mixin AuthFormMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    if (mounted) {
      setState(() => _isLoading = loading);
    }
  }

  VoidCallback get startLoading => () => setLoading(true);
  VoidCallback get stopLoading => () => setLoading(false);
}

/// Mixin for login forms with identifier and password controllers
mixin LoginFormControllers<T extends StatefulWidget> on State<T> {
  late final TextEditingController identifierController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    identifierController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String get identifier => identifierController.text.trim();
  String get password => passwordController.text.trim();
}

/// Mixin for register forms with multiple controllers
mixin RegisterFormControllers<T extends StatefulWidget> on State<T> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String get name => nameController.text.trim();
  String get email => emailController.text.trim();
  String get password => passwordController.text.trim();
  String get confirmPassword => confirmPasswordController.text.trim();
}
