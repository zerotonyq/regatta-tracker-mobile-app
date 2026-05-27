import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/domain/app_role.dart';
import '../../features/api/models/api_models.dart';
import '../../features/auth/presentation/auth_session_controller.dart';

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
  static const _logoAsset = 'assets/images/regatracker_logo.svg';
  static final RegExp _loginPattern = RegExp(r'^[a-zA-Z0-9]+$');

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  UserRole _selectedRole = UserRole.participant;
  bool _obscurePassword = true;

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
    const navy = Color(0xFF061B3A);
    const cyan = Color(0xFF00B8CC);
    const textMuted = Color(0xFF667085);
    const background = Color(0xFFF8FBFD);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: widget.onBack,
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: navy,
                          ),
                        ),

                        const SizedBox(height: 4),

                        SvgPicture.asset(
                          _logoAsset,
                          width: 100,
                          height: 100,
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Регистрация',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: navy,
                            letterSpacing: -0.6,
                          ),
                        ),


                        const SizedBox(height: 34),

                        _AuthTextField(
                          controller: _nameController,
                          hintText: 'Имя',
                          icon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Введите имя';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        _AuthTextField(
                          controller: _surnameController,
                          hintText: 'Фамилия',
                          icon: Icons.badge_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Введите фамилию';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        _AuthTextField(
                          controller: _loginController,
                          hintText: 'Логин',
                          icon: Icons.alternate_email_rounded,
                          textInputAction: TextInputAction.next,
                          validator: _validateLogin,
                        ),

                        const SizedBox(height: 14),

                        _AuthTextField(
                          controller: _passwordController,
                          hintText: 'Пароль',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: navy,
                            ),
                          ),
                          validator: _validatePassword,
                        ),

                        const SizedBox(height: 22),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Роль',
                            style: TextStyle(
                              fontSize: 15,
                              color: navy.withOpacity(0.76),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: _RoleCard(
                                title: 'Участник',
                                subtitle: 'Гонщик',
                                icon: Icons.sailing_rounded,
                                selected: _selectedRole == UserRole.participant,
                                onTap: () {
                                  setState(() {
                                    _selectedRole = UserRole.participant;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _RoleCard(
                                title: 'Судья',
                                subtitle: 'Контроль',
                                icon: Icons.gavel_rounded,
                                selected: _selectedRole == UserRole.judge,
                                onTap: () {
                                  setState(() {
                                    _selectedRole = UserRole.judge;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        if (widget.controller.error != null) ...[
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .error
                                  .withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              widget.controller.error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed:
                            widget.controller.isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              elevation: 8,
                              shadowColor: cyan.withOpacity(0.28),
                              backgroundColor: cyan,
                              disabledBackgroundColor: cyan.withOpacity(0.55),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: widget.controller.isLoading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                                : const Text(
                              'Создать аккаунт',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF061B3A);
    const textMuted = Color(0xFF667085);
    const borderColor = Color(0xFFD6DEE8);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(
        fontSize: 17,
        color: navy,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: textMuted,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          icon,
          color: navy,
          size: 24,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 19,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFF00B8CC),
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.6,
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF061B3A);
    const cyan = Color(0xFF00B8CC);
    const borderColor = Color(0xFFD6DEE8);
    const textMuted = Color(0xFF667085);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? cyan.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? cyan : borderColor,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: cyan.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected ? cyan : const Color(0xFFF2F6FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : navy,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: navy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: cyan,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}