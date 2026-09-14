import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../components/buttons/app_buttons.dart';
import '../../components/cards/app_cards.dart';
import '../../components/feedback/app_feedback.dart';
import '../../components/inputs/app_inputs.dart';
import '../../components/layout/page_content.dart';
import '../../components/layout/page_header.dart';
import '../../components/navigation/pagination_bar.dart';
import '../../components/tables/responsive_data_view.dart';
import '../../core/constants/pagination_constants.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_spacing.dart';
import '../../core/network/api_client.dart';
import '../../core/routing/route_paths.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../l10n/l10n.dart';
import '../../models/retail_models.dart';
import '../../services/sale_service.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({
    super.key,
    this.search = '',
    this.status = 'all',
    this.from,
    this.to,
    this.page = 1,
  });

  final String search;
  final String status;
  final DateTime? from;
  final DateTime? to;
  final int page;

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  late final _search = TextEditingController(text: widget.search);
  late String _status = widget.status;
  late DateTime? _from = widget.from;
  late DateTime? _to = widget.to;
  List<Sale>? _sales;
  late int _page = widget.page;
  bool _hasNext = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sales == null && _error == null) _load();
  }

  @override
  void didUpdateWidget(covariant InvoicesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.search != widget.search ||
        oldWidget.status != widget.status ||
        oldWidget.from != widget.from ||
        oldWidget.to != widget.to ||
        oldWidget.page != widget.page) {
      _search.text = widget.search;
      _status = widget.status;
      _from = widget.from;
      _to = widget.to;
      _page = widget.page;
      _load();
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _sales = null;
      _error = null;
    });
    try {
      final sales = await SaleService(context.read<ApiClient>()).sales(
        invoiceCode: _search.text.trim(),
        status: _status == 'all' ? null : _status,
        dateFrom: _from,
        dateTo: _to == null
            ? null
            : DateTime(_to!.year, _to!.month, _to!.day, 23, 59, 59),
        offset: PaginationConstants.offsetFor(_page),
        limit: PaginationConstants.fetchSize,
      );
      if (mounted) {
        setState(() {
          _hasNext = sales.length > PaginationConstants.pageSize;
          _sales = sales.take(PaginationConstants.pageSize).toList();
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  void _applyUrl({int page = 1}) {
    final query = <String, String>{};
    if (_search.text.trim().isNotEmpty) query['search'] = _search.text.trim();
    if (_status != 'all') query['status'] = _status;
    if (_from != null) query['from'] = AppDateUtils.query(_from!);
    if (_to != null) query['to'] = AppDateUtils.query(_to!);
    if (page > 1) query['page'] = page.toString();
    context.go(
      Uri(path: RoutePaths.invoices, queryParameters: query).toString(),
    );
  }

  @override
  Widget build(BuildContext context) => PageContent(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: context.l10n.invoices,
          subtitle: context.l10n.invoicesSubtitle,
          actions: [
            PrimaryButton(
              label: context.l10n.createInvoice,
              icon: Icons.add_shopping_cart,
              onPressed: () => context.go(RoutePaths.sales),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 270,
                child: AppTextField(
                  controller: _search,
                  label: context.l10n.invoiceCode,
                  prefixIcon: Icons.search,
                  onSubmitted: (_) => _applyUrl(),
                ),
              ),
              SizedBox(
                width: 190,
                child: AppDropdown<String>(
                  value: _status,
                  label: context.l10n.status,
                  items: {
                    'all': context.l10n.all,
                    'COMPLETED': context.l10n.completed,
                    'CANCELLED': context.l10n.cancelled,
                  },
                  onChanged: (value) {
                    _status = value ?? 'all';
                    _applyUrl();
                  },
                ),
              ),
              SizedBox(
                width: 190,
                child: AppDatePicker(
                  label: context.l10n.fromDate,
                  value: _from,
                  onChanged: (value) {
                    _from = value;
                    _applyUrl();
                  },
                ),
              ),
              SizedBox(
                width: 190,
                child: AppDatePicker(
                  label: context.l10n.toDate,
                  value: _to,
                  onChanged: (value) {
                    _to = value;
                    _applyUrl();
                  },
                ),
              ),
              SecondaryButton(
                label: context.l10n.filter,
                icon: Icons.filter_alt_outlined,
                onPressed: _applyUrl,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_error != null)
          ErrorView(message: _error!, onRetry: _load)
        else if (_sales == null)
          const LoadingView()
        else if (_sales!.isEmpty && _page == 1)
          EmptyView(message: context.l10n.noMatchingInvoices)
        else ...[
          if (_sales!.isEmpty)
            EmptyView(message: context.l10n.noMatchingInvoices)
          else
            ResponsiveDataView(
              desktop: AppCard(
                padding: EdgeInsets.zero,
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text(context.l10n.invoiceCode)),
                          DataColumn(label: Text(context.l10n.time)),
                          DataColumn(label: Text(context.l10n.staff)),
                          DataColumn(label: Text(context.l10n.grandTotal)),
                          DataColumn(label: Text(context.l10n.payment)),
                          DataColumn(label: Text(context.l10n.status)),
                          const DataColumn(label: Text('')),
                        ],
                        rows: _sales!.map(_row).toList(),
                      ),
                    ),
                  ),
                ),
              ),
              compactItems: _sales!.map(_card).toList(),
            ),
          if (_page > 1 || _hasNext) ...[
            const SizedBox(height: AppSpacing.md),
            PaginationBar(
              page: _page,
              hasNext: _hasNext,
              onPageChanged: (page) => _applyUrl(page: page),
            ),
          ],
        ],
      ],
    ),
  );

  Widget _badge(Sale sale) => sale.isCancelled
      ? StatusBadge(label: context.l10n.cancelled, color: AppColors.error)
      : StatusBadge(label: context.l10n.completed, color: AppColors.success);

  String _paymentMethodLabel(String value) => switch (value) {
    'CASH' => context.l10n.cash,
    'TRANSFER' => context.l10n.bankTransfer,
    'CARD' => context.l10n.card,
    _ => value,
  };

  void _openInvoice(Sale sale) => context.go(RoutePaths.invoice(sale.id));

  DataCell _invoiceCell(Sale sale, Widget child) =>
      DataCell(child, onTap: () => _openInvoice(sale));

  DataRow _row(Sale sale) => DataRow(
    cells: [
      _invoiceCell(sale, Text(sale.invoiceCode)),
      _invoiceCell(sale, Text(AppDateUtils.displayDateTime(sale.soldAt))),
      _invoiceCell(sale, Text('#${sale.staffId}')),
      _invoiceCell(sale, Text(CurrencyUtils.format(sale.totalAmount))),
      _invoiceCell(sale, Text(_paymentMethodLabel(sale.paymentMethod))),
      _invoiceCell(sale, _badge(sale)),
      DataCell(
        IconButton(
          onPressed: () => _openInvoice(sale),
          icon: const Icon(Icons.chevron_right),
        ),
      ),
    ],
  );

  Widget _card(Sale sale) => AppCard(
    child: InkWell(
      onTap: () => context.go(RoutePaths.invoice(sale.id)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale.invoiceCode,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${AppDateUtils.displayDateTime(sale.soldAt)} • ${_paymentMethodLabel(sale.paymentMethod)}',
                ),
                const SizedBox(height: AppSpacing.xs),
                _badge(sale),
              ],
            ),
          ),
          Text(
            CurrencyUtils.format(sale.totalAmount),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    ),
  );
}
