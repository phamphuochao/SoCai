import 'package:flutter/material.dart';

import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_radius.dart';
import '../../core/design_system/app_spacing.dart';
import '../../l10n/l10n.dart';

class AppDialogTitle extends StatelessWidget {
  const AppDialogTitle({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor = AppColors.primary,
  });

  final String title;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(title)),
    ],
  );
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: AppDialogTitle(title: title, icon: Icons.help_outline_rounded),
          content: SizedBox(
            width: AppDimensions.dialogWidth,
            child: Text(message),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.close),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmLabel ?? context.l10n.confirm),
            ),
          ],
        ),
      ) ??
      false;
}
