import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../features/auth/presentation/auth_bootstrap_controller.dart';
import '../../features/auth/presentation/auth_session_controller.dart';
import '../../features/auth/presentation/auth_session_state.dart';

class SessionRestorePage extends StatelessWidget {
  const SessionRestorePage({
    required this.controller,
    required this.bootstrapController,
    super.key,
  });

  final AuthSessionController controller;
  final AuthBootstrapController bootstrapController;

  static const _logoAsset = 'assets/images/regatracker_logo.svg';

  @override
  Widget build(BuildContext context) {
    final status = controller.status;
    final isBusy = bootstrapController.isBootstrapping ||
        status == AuthSessionStatus.restoring;
    final error = controller.error;

    const navy = Color(0xFF061B3A);
    const cyan = Color(0xFF00B8CC);
    const textMuted = Color(0xFF667085);
    const background = Color(0xFFF8FBFD);
    const borderColor = Color(0xFFD6DEE8);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    _logoAsset,
                    width: 128,
                    height: 128,
                  ),

                  const SizedBox(height: 28),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      key: ValueKey(isBusy),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: navy.withOpacity(0.06),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _StatusIcon(isBusy: isBusy),

                          const SizedBox(height: 22),

                          Text(
                            isBusy
                                ? 'Восстанавливаем сессию'
                                : 'Не удалось восстановить сессию',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: navy,
                              letterSpacing: -0.4,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            isBusy
                                ? 'Проверяем авторизацию и готовим приложение к запуску.'
                                : error ??
                                'Сеть недоступна или сервис авторизации сейчас не отвечает.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.45,
                              color: textMuted,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 28),

                          if (isBusy)
                            const SizedBox(
                              width: 34,
                              height: 34,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(cyan),
                              ),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                onPressed: bootstrapController.retryRestore,
                                style: ElevatedButton.styleFrom(
                                  elevation: 8,
                                  shadowColor: cyan.withOpacity(0.28),
                                  backgroundColor: cyan,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text(
                                  'Повторить',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'RegaTracker',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({
    required this.isBusy,
  });

  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF061B3A);
    const cyan = Color(0xFF00B8CC);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: isBusy ? cyan.withOpacity(0.1) : Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(
        isBusy ? Icons.sync_rounded : Icons.wifi_off_rounded,
        size: 34,
        color: isBusy ? cyan : Colors.redAccent,
      ),
    );
  }
}