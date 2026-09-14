import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../components/buttons/app_buttons.dart';
import '../../components/cards/app_cards.dart';
import '../../components/charts/revenue_chart.dart';
import '../../components/feedback/app_feedback.dart';
import '../../components/inputs/app_inputs.dart';
import '../../components/layout/page_content.dart';
import '../../components/layout/page_header.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_spacing.dart';
import '../../core/network/api_client.dart';
import '../../core/routing/route_paths.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../l10n/l10n.dart';
import '../../models/retail_models.dart';
import '../../services/report_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, this.from, this.to});

  final DateTime? from;
  final DateTime? to;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late DateTime _from =
      widget.from ?? DateTime.now().subtract(const Duration(days: 29));
  late DateTime _to = widget.to ?? DateTime.now();
  RevenueSummary? _summary;
  List<TopProduct> _top = const [];
  List<DailyRevenue> _daily = const [];
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_summary == null && _error == null) _load();
  }

  @override
  void didUpdateWidget(covariant ReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.from != widget.from || oldWidget.to != widget.to) {
      _from = widget.from ?? DateTime.now().subtract(const Duration(days: 29));
      _to = widget.to ?? DateTime.now();
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _summary = null;
      _error = null;
    });
    try {
      final report = ReportService(context.read<ApiClient>());
      final end = DateTime(_to.year, _to.month, _to.day, 23, 59, 59);
      final values = await Future.wait<dynamic>([
        report.summary(from: _from, to: end),
        report.topProducts(from: _from, to: end, limit: 10),
        report.dailyRevenue(from: _from, to: end),
      ]);
      if (!mounted) return;
      setState(() {
        _summary = values[0] as RevenueSummary;
        _top = values[1] as List<TopProduct>;
        _daily = values[2] as List<DailyRevenue>;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  void _applyUrl() {
    context.go(
      Uri(
        path: RoutePaths.reports,
        queryParameters: {
          'from': AppDateUtils.query(_from),
          'to': AppDateUtils.query(_to),
        },
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_summary == null) return const LoadingView();
    return PageContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(title: l10n.reports, subtitle: l10n.reportsSubtitle),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: AppDatePicker(
                    label: l10n.fromDate,
                    value: _from,
                    onChanged: (value) => setState(() => _from = value),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: AppDatePicker(
                    label: l10n.toDate,
                    value: _to,
                    onChanged: (value) => setState(() => _to = value),
                  ),
                ),
                PrimaryButton(
                  label: l10n.viewReport,
                  icon: Icons.bar_chart,
                  onPressed: _applyUrl,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              mainAxisExtent: 155,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
            ),
            itemCount: 5,
            itemBuilder: (context, index) => [
              StatCard(
                label: l10n.netRevenue,
                value: CurrencyUtils.format(_summary!.netRevenue),
                icon: Icons.payments_outlined,
              ),
              StatCard(
                label: l10n.grossProfit,
                value: CurrencyUtils.format(_summary!.grossProfit),
                icon: Icons.trending_up,
                color: AppColors.success,
              ),
              StatCard(
                label: l10n.netProfit,
                value: CurrencyUtils.format(_summary!.netProfit),
                icon: Icons.verified_outlined,
                color: Colors.deepPurple,
              ),
              StatCard(
                label: l10n.averageOrderValue,
                value: CurrencyUtils.format(_summary!.averageOrderValue),
                icon: Icons.calculate_outlined,
              ),
              StatCard(
                label: l10n.invoiceCount,
                value: '${_summary!.orderCount}',
                icon: Icons.receipt_long_outlined,
                color: AppColors.warning,
              ),
            ][index],
          ),
          const SizedBox(height: AppSpacing.lg),
          RevenueChart(data: _daily),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.topProducts,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                if (_top.isEmpty)
                  EmptyView(message: l10n.noSalesInRange)
                else
                  ..._top.asMap().entries.map(
                    (entry) => ListTile(
                      leading: CircleAvatar(
                        radius: 14,
                        child: Text('${entry.key + 1}'),
                      ),
                      title: Text(entry.value.name),
                      subtitle: Text(
                        l10n.productQuantity(entry.value.quantity),
                      ),
                      trailing: Text(CurrencyUtils.format(entry.value.revenue)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
