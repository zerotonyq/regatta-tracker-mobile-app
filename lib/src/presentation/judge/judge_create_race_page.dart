import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../features/api/models/api_models.dart';
import '../../features/auth/presentation/auth_session_controller.dart';
import '../../features/judge/presentation/judge_race_controller.dart';

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
  static const _logoAsset = 'assets/images/regatracker_logo.svg';

  final Set<int> _selectedParticipantIds = <int>{};
  String? _localError;

  @override
  void initState() {
    super.initState();
    widget.controller.loadRaceCatalog();
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
    const background = Color(0xFFF8FBFD);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            final selectedUsers = widget.controller.availableParticipants
                .where((user) => _selectedParticipantIds.contains(user.id))
                .toList();

            final availableUsers = widget.controller.availableParticipants
                .where((user) => !_selectedParticipantIds.contains(user.id))
                .toList();

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  children: [
                    _Header(
                      logoAsset: _logoAsset,
                      onBack: widget.onBack,
                    ),

                    const SizedBox(height: 24),

                    _HeroCard(
                      judgeId: widget.authController.userId,
                      selectedCount: _selectedParticipantIds.length,
                    ),

                    if (widget.controller.message != null &&
                        widget.controller.message!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _InlineBanner(
                        icon: Icons.check_circle_outline_rounded,
                        text: widget.controller.message!,
                      ),
                    ],

                    if (_localError != null &&
                        _localError!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _InlineBanner(
                        icon: Icons.error_outline_rounded,
                        text: _localError!,
                        danger: true,
                      ),
                    ],

                    if (widget.controller.error != null &&
                        widget.controller.error!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _InlineBanner(
                        icon: Icons.error_outline_rounded,
                        text: widget.controller.error!,
                        danger: true,
                      ),
                    ],

                    const SizedBox(height: 16),

                    _SelectedParticipantsSection(
                      users: selectedUsers,
                      onRemove: (user) => _removeParticipant(user.id),
                    ),

                    const SizedBox(height: 16),

                    _UserCatalogSection(
                      title: 'Доступные участники',
                      subtitle: 'Добавьте участников, которые будут включены в гонку.',
                      users: availableUsers,
                      emptyTitle: 'Участников нет',
                      emptyText: 'Сервис управления пока не вернул участников.',
                      actionTooltipBuilder: (user) => 'Добавить id ${user.id}',
                      actionIcon: Icons.add_rounded,
                      actionColor: _AppColors.cyan,
                      onAction: (user) => _addParticipant(user.id),
                    ),

                    const SizedBox(height: 24),

                    _PrimaryActionButton(
                      label: 'Создать гонку',
                      icon: Icons.flag_rounded,
                      loading: widget.controller.loading,
                      onPressed: widget.controller.loading ? null : _submit,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.logoAsset,
    required this.onBack,
  });

  final String logoAsset;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Назад',
          onTap: onBack,
        ),
        const SizedBox(width: 12),
        SvgPicture.asset(
          logoAsset,
          width: 42,
          height: 42,
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RegaTracker',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _AppColors.navy,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Создание гонки',
                style: TextStyle(
                  fontSize: 14,
                  color: _AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.judgeId,
    required this.selectedCount,
  });

  final int? judgeId;
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _CardIcon(
                icon: Icons.add_rounded,
                color: _AppColors.cyan,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Новая гонка',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _AppColors.navy,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Выберите участников из списка ниже. Текущий судья будет автоматически добавлен в создаваемую гонку.',
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: _AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(
                icon: Icons.gavel_rounded,
                text: 'ID судьи: ${judgeId?.toString() ?? 'неизвестно'}',
              ),
              _InfoChip(
                icon: Icons.groups_outlined,
                text: 'Участников: $selectedCount',
              ),
            ],
          ),
        ],
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
      subtitle: 'Эти участники будут добавлены в новую гонку.',
      users: users,
      emptyTitle: 'Пока никто не выбран',
      emptyText: 'Добавьте участников из списка ниже.',
      actionTooltipBuilder: (user) => 'Убрать id ${user.id}',
      actionIcon: Icons.remove_rounded,
      actionColor: Colors.redAccent,
      onAction: onRemove,
    );
  }
}

class _UserCatalogSection extends StatelessWidget {
  const _UserCatalogSection({
    required this.title,
    required this.subtitle,
    required this.users,
    required this.emptyTitle,
    required this.emptyText,
    required this.actionTooltipBuilder,
    required this.actionIcon,
    required this.actionColor,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final List<UserSummaryDto> users;
  final String emptyTitle;
  final String emptyText;
  final String Function(UserSummaryDto user) actionTooltipBuilder;
  final IconData actionIcon;
  final Color actionColor;
  final ValueChanged<UserSummaryDto> onAction;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _AppColors.navy,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              height: 1.35,
              color: _AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          if (users.isEmpty)
            _EmptyBlock(
              icon: Icons.person_off_outlined,
              title: emptyTitle,
              text: emptyText,
            )
          else
            ...users.map(
                  (user) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _UserTile(
                  user: user,
                  actionTooltip: actionTooltipBuilder(user),
                  actionIcon: actionIcon,
                  actionColor: actionColor,
                  onAction: () => onAction(user),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.actionTooltip,
    required this.actionIcon,
    required this.actionColor,
    required this.onAction,
  });

  final UserSummaryDto user;
  final String actionTooltip;
  final IconData actionIcon;
  final Color actionColor;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final fullName = '${user.name} ${user.surname}'.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: _AppColors.cyan,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isEmpty ? 'Пользователь ${user.id}' : fullName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: _AppColors.navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'id ${user.id} · логин ${user.login}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Tooltip(
            message: actionTooltip,
            child: InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: actionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  actionIcon,
                  color: actionColor,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Icon(icon, size: 23),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: _AppColors.cyan.withOpacity(0.28),
          backgroundColor: _AppColors.cyan,
          disabledBackgroundColor: _AppColors.cyan.withOpacity(0.45),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  const _AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _AppColors.border),
        boxShadow: [
          BoxShadow(
            color: _AppColors.navy.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardIcon extends StatelessWidget {
  const _CardIcon({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _AppColors.navy,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: _AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineBanner extends StatelessWidget {
  const _InlineBanner({
    required this.icon,
    required this.text,
    this.danger = false,
  });

  final IconData icon;
  final String text;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.redAccent : _AppColors.cyan;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _AppColors.navy,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: _AppColors.cyan,
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _AppColors.textMuted,
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _AppColors.navy.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: _AppColors.navy,
            size: 23,
          ),
        ),
      ),
    );
  }
}

class _AppColors {
  static const navy = Color(0xFF061B3A);
  static const cyan = Color(0xFF00B8CC);
  static const textMuted = Color(0xFF667085);
  static const border = Color(0xFFD6DEE8);
  static const surface = Colors.white;
  static const lightSurface = Color(0xFFF2F6FA);
}

extension on UserRole {
  String get wireNameRu {
    return switch (this) {
      UserRole.participant => 'участник',
      UserRole.judge => 'судья',
    };
  }
}