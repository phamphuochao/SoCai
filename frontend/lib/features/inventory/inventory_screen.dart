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
import '../../components/tables/responsive_data_view.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_spacing.dart';
import '../../core/network/api_client.dart';
import '../../core/routing/route_paths.dart';
import '../../l10n/l10n.dart';
import '../../models/retail_models.dart';
import '../../providers/auth_provider.dart';
import '../../services/inventory_service.dart';
import '../../services/product_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Product>? _products;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_products == null && _error == null) _load();
  }

  Future<void> _load() async {
    setState(() {
      _products = null;
      _error = null;
    });
    try {
      final products = await ProductService(
        context.read<ApiClient>(),
      ).products(activeOnly: true);
      if (mounted) setState(() => _products = products);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  Future<void> _openAdjustment() async {
    if (_products == null || _products!.isEmpty) return;
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _InventoryMutationDialog(
        products: _products!,
        admin: context.read<AuthProvider>().isAdmin,
        api: context.read<ApiClient>(),
      ),
    );
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) => PageContent(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: context.l10n.inventory,
          subtitle: context.l10n.inventorySubtitle,
          actions: [
            SecondaryButton(
              label: context.l10n.inventoryHistory,
              icon: Icons.history,
              onPressed: () => context.go(RoutePaths.inventoryHistory),
            ),
            PrimaryButton(
              label: context.l10n.importOrAdjust,
              icon: Icons.tune,
              onPressed: _openAdjustment,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_error != null)
          ErrorView(message: _error!, onRetry: _load)
        else if (_products == null)
          const LoadingView()
        else if (_products!.isEmpty)
          EmptyView(message: context.l10n.noInventoryProducts)
        else
          ResponsiveDataView(
            desktop: AppCard(
              padding: EdgeInsets.zero,
              child: DataTable(
                columns: [
                  DataColumn(label: Text(context.l10n.sku)),
                  DataColumn(label: Text(context.l10n.product)),
                  DataColumn(label: Text(context.l10n.currentStock)),
                  DataColumn(label: Text(context.l10n.warningThreshold)),
                  DataColumn(label: Text(context.l10n.status)),
                ],
                rows: _products!.map(_row).toList(),
              ),
            ),
            compactItems: _products!.map(_card).toList(),
          ),
      ],
    ),
  );

  Widget _badge(Product product) => product.isLowStock
      ? StatusBadge(label: context.l10n.lowStock, color: AppColors.warning)
      : StatusBadge(label: context.l10n.inStock, color: AppColors.success);

  DataRow _row(Product product) => DataRow(
    cells: [
      DataCell(Text(product.sku)),
      DataCell(Text(product.name)),
      DataCell(Text('${product.stockQuantity}')),
      DataCell(Text('${product.minStockLevel}')),
      DataCell(_badge(product)),
    ],
  );

  Widget _card(Product product) => AppCard(
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${product.sku} • ${context.l10n.thresholdValue(product.minStockLevel)}',
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${product.stockQuantity}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            _badge(product),
          ],
        ),
      ],
    ),
  );
}

class _InventoryMutationDialog extends StatefulWidget {
  const _InventoryMutationDialog({
    required this.products,
    required this.admin,
    required this.api,
  });

  final List<Product> products;
  final bool admin;
  final ApiClient api;

  @override
  State<_InventoryMutationDialog> createState() =>
      _InventoryMutationDialogState();
}

class _InventoryMutationDialogState extends State<_InventoryMutationDialog> {
  late int _productId = widget.products.first.id;
  String _mode = 'import';
  final _quantity = TextEditingController();
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _quantity.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final quantity = int.tryParse(_quantity.text);
    if (quantity == null ||
        quantity == 0 ||
        (_mode == 'import' && quantity < 0)) {
      showMessage(
        context,
        _mode == 'import'
            ? context.l10n.importQuantityPositive
            : context.l10n.adjustmentNonZero,
        error: true,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final service = InventoryService(widget.api);
      if (_mode == 'import') {
        await service.importStock(_productId, quantity, _note.text.trim());
      } else {
        await service.adjustStock(_productId, quantity, _note.text.trim());
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) showMessage(context, error.toString(), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: AppDialogTitle(
      title: context.l10n.updateInventory,
      icon: Icons.inventory_2_outlined,
    ),
    content: SizedBox(
      width: AppDimensions.dialogWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: _productId,
            decoration: InputDecoration(labelText: context.l10n.product),
            items: widget.products
                .map(
                  (product) => DropdownMenuItem(
                    value: product.id,
                    child: Text(product.name),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                setState(() => _productId = value ?? _productId),
          ),
          const SizedBox(height: AppSpacing.md),
          AppDropdown<String>(
            value: _mode,
            label: context.l10n.operationType,
            items: {
              'import': context.l10n.importStock,
              if (widget.admin) 'adjust': context.l10n.inventoryAdjustment,
            },
            onChanged: (value) => setState(() => _mode = value ?? 'import'),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _quantity,
            label: _mode == 'import'
                ? context.l10n.importQuantity
                : context.l10n.quantityChange,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _note,
            label: context.l10n.notes,
            maxLines: 2,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _busy ? null : () => Navigator.pop(context, false),
        child: Text(context.l10n.close),
      ),
      FilledButton(
        onPressed: _busy ? null : _submit,
        child: Text(_busy ? context.l10n.saving : context.l10n.save),
      ),
    ],
  );
}
