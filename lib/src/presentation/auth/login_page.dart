import 'package:flutter/material.dart';

import '../../features/auth/presentation/auth_session_controller.dart';
import '../widgets/app_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    required this.controller,
    required this.onOpenRegister,
    this.onBack,
    super.key,
  });

  final AuthSessionController controller;
  final VoidCallback? onBack;
  final VoidCallback onOpenRegister;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await widget.controller.login(
      login: _loginController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.onBack == null
            ? null
            : BackButton(onPressed: widget.onBack),
        title: const Text('Вход'),
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _loginController,
                    decoration: const InputDecoration(
                      labelText: 'Логин',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Введите логин'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Пароль',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Введите пароль'
                        : null,
                  ),
                  if (widget.controller.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.controller.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Войти',
                    fullWidth: true,
                    loading: widget.controller.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Нет аккаунта? Регистрация',
                    fullWidth: true,
                    variant: AppButtonVariant.ghost,
                    onPressed: widget.onOpenRegister,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
