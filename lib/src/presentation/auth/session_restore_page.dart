import 'package:flutter/material.dart';

import '../../features/auth/presentation/auth_bootstrap_controller.dart';
import '../../features/auth/presentation/auth_session_controller.dart';
import '../../features/auth/presentation/auth_session_state.dart';
import '../widgets/app_button.dart';

class SessionRestorePage extends StatelessWidget {
  const SessionRestorePage({
    required this.controller,
    required this.bootstrapController,
    super.key,
  });

  final AuthSessionController controller;
  final AuthBootstrapController bootstrapController;

  @override
  Widget build(BuildContext context) {
    final status = controller.status;
    final isBusy =
        bootstrapController.isBootstrapping ||
        status == AuthSessionStatus.restoring;
    final error = controller.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Восстановление сессии')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isBusy
                      ? 'Восстанавливаем сессию...'
                      : 'Не удалось восстановить сессию',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  isBusy
                      ? 'Приложение обновляет действующую сессию перед открытием рабочих экранов.'
                      : (error ??
                            'Сеть недоступна или сервис авторизации сейчас не отвечает.'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (isBusy)
                  const Center(child: CircularProgressIndicator())
                else
                  AppButton(
                    label: 'Повторить',
                    fullWidth: true,
                    onPressed: bootstrapController.retryRestore,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
