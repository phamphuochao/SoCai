import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../components/language/language_menu.dart';
import '../../core/adaptive/app_breakpoints.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_spacing.dart';
import '../../core/routing/route_paths.dart';
import '../../l10n/l10n.dart';
import '../../providers/auth_provider.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    _Destination(Icons.dashboard_outlined, RoutePaths.dashboard),
    _Destination(Icons.shopping_cart_outlined, RoutePaths.sales),
    _Destination(Icons.receipt_long_outlined, RoutePaths.invoices),
    _Destination(Icons.inventory_2_outlined, RoutePaths.products),
    _Destination(Icons.warehouse_outlined, RoutePaths.inventory),
    _Destination(Icons.payments_outlined, RoutePaths.expenses),
    _Destination(Icons.bar_chart_outlined, RoutePaths.reports),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final selected = _selectedIndex(GoRouterState.of(context).uri.path);
    final labels = _labels(context);
    if (width < AppBreakpoints.compact) {
      return Scaffold(
        appBar: AppBar(title: const _Brand(compact: true)),
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: _Brand(),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _destinations.length,
                    itemBuilder: (context, index) => ListTile(
                      selected: index == selected,
                      leading: Icon(_destinations[index].icon),
                      title: Text(labels[index]),
                      onTap: () {
                        Navigator.pop(context);
                        context.go(_destinations[index].path);
                      },
                    ),
                  ),
                ),
                _AccountTile(
                  onLogout: () => context.read<AuthProvider>().logout(),
                ),
              ],
            ),
          ),
        ),
        body: child,
      );
    }

    if (width < AppBreakpoints.expanded) {
      final extended = width >= AppBreakpoints.medium;
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: extended,
              minExtendedWidth: 200,
              selectedIndex: selected,
              onDestinationSelected: (index) =>
                  context.go(_destinations[index].path),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: _Brand(compact: !extended),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LanguageMenu(),
                      IconButton(
                        tooltip: context.l10n.logout,
                        onPressed: () => context.read<AuthProvider>().logout(),
                        icon: const Icon(Icons.logout),
                      ),
                    ],
                  ),
                ),
              ),
              destinations: _destinations
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(labels[_destinations.indexOf(item)]),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: AppDimensions.sidebarWidth,
            child: Material(
              color: AppColors.surface,
              child: SafeArea(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: _Brand(),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        itemCount: _destinations.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.xxs,
                          ),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            selectedTileColor: AppColors.paleBlue,
                            selectedColor: AppColors.primary,
                            selected: index == selected,
                            leading: Icon(_destinations[index].icon),
                            title: Text(labels[index]),
                            onTap: () => context.go(_destinations[index].path),
                          ),
                        ),
                      ),
                    ),
                    _AccountTile(
                      onLogout: () => context.read<AuthProvider>().logout(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _selectedIndex(String path) {
    if (path.startsWith('/invoices')) return 2;
    if (path.startsWith('/products')) return 3;
    if (path.startsWith('/inventory')) return 4;
    final index = _destinations.indexWhere(
      (item) => path.startsWith(item.path),
    );
    return index < 0 ? 0 : index;
  }

  List<String> _labels(BuildContext context) => [
    context.l10n.dashboard,
    context.l10n.sales,
    context.l10n.invoices,
    context.l10n.products,
    context.l10n.inventory,
    context.l10n.expenses,
    context.l10n.reports,
  ];
}

class _Brand extends StatelessWidget {
  const _Brand({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        AppAssets.logo,
        width: compact ? 30 : 28,
        height: compact ? 30 : 28,
        fit: BoxFit.contain,
        semanticLabel: AppStrings.appName,
      ),
      if (!compact) ...[
        const SizedBox(width: 10),
        Text(
          AppStrings.appName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    ],
  );
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final l10n = context.l10n;
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  child: Icon(Icons.person_outline, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? user?.username ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        user?.role == 'admin' ? l10n.adminRole : l10n.staffRole,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LanguageMenu(),
                  IconButton(
                    tooltip: l10n.logout,
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Destination {
  const _Destination(this.icon, this.path);

  final IconData icon;
  final String path;
}
