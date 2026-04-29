import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, success, danger, ghost, outline }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    super.key,
    this.onPressed,
    this.loading = false,
    this.fullWidth = false,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final style = _style(context, variant, size);
    final content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (icon != null)
          Icon(icon, size: 18),
        if (loading || icon != null) const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: style,
        child: content,
      ),
    );
  }

  ButtonStyle _style(
    BuildContext context,
    AppButtonVariant variant,
    AppButtonSize size,
  ) {
    final colors = Theme.of(context).colorScheme;
    final minimumSize = switch (size) {
      AppButtonSize.sm => const Size(40, 40),
      AppButtonSize.md => const Size(40, 48),
      AppButtonSize.lg => const Size(40, 56),
    };

    Color background;
    Color foreground;
    BorderSide? side;
    double elevation = 0;

    switch (variant) {
      case AppButtonVariant.primary:
        background = colors.primary;
        foreground = colors.onPrimary;
        elevation = 1;
      case AppButtonVariant.secondary:
        background = colors.secondaryContainer;
        foreground = colors.onSecondaryContainer;
      case AppButtonVariant.success:
        background = Colors.green.shade700;
        foreground = Colors.white;
        elevation = 1;
      case AppButtonVariant.danger:
        background = colors.error;
        foreground = colors.onError;
        elevation = 1;
      case AppButtonVariant.ghost:
        background = Colors.transparent;
        foreground = colors.onSurface;
      case AppButtonVariant.outline:
        background = Colors.transparent;
        foreground = colors.primary;
        side = BorderSide(color: colors.primary, width: 1.5);
    }

    return ElevatedButton.styleFrom(
      elevation: elevation,
      minimumSize: minimumSize,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      foregroundColor: foreground,
      backgroundColor: background,
      side: side,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
