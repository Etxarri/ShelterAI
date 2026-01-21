import 'package:flutter/material.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/services/auth_service.dart';
import 'package:shelter_ai/widgets/auth_button.dart';
import 'package:shelter_ai/widgets/auth_screen_scaffold.dart';
import 'package:shelter_ai/utils/auth_helper.dart';
import 'package:shelter_ai/mixins/auth_form_mixin.dart';

class RefugeeLoginScreen extends StatefulWidget {
  const RefugeeLoginScreen({super.key});

  @override
  State<RefugeeLoginScreen> createState() => _RefugeeLoginScreenState();
}

class _RefugeeLoginScreenState extends State<RefugeeLoginScreen>
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
      title: 'Sign In',
      showAppBar: true,
      onBackPressed: () =>
          Navigator.pushReplacementNamed(context, '/refugee-landing'),
      isLoading: isLoading,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthFormHeader(
            title: 'Refugee Access',
            subtitle: 'Use your email, phone or username to access.',
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
            text: 'Don\'t have an account? Register',
            route: '/refugee-register',
            isLoading: isLoading,
            isPrimary: true,
          ),
          AuthNavigationButton(
            text: 'Back',
            route: '/refugee-landing',
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
