import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../components/buttons/app_buttons.dart';
import '../../components/cards/app_cards.dart';
import '../../components/feedback/app_feedback.dart';
import '../../components/layout/page_content.dart';
import '../../components/layout/page_header.dart';
import '../../components/navigation/pagination_bar.dart';
import '../../components/tables/responsive_data_view.dart';
import '../../core/constants/pagination_constants.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_spacing.dart';
import '../../core/network/api_client.dart';
import '../../core/routing/route_paths.dart';
import '../../core/utils/date_utils.dart';
import '../../l10n/l10n.dart';
import '../../models/retail_models.dart';
import '../../services/inventory_service.dart';
import '../../services/product_service.dart';

class InventoryHistoryScreen extends StatefulWidget {
  const InventoryHistoryScreen({super.key, this.productId, this.page = 1});

  final int? productId;
  final int page;

  @override
  State<InventoryHistoryScreen> createState() => _InventoryHistoryScreenState();
}

class _InventoryHistoryScreenState extends State<InventoryHistoryScreen> {
  List<InventoryTransaction>? _transactions;
  List<Product> _products = const [];
  int? _productId;
  late int _page = widget.page;
  bool _hasNext = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _productId = widget.productId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_transactions == null && _error == null) _load();
  }

  @override
  void didUpdateWidget(covariant InventoryHistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId ||
        oldWidget.page != widget.page) {
      _productId = widget.productId;
      _page = widget.page;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _transactions = null;
      _error = null;
    });
    try {
      final api = context.read<ApiClient>();
      final values = await Future.wait<dynamic>([
        InventoryService(api).transactions(
          productId: _productId,
          offset: PaginationConstants.offsetFor(_page),
          limit: PaginationConstants.fetchSize,
        ),
        ProductService(api).products(),
      ]);
      if (!mounted) return;
      setState(() {
        final fetched = values[0] as List<InventoryTransaction>;
        _hasNext = fetched.length > PaginationConstants.pageSize;
        _transactions = fetched.take(PaginationConstants.pageSize).toList();
        _products = values[1] as List<Product>;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  String _productName(int id) =>
      _products.where((product) => product.id == id).firstOrNull?.name ??
      context.l10n.productNumber(id);

  String _transactionType(String type) => switch (type) {
    'IMPORT' => context.l10n.transactionImport,
    'ADJUSTMENT' => context.l10n.transactionAdjustment,
    'SALE' => context.l10n.transactionSale,
    'RETURN' => context.l10n.transactionReturn,
    _ => type,
  };

  void _applyUrl({int page = 1}) {
    final query = <String, String>{};
    if (_productId != null) query['product'] = _productId.toString();
    if (page > 1) query['page'] = page.toString();
    context.go(
      Uri(path: RoutePaths.inventoryHistory, queryParameters: query).toString(),
    );
  }

  @override
  Widget build(BuildContext context) => PageContent(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: context.l10n.inventoryHistory,
          subtitle: context.l10n.inventoryHistorySubtitle,
          actions: [
            SecondaryButton(
              label: context.l10n.currentInventory,
              onPressed: () => context.go(RoutePaths.inventory),
              icon: Icons.warehouse_outlined,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: DropdownButtonFormField<int?>(
            initialValue: _productId,
            decoration: InputDecoration(
              labelText: context.l10n.filterByProduct,
            ),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text(context.l10n.allProducts),
              ),
              ..._products.map(
                (product) => DropdownMenuItem<int?>(
                  value: product.id,
                  child: Text(product.name),
                ),
              ),
            ],
            onChanged: (value) {
              _productId = value;
              _applyUrl();
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_error != null)
          ErrorView(message: _error!, onRetry: _load)
        else if (_transactions == null)
          const LoadingView()
        else if (_transactions!.isEmpty && _page == 1)
          EmptyView(message: context.l10n.noInventoryTransactions)
        else ...[
          if (_transactions!.isEmpty)
            EmptyView(message: context.l10n.noInventoryTransactions)
          else
            ResponsiveDataView(
              desktop: AppCard(
                padding: EdgeInsets.zero,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text(context.l10n.time)),
                    DataColumn(label: Text(context.l10n.product)),
                    DataColumn(label: Text(context.l10n.type)),
                    DataColumn(label: Text(context.l10n.change)),
                    DataColumn(label: Text(context.l10n.notes)),
                  ],
                  rows: _transactions!
                      .map(
                        (transaction) => DataRow(
                          cells: [
                            DataCell(
                              Text(
                                AppDateUtils.displayDateTime(
                                  transaction.createdAt,
                                ),
                              ),
                            ),
                            DataCell(Text(_productName(transaction.productId))),
                            DataCell(Text(_transactionType(transaction.type))),
                            DataCell(
                              Text(
                                '${transaction.quantityChange > 0 ? '+' : ''}${transaction.quantityChange}',
                                style: TextStyle(
                                  color: transaction.quantityChange > 0
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ),
                            DataCell(Text(transaction.note ?? '—')),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
              compactItems: _transactions!
                  .map(
                    (transaction) => AppCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(_productName(transaction.productId)),
                        subtitle: Text(
                          '${_transactionType(transaction.type)} • ${AppDateUtils.displayDateTime(transaction.createdAt)}\n${transaction.note ?? ''}',
                        ),
                        trailing: Text(
                          '${transaction.quantityChange > 0 ? '+' : ''}${transaction.quantityChange}',
                          style: TextStyle(
                            color: transaction.quantityChange > 0
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
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
}
