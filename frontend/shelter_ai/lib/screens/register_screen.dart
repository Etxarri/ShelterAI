import 'package:flutter/material.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/services/auth_service.dart';
import 'package:shelter_ai/widgets/auth_button.dart';
import 'package:shelter_ai/widgets/auth_screen_scaffold.dart';
import 'package:shelter_ai/utils/auth_helper.dart';
import 'package:shelter_ai/utils/form_validators.dart';
import 'package:shelter_ai/mixins/auth_form_mixin.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with AuthFormMixin, RegisterFormControllers {
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    await AuthHelper.handleWorkerRegister(
      context: context,
      name: name,
      email: email,
      password: password,
      onLoadingStart: startLoading,
      onLoadingEnd: stopLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenScaffold(
      title: 'Create account',
      showAppBar: true,
      onBackPressed: () => Navigator.pushReplacementNamed(context, '/login'),
      isLoading: isLoading,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthFormHeader(
              title: 'Create worker account',
              subtitle: 'Use an organization email to maintain security.',
            ),
            AuthTextField(
              controller: nameController,
              labelText: 'Full name',
              prefixIcon: Icons.person,
              enabled: !isLoading,
              validator: FormValidators.required,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: emailController,
              labelText: 'Email',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              enabled: !isLoading,
              validator: FormValidators.email,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: passwordController,
              labelText: 'Password',
              prefixIcon: Icons.lock,
              obscureText: true,
              enabled: !isLoading,
              validator: FormValidators.password,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: confirmPasswordController,
              labelText: 'Confirm password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              enabled: !isLoading,
              validator: (v) => FormValidators.confirmPassword(v, password),
            ),
            const SizedBox(height: 22),
            AuthButton(
              onPressed: _handleRegister,
              isLoading: isLoading,
              label: 'Create account',
              loadingLabel: 'Creating account...',
              icon: Icons.person_add_alt_1,
            ),
            AuthNavigationButton(
              text: 'I already have an account',
              route: '/login',
              isLoading: isLoading,
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }
}
