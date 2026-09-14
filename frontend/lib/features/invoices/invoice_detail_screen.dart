import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../components/buttons/app_buttons.dart';
import '../../components/cards/app_cards.dart';
import '../../components/dialogs/confirm_dialog.dart';
import '../../components/feedback/app_feedback.dart';
import '../../components/layout/page_content.dart';
import '../../components/layout/page_header.dart';
import '../../components/tables/responsive_data_view.dart';
import '../../core/adaptive/app_breakpoints.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_spacing.dart';
import '../../core/network/api_client.dart';
import '../../core/routing/route_paths.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../l10n/l10n.dart';
import '../../models/retail_models.dart';
import '../../services/product_service.dart';
import '../../services/sale_service.dart';

class InvoiceDetailScreen extends StatefulWidget {
  const InvoiceDetailScreen({super.key, required this.saleId});

  final int saleId;

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  Sale? _sale;
  Map<int, Product> _products = const {};
  String? _error;
  bool _cancelling = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sale == null && _error == null) _load();
  }

  Future<void> _load() async {
    setState(() {
      _sale = null;
      _error = null;
    });
    try {
      final api = context.read<ApiClient>();
      final values = await Future.wait<dynamic>([
        SaleService(api).sale(widget.saleId),
        ProductService(api).products(),
      ]);
      if (!mounted) return;
      final products = values[1] as List<Product>;
      setState(() {
        _sale = values[0] as Sale;
        _products = {for (final product in products) product.id: product};
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  Future<void> _cancel() async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.cancelInvoice,
      message: l10n.cancelInvoicePrompt,
      confirmLabel: l10n.cancelInvoice,
    );
    if (!confirmed || !mounted) return;
    setState(() => _cancelling = true);
    try {
      final sale = await SaleService(
        context.read<ApiClient>(),
      ).cancel(widget.saleId);
      if (mounted) {
        setState(() => _sale = sale);
        showMessage(context, context.l10n.invoiceCancelled);
      }
    } catch (error) {
      if (mounted) showMessage(context, error.toString(), error: true);
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_sale == null) return const LoadingView();
    final sale = _sale!;
    final l10n = context.l10n;
    return PageContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: sale.invoiceCode,
            subtitle: l10n.createdAt(AppDateUtils.displayDateTime(sale.soldAt)),
            actions: [
              SecondaryButton(
                label: l10n.invoiceList,
                onPressed: () => context.go(RoutePaths.invoices),
              ),
              if (!sale.isCancelled)
                PrimaryButton(
                  label: l10n.cancelInvoice,
                  icon: Icons.cancel_outlined,
                  loading: _cancelling,
                  onPressed: _cancel,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(child: _invoiceInformation(sale)),
          const SizedBox(height: AppSpacing.md),
          _invoiceBody(sale),
        ],
      ),
    );
  }

  Widget _invoiceInformation(Sale sale) {
    final l10n = context.l10n;
    final details = [
      _detail(l10n.customer, sale.customerName ?? l10n.walkInCustomer),
      _detail(l10n.staff, '#${sale.staffId}'),
      _detail(l10n.payment, _paymentLabel(sale.paymentMethod)),
      _detailWidget(
        l10n.status,
        sale.isCancelled
            ? StatusBadge(label: l10n.cancelled, color: AppColors.error)
            : StatusBadge(label: l10n.completed, color: AppColors.success),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= AppBreakpoints.medium
            ? 4
            : constraints.maxWidth >= AppBreakpoints.compact
            ? 2
            : 1;
        final itemWidth =
            (constraints.maxWidth - AppSpacing.lg * (columns - 1)) / columns;
        return Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.md,
          children: details
              .map((detail) => SizedBox(width: itemWidth, child: detail))
              .toList(),
        );
      },
    );
  }

  Widget _invoiceBody(Sale sale) => LayoutBuilder(
    builder: (context, constraints) {
      final items = _itemsView(sale);
      final summary = _summaryCard(sale);
      if (constraints.maxWidth >= AppBreakpoints.expanded) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: items),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: summary),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          items,
          const SizedBox(height: AppSpacing.md),
          summary,
        ],
      );
    },
  );

  Widget _itemsView(Sale sale) => ResponsiveDataView(
    desktop: AppCard(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columns: [
                DataColumn(label: Text(context.l10n.product)),
                DataColumn(label: Text(context.l10n.quantity)),
                DataColumn(label: Text(context.l10n.unitPrice)),
                DataColumn(label: Text(context.l10n.lineTotal)),
              ],
              rows: sale.items.map(_itemRow).toList(),
            ),
          ),
        ),
      ),
    ),
    compactItems: sale.items.map(_itemCard).toList(),
  );

  DataRow _itemRow(SaleItem item) => DataRow(
    cells: [
      DataCell(Text(_productName(item))),
      DataCell(Text('${item.quantity}')),
      DataCell(Text(CurrencyUtils.format(item.unitPrice))),
      DataCell(Text(CurrencyUtils.format(item.lineTotal))),
    ],
  );

  Widget _itemCard(SaleItem item) => AppCard(
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _productName(item),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${item.quantity} × ${CurrencyUtils.format(item.unitPrice)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          CurrencyUtils.format(item.lineTotal),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    ),
  );

  String _productName(SaleItem item) =>
      _products[item.productId]?.name ??
      context.l10n.productNumber(item.productId);

  Widget _summaryCard(Sale sale) => AppCard(
    child: Column(
      children: [
        _moneyRow(context.l10n.subtotal, sale.subtotal),
        const SizedBox(height: AppSpacing.sm),
        _moneyRow(context.l10n.discount, sale.discountAmount),
        const Divider(height: AppSpacing.lg),
        _moneyRow(context.l10n.grandTotal, sale.totalAmount, emphasized: true),
      ],
    ),
  );

  String _paymentLabel(String value) => switch (value.toLowerCase()) {
    'cash' => context.l10n.cash,
    'transfer' || 'bank_transfer' => context.l10n.bankTransfer,
    'card' => context.l10n.card,
    _ => value,
  };

  Widget _detail(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 4),
      Text(value, style: Theme.of(context).textTheme.titleMedium),
    ],
  );
  Widget _detailWidget(String label, Widget value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 4),
      value,
    ],
  );
  Widget _moneyRow(String label, double value, {bool emphasized = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: emphasized ? Theme.of(context).textTheme.titleMedium : null,
          ),
          Text(
            CurrencyUtils.format(value),
            style: emphasized ? Theme.of(context).textTheme.titleLarge : null,
          ),
        ],
      );
}
