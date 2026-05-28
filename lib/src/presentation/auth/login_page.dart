import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../features/auth/presentation/auth_session_controller.dart';

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
  static const _logoAsset = 'assets/images/regatracker_logo.svg';

  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

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
    const navy = Color(0xFF061B3A);
    const cyan = Color(0xFF00B8CC);
    const background = Color(0xFFF8FBFD);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            final screenWidth = MediaQuery.sizeOf(context).width;
            final brandFontSize = 56.0;
            final titleFontSize = screenWidth < 360 ? 34.0 : 40.0;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.onBack != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: widget.onBack,
                              icon: const Icon(Icons.arrow_back_rounded),
                              color: navy,
                            ),
                          ),

                        const SizedBox(height: 12),

                        SvgPicture.asset(_logoAsset, width: 200, height: 200),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'REGATracker',
                              style: TextStyle(
                                fontSize: brandFontSize,
                                fontWeight: FontWeight.w800,
                                color: navy,
                                letterSpacing: -0.8,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'Вход',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w800,
                            color: navy,
                            letterSpacing: -0.8,
                          ),
                        ),

                        const SizedBox(height: 32),

                        _AuthTextField(
                          controller: _loginController,
                          hintText: 'Логин',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Введите логин';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _AuthTextField(
                          controller: _passwordController,
                          hintText: 'Пароль',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите пароль';
                            }
                            return null;
                          },
                        ),

                        if (widget.controller.error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: 0.08),
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
                            onPressed: widget.controller.isLoading
                                ? null
                                : _submit,
                            style: ElevatedButton.styleFrom(
                              elevation: 8,
                              shadowColor: cyan.withValues(alpha: 0.28),
                              backgroundColor: cyan,
                              disabledBackgroundColor: cyan.withValues(
                                alpha: 0.55,
                              ),
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
                                    'Войти',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: widget.onOpenRegister,
                            style: ElevatedButton.styleFrom(
                              elevation: 8,
                              shadowColor: cyan.withValues(alpha: 0.28),
                              backgroundColor: cyan,
                              disabledBackgroundColor: cyan.withValues(
                                alpha: 0.55,
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'Зарегистрироваться',
                              style: TextStyle(
                                fontSize: 20,
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
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
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
        prefixIcon: Icon(icon, color: navy, size: 25),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
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
          borderSide: const BorderSide(color: Color(0xFF00B8CC), width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
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
