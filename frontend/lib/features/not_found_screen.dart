import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/buttons/app_buttons.dart';
import '../core/design_system/app_spacing.dart';
import '../core/routing/route_paths.dart';
import '../l10n/l10n.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('404', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.pageNotFound),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: l10n.backToDashboard,
                icon: Icons.dashboard_outlined,
                onPressed: () => context.go(RoutePaths.dashboard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
