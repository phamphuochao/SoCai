import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/cards/app_cards.dart';
import '../../components/charts/revenue_chart.dart';
import '../../components/feedback/app_feedback.dart';
import '../../components/layout/page_content.dart';
import '../../components/layout/page_header.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_spacing.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/currency_utils.dart';
import '../../l10n/l10n.dart';
import '../../models/retail_models.dart';
import '../../providers/auth_provider.dart';
import '../../services/inventory_service.dart';
import '../../services/report_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  RevenueSummary? _summary;
  List<DailyRevenue> _daily = const [];
  List<TopProduct> _top = const [];
  List<Product> _lowStock = const [];
  String? _error;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final api = context.read<ApiClient>();
      final report = ReportService(api);
      final inventory = InventoryService(api);
      final now = DateTime.now();
      final start = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 6));
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final values = await Future.wait<dynamic>([
        report.summary(),
        report.dailyRevenue(from: start, to: end),
        report.topProducts(from: start, to: end),
        inventory.lowStock(),
      ]);
      if (!mounted) return;
      setState(() {
        _summary = values[0] as RevenueSummary;
        _daily = values[1] as List<DailyRevenue>;
        _top = values[2] as List<TopProduct>;
        _lowStock = values[3] as List<Product>;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final l10n = context.l10n;
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_summary == null) return const LoadingView();
    return PageContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: l10n.dashboard,
            subtitle: l10n.welcomeUser(user?.fullName ?? user?.username ?? ''),
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1100
                  ? 4
                  : constraints.maxWidth >= 620
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: 168,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                ),
                itemCount: 4,
                itemBuilder: (context, index) => [
                  StatCard(
                    label: l10n.revenueToday,
                    value: CurrencyUtils.format(_summary!.netRevenue),
                    icon: Icons.payments_outlined,
                    color: AppColors.success,
                  ),
                  StatCard(
                    label: l10n.netProfit,
                    value: CurrencyUtils.format(_summary!.netProfit),
                    icon: Icons.verified_outlined,
                  ),
                  StatCard(
                    label: l10n.invoiceCount,
                    value: _summary!.orderCount.toString(),
                    icon: Icons.receipt_long_outlined,
                    color: Colors.deepPurple,
                  ),
                  StatCard(
                    label: l10n.lowStockProducts,
                    value: _lowStock.length.toString(),
                    icon: Icons.notifications_none,
                    color: AppColors.warning,
                  ),
                ][index],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final chart = RevenueChart(
                data: _daily,
                title: l10n.revenueLastSevenDays,
              );
              final top = AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.topProducts,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_top.isEmpty)
                      EmptyView(message: l10n.noSalesInRange)
                    else
                      ..._top.asMap().entries.map(
                        (entry) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 14,
                            child: Text('${entry.key + 1}'),
                          ),
                          title: Text(entry.value.name),
                          subtitle: Text(
                            l10n.productQuantity(entry.value.quantity),
                          ),
                          trailing: Text(
                            CurrencyUtils.format(entry.value.revenue),
                          ),
                        ),
                      ),
                  ],
                ),
              );
              if (constraints.maxWidth < 1000) {
                return Column(
                  children: [
                    chart,
                    const SizedBox(height: AppSpacing.md),
                    top,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: chart),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: top),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
