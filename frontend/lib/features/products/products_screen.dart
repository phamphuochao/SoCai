import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../components/buttons/app_buttons.dart';
import '../../components/cards/app_cards.dart';
import '../../components/dialogs/confirm_dialog.dart';
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
import '../../l10n/l10n.dart';
import '../../models/retail_models.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({
    super.key,
    this.search = '',
    this.status = 'all',
    this.categoryId,
    this.page = 1,
  });

  final String search;
  final String status;
  final int? categoryId;
  final int page;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late final _search = TextEditingController(text: widget.search);
  List<Product>? _products;
  List<Category> _categories = const [];
  late String _status = widget.status;
  late int? _categoryId = widget.categoryId;
  late int _page = widget.page;
  bool _hasNext = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_products == null && _error == null) _load();
  }

  @override
  void didUpdateWidget(covariant ProductsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.search != widget.search ||
        oldWidget.status != widget.status ||
        oldWidget.categoryId != widget.categoryId ||
        oldWidget.page != widget.page) {
      _search.text = widget.search;
      _status = widget.status;
      _categoryId = widget.categoryId;
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
      _products = null;
      _error = null;
    });
    try {
      final service = ProductService(context.read<ApiClient>());
      final values = await Future.wait<dynamic>([
        service.categories(activeOnly: false),
        service.products(
          keyword: _search.text.trim(),
          categoryId: _categoryId,
          isActive: switch (_status) {
            'active' || 'low' => true,
            'inactive' => false,
            _ => null,
          },
          lowStockOnly: _status == 'low',
          offset: PaginationConstants.offsetFor(_page),
          limit: PaginationConstants.fetchSize,
        ),
      ]);
      final fetched = values[1] as List<Product>;
      if (!mounted) return;
      setState(() {
        _categories = values[0] as List<Category>;
        _hasNext = fetched.length > PaginationConstants.pageSize;
        _products = fetched.take(PaginationConstants.pageSize).toList();
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  void _applyUrl({int page = 1}) {
    final query = <String, String>{};
    if (_search.text.trim().isNotEmpty) query['search'] = _search.text.trim();
    if (_status != 'all') query['status'] = _status;
    if (_categoryId != null) query['category'] = _categoryId.toString();
    if (page > 1) query['page'] = page.toString();
    context.go(
      Uri(path: RoutePaths.products, queryParameters: query).toString(),
    );
  }

  Future<void> _deactivate(Product product) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.stopProductTitle,
      message: l10n.stopProductPrompt(product.name),
      confirmLabel: l10n.stopSelling,
    );
    if (!confirmed || !mounted) return;
    try {
      await ProductService(context.read<ApiClient>()).deactivate(product.id);
      if (mounted) {
        showMessage(context, l10n.stopProductSuccess(product.name));
        _load();
      }
    } catch (error) {
      if (mounted) showMessage(context, error.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AuthProvider>().isAdmin;
    final l10n = context.l10n;
    return PageContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: l10n.products,
            subtitle: l10n.productsSubtitle,
            actions: [
              if (admin)
                PrimaryButton(
                  label: l10n.addProduct,
                  icon: Icons.add,
                  onPressed: () => context.go(RoutePaths.productNew),
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
                  width: 320,
                  child: AppTextField(
                    controller: _search,
                    hint: l10n.searchNameOrSku,
                    prefixIcon: Icons.search,
                    onSubmitted: (_) => _applyUrl(),
                  ),
                ),
                SizedBox(
                  width: 210,
                  child: AppDropdown<String>(
                    value: _status,
                    label: l10n.status,
                    items: {
                      'all': l10n.allStatuses,
                      'active': l10n.activeProducts,
                      'inactive': l10n.inactiveProducts,
                      'low': l10n.lowStock,
                    },
                    onChanged: (value) {
                      _status = value ?? 'all';
                      _applyUrl();
                    },
                  ),
                ),
                SizedBox(
                  width: 230,
                  child: DropdownButtonFormField<int?>(
                    initialValue: _categoryId,
                    decoration: InputDecoration(labelText: l10n.category),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text(l10n.allCategories),
                      ),
                      ..._categories.map(
                        (category) => DropdownMenuItem<int?>(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      _categoryId = value;
                      _applyUrl();
                    },
                  ),
                ),
                SecondaryButton(
                  label: l10n.search,
                  icon: Icons.search,
                  onPressed: _applyUrl,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_error != null)
            ErrorView(message: _error!, onRetry: _load)
          else if (_products == null)
            const LoadingView()
          else if (_products!.isEmpty && _page == 1)
            EmptyView(message: l10n.noMatchingProducts)
          else ...[
            if (_products!.isEmpty)
              EmptyView(message: l10n.noMatchingProducts)
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
                            DataColumn(label: Text(l10n.productCode)),
                            DataColumn(label: Text(l10n.productName)),
                            DataColumn(label: Text(l10n.category)),
                            DataColumn(label: Text(l10n.sellingPrice)),
                            DataColumn(label: Text(l10n.stock)),
                            DataColumn(label: Text(l10n.status)),
                            DataColumn(label: Text(l10n.action)),
                          ],
                          rows: _products!
                              .map((product) => _row(product, admin))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                compactItems: _products!
                    .map((product) => _card(product, admin))
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

  String _categoryName(int? id) =>
      _categories.where((category) => category.id == id).firstOrNull?.name ??
      context.l10n.uncategorized;

  Widget _statusBadge(Product product) {
    if (!product.isActive) {
      return StatusBadge(
        label: context.l10n.inactiveProducts,
        color: AppColors.textSecondary,
      );
    }
    if (product.isLowStock) {
      return StatusBadge(
        label: context.l10n.lowStock,
        color: AppColors.warning,
      );
    }
    return StatusBadge(
      label: context.l10n.activeProducts,
      color: AppColors.success,
    );
  }

  DataRow _row(Product product, bool admin) => DataRow(
    cells: [
      DataCell(Text(product.sku)),
      DataCell(Text(product.name)),
      DataCell(Text(_categoryName(product.categoryId))),
      DataCell(Text(CurrencyUtils.format(product.sellingPrice))),
      DataCell(Text('${product.stockQuantity}')),
      DataCell(_statusBadge(product)),
      DataCell(
        Row(
          children: [
            if (admin)
              IconButton(
                tooltip: context.l10n.edit,
                onPressed: () => context.go(RoutePaths.productEdit(product.id)),
                icon: const Icon(Icons.edit_outlined),
              ),
            if (admin && product.isActive)
              IconButton(
                tooltip: context.l10n.stopSelling,
                onPressed: () => _deactivate(product),
                icon: const Icon(Icons.block_outlined),
              ),
          ],
        ),
      ),
    ],
  );

  Widget _card(Product product, bool admin) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            _statusBadge(product),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('${product.sku} • ${_categoryName(product.categoryId)}'),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${CurrencyUtils.format(product.sellingPrice)}  •  '
          '${context.l10n.stockValue(product.stockQuantity)}',
        ),
        if (admin) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              TextButton.icon(
                onPressed: () => context.go(RoutePaths.productEdit(product.id)),
                icon: const Icon(Icons.edit_outlined),
                label: Text(context.l10n.edit),
              ),
              if (product.isActive)
                TextButton.icon(
                  onPressed: () => _deactivate(product),
                  icon: const Icon(Icons.block_outlined),
                  label: Text(context.l10n.stopSelling),
                ),
            ],
          ),
        ],
      ],
    ),
  );
}
