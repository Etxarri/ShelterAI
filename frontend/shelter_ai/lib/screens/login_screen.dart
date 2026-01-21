import 'package:flutter/material.dart';
import '../widgets/custom_snackbar.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/services/auth_service.dart';
import 'package:shelter_ai/widgets/auth_button.dart';
import 'package:shelter_ai/widgets/auth_screen_scaffold.dart';
import 'package:shelter_ai/utils/auth_helper.dart';
import 'package:shelter_ai/mixins/auth_form_mixin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with AuthFormMixin, LoginFormControllers {
  Future<void> _handleLogin() async {
    await AuthHelper.handleLogin(
      context: context,
      identifier: identifier,
      password: password,
      onLoadingStart: startLoading,
      onLoadingEnd: stopLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenScaffold(
      isLoading: isLoading,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthFormHeader(
            title: 'Worker Access',
            subtitle: 'Receive, assign and prioritize securely.',
          ),
          AuthTextField(
            controller: identifierController,
            labelText: 'Email, phone or username',
            prefixIcon: Icons.person,
            keyboardType: TextInputType.text,
            enabled: !isLoading,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: passwordController,
            labelText: 'Password',
            prefixIcon: Icons.lock,
            obscureText: true,
            enabled: !isLoading,
          ),
          const SizedBox(height: 20),
          AuthButton(
            onPressed: _handleLogin,
            isLoading: isLoading,
            label: 'Sign in',
            loadingLabel: 'Signing in...',
            icon: Icons.login,
          ),
          AuthNavigationButton(
            text: 'First time? Create account',
            route: '/register',
            isLoading: isLoading,
            isPrimary: true,
          ),
          AuthNavigationButton(
            text: 'Back to home',
            route: '/welcome',
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
