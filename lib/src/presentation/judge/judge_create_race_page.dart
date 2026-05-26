import 'package:flutter/material.dart';

import '../../features/api/models/api_models.dart';
import '../../features/auth/presentation/auth_session_controller.dart';
import '../../features/judge/presentation/judge_race_controller.dart';
import '../widgets/app_button.dart';

class JudgeCreateRacePage extends StatefulWidget {
  const JudgeCreateRacePage({
    required this.authController,
    required this.controller,
    required this.onBack,
    required this.onCreated,
    super.key,
  });

  final AuthSessionController authController;
  final JudgeRaceController controller;
  final VoidCallback onBack;
  final VoidCallback onCreated;

  @override
  State<JudgeCreateRacePage> createState() => _JudgeCreateRacePageState();
}

class _JudgeCreateRacePageState extends State<JudgeCreateRacePage> {
  final Set<int> _selectedParticipantIds = <int>{};
  String? _localError;

  @override
  void initState() {
    super.initState();
    widget.controller.loadRaceCatalog();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _submit() async {
    final currentJudgeId = widget.authController.userId;
    if (currentJudgeId == null) {
      setState(() {
        _localError =
            'Не удалось определить id текущего судьи. Перезайдите в аккаунт.';
      });
      return;
    }

    setState(() {
      _localError = null;
    });

    final raceId = await widget.controller.createRace(
      participantIds: _selectedParticipantIds.toList(),
      judgeIds: <int>[currentJudgeId],
    );
    if (raceId != null && mounted) {
      widget.onCreated();
    }
  }

  void _addParticipant(int id) {
    setState(() {
      _selectedParticipantIds.add(id);
    });
  }

  void _removeParticipant(int id) {
    setState(() {
      _selectedParticipantIds.remove(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: widget.onBack),
        title: const Text('Создание гонки'),
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                const Text(
                  'Выберите участников из списка ниже. Текущий судья будет автоматически добавлен в создаваемую гонку.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ваш id судьи: ${widget.authController.userId?.toString() ?? 'неизвестно'}',
                ),
                const SizedBox(height: 12),
                _SelectedParticipantsSection(
                  users: widget.controller.availableParticipants
                      .where(
                        (user) => _selectedParticipantIds.contains(user.id),
                      )
                      .toList(),
                  onRemove: (user) => _removeParticipant(user.id),
                ),
                const SizedBox(height: 16),
                _UserCatalogSection(
                  title: 'Доступные участники',
                  users: widget.controller.availableParticipants
                      .where(
                        (user) => !_selectedParticipantIds.contains(user.id),
                      )
                      .toList(),
                  emptyText: 'Сервис управления пока не вернул участников.',
                  actionTooltipBuilder: (user) => 'Добавить id ${user.id}',
                  actionIcon: Icons.add_circle_outline,
                  onAction: (user) => _addParticipant(user.id),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Создать гонку',
                  fullWidth: true,
                  loading: widget.controller.loading,
                  onPressed: _submit,
                ),
                if (widget.controller.message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.controller.message!,
                    style: TextStyle(color: Colors.green.shade700),
                  ),
                ],
                if (_localError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _localError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                if (widget.controller.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.controller.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UserCatalogSection extends StatelessWidget {
  const _UserCatalogSection({
    required this.title,
    required this.users,
    required this.emptyText,
    required this.actionTooltipBuilder,
    required this.actionIcon,
    required this.onAction,
  });

  final String title;
  final List<UserSummaryDto> users;
  final String emptyText;
  final String Function(UserSummaryDto user) actionTooltipBuilder;
  final IconData actionIcon;
  final ValueChanged<UserSummaryDto> onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (users.isEmpty)
              Text(emptyText)
            else
              ...users.map(
                (user) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('${user.name} ${user.surname}'),
                  subtitle: Text(
                    'id=${user.id} | логин=${user.login} | роль=${user.role.wireNameRu}',
                  ),
                  trailing: IconButton(
                    tooltip: actionTooltipBuilder(user),
                    icon: Icon(actionIcon),
                    onPressed: () => onAction(user),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SelectedParticipantsSection extends StatelessWidget {
  const _SelectedParticipantsSection({
    required this.users,
    required this.onRemove,
  });

  final List<UserSummaryDto> users;
  final ValueChanged<UserSummaryDto> onRemove;

  @override
  Widget build(BuildContext context) {
    return _UserCatalogSection(
      title: 'Приглашаемые участники',
      users: users,
      emptyText: 'Пока никто не выбран.',
      actionTooltipBuilder: (user) => 'Убрать id ${user.id}',
      actionIcon: Icons.remove_circle_outline,
      onAction: onRemove,
    );
  }
}

extension on UserRole {
  String get wireNameRu {
    return switch (this) {
      UserRole.participant => 'участник',
      UserRole.judge => 'судья',
    };
  }
}
