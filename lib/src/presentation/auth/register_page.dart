import 'package:flutter/material.dart';

import '../../core/domain/app_role.dart';
import '../../features/api/models/api_models.dart';
import '../../features/auth/presentation/auth_session_controller.dart';
import '../widgets/app_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    required this.controller,
    required this.onBack,
    required this.onOpenLogin,
    super.key,
  });

  final AuthSessionController controller;
  final VoidCallback onBack;
  final VoidCallback onOpenLogin;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static final RegExp _loginPattern = RegExp(r'^[a-zA-Z0-9]+$');

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  UserRole _selectedRole = UserRole.participant;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await widget.controller.register(
      name: _nameController.text.trim(),
      surname: _surnameController.text.trim(),
      login: _loginController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole == UserRole.judge
          ? AppRole.judge
          : AppRole.participant,
    );
  }

  String? _validateLogin(String? value) {
    final login = value?.trim() ?? '';
    if (login.isEmpty) {
      return 'Введите логин';
    }
    if (login.length < 3) {
      return 'Минимум 3 символа';
    }
    if (!_loginPattern.hasMatch(login)) {
      return 'Логин: только латинские буквы и цифры';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Введите пароль';
    }
    if (password.length < 8) {
      return 'Минимум 8 символов';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Нужна хотя бы одна заглавная буква';
    }
    if (!RegExp(r'[~!@#$&*_-]').hasMatch(password)) {
      return 'Нужен спецсимвол: ~ ! @ # \$ & * - _';
    }
    if (RegExp(r'[^a-zA-Z0-9~!@#$&*_-]').hasMatch(password)) {
      return 'В пароле есть недопустимые символы';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: widget.onBack),
        title: const Text('Регистрация'),
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Имя',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Введите имя' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _surnameController,
                    decoration: const InputDecoration(
                      labelText: 'Фамилия',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Введите фамилию'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _loginController,
                    decoration: const InputDecoration(
                      labelText: 'Логин',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateLogin,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Пароль',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validatePassword,
                  ),

                  RadioGroup<UserRole>(
                    groupValue: _selectedRole,
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Radio<UserRole>(value: UserRole.participant),
                            const SizedBox(width: 8),
                            const Text('Участник'),
                          ],
                        ),

                        Row(
                          children: [
                            Radio<UserRole>(value: UserRole.judge),
                            const SizedBox(width: 8),
                            const Text('Судья'),
                          ],
                        ),
                      ],
                    ),
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
                    label: 'Зарегистрироваться',
                    fullWidth: true,
                    loading: widget.controller.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Уже есть аккаунт? Войти',
                    fullWidth: true,
                    variant: AppButtonVariant.ghost,
                    onPressed: widget.onOpenLogin,
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
