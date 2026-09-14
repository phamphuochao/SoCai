import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../components/buttons/app_buttons.dart';
import '../../components/cards/app_cards.dart';
import '../../components/feedback/app_feedback.dart';
import '../../components/inputs/app_inputs.dart';
import '../../components/layout/page_content.dart';
import '../../components/layout/page_header.dart';
import '../../core/design_system/app_spacing.dart';
import '../../core/network/api_client.dart';
import '../../core/routing/route_paths.dart';
import '../../core/utils/validators.dart';
import '../../l10n/l10n.dart';
import '../../models/retail_models.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  final int? productId;

  bool get editing => productId != null;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sku = TextEditingController();
  final _name = TextEditingController();
  final _cost = TextEditingController(text: '0');
  final _price = TextEditingController(text: '0');
  final _stock = TextEditingController(text: '0');
  final _minimum = TextEditingController(text: '0');
  List<Category>? _categories;
  int? _categoryId;
  bool _busy = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_categories == null && _error == null) _load();
  }

  Future<void> _load() async {
    try {
      final service = ProductService(context.read<ApiClient>());
      final categories = await service.categories();
      Product? product;
      if (widget.productId != null) {
        product = await service.product(widget.productId!);
      }
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _categoryId = product?.categoryId ?? categories.firstOrNull?.id;
        if (product != null) {
          _sku.text = product.sku;
          _name.text = product.name;
          _cost.text = product.costPrice.toStringAsFixed(0);
          _price.text = product.sellingPrice.toStringAsFixed(0);
          _stock.text = product.stockQuantity.toString();
          _minimum.text = product.minStockLevel.toString();
        }
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final payload = <String, dynamic>{
      'name': _name.text.trim(),
      'category_id': _categoryId,
      'cost_price': double.parse(_cost.text),
      'selling_price': double.parse(_price.text),
      'min_stock_level': int.parse(_minimum.text),
    };
    if (!widget.editing) {
      payload['sku'] = _sku.text.trim();
      payload['stock_quantity'] = int.parse(_stock.text);
    }
    try {
      final service = ProductService(context.read<ApiClient>());
      if (widget.editing) {
        await service.update(widget.productId!, payload);
      } else {
        await service.create(payload);
      }
      if (!mounted) return;
      showMessage(
        context,
        widget.editing
            ? context.l10n.productUpdated
            : context.l10n.productCreated,
      );
      context.go(RoutePaths.products);
    } catch (error) {
      if (mounted) showMessage(context, error.toString(), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    for (final controller in [_sku, _name, _cost, _price, _stock, _minimum]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!context.watch<AuthProvider>().isAdmin) {
      return ErrorView(message: l10n.adminOnlyProducts);
    }
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_categories == null) return const LoadingView();
    return PageContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: widget.editing ? l10n.editProduct : l10n.createProduct,
          ),
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: AppCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _sku,
                        label: l10n.sku,
                        enabled: !widget.editing,
                        validator: (value) => Validators.required(
                          value,
                          l10n.fieldRequired(l10n.sku),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _name,
                        label: l10n.productName,
                        validator: (value) => Validators.required(
                          value,
                          l10n.fieldRequired(l10n.productName),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<int>(
                        initialValue: _categoryId,
                        decoration: InputDecoration(labelText: l10n.category),
                        items: _categories!
                            .map(
                              (category) => DropdownMenuItem(
                                value: category.id,
                                child: Text(category.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _categoryId = value),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _twoFields(
                        AppTextField(
                          controller: _cost,
                          label: l10n.costPrice,
                          keyboardType: TextInputType.number,
                          validator: (value) => Validators.nonNegativeNumber(
                            value,
                            invalidMessage: l10n.mustBeNumber(l10n.costPrice),
                            negativeMessage: l10n.mustNotBeNegative(
                              l10n.costPrice,
                            ),
                          ),
                        ),
                        AppTextField(
                          controller: _price,
                          label: l10n.sellingPrice,
                          keyboardType: TextInputType.number,
                          validator: (value) => Validators.nonNegativeNumber(
                            value,
                            invalidMessage: l10n.mustBeNumber(
                              l10n.sellingPrice,
                            ),
                            negativeMessage: l10n.mustNotBeNegative(
                              l10n.sellingPrice,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _twoFields(
                        AppTextField(
                          controller: _stock,
                          label: l10n.initialStock,
                          enabled: !widget.editing,
                          keyboardType: TextInputType.number,
                          validator: (value) => Validators.nonNegativeNumber(
                            value,
                            invalidMessage: l10n.mustBeNumber(l10n.stock),
                            negativeMessage: l10n.mustNotBeNegative(l10n.stock),
                          ),
                        ),
                        AppTextField(
                          controller: _minimum,
                          label: l10n.lowStockThreshold,
                          keyboardType: TextInputType.number,
                          validator: (value) => Validators.nonNegativeNumber(
                            value,
                            invalidMessage: l10n.mustBeNumber(
                              l10n.lowStockThreshold,
                            ),
                            negativeMessage: l10n.mustNotBeNegative(
                              l10n.lowStockThreshold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          SecondaryButton(
                            label: l10n.back,
                            onPressed: () => context.go(RoutePaths.products),
                          ),
                          PrimaryButton(
                            label: l10n.saveProduct,
                            loading: _busy,
                            onPressed: _save,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _twoFields(Widget first, Widget second) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth < 560
        ? Column(
            children: [
              first,
              const SizedBox(height: AppSpacing.md),
              second,
            ],
          )
        : Row(
            children: [
              Expanded(child: first),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: second),
            ],
          ),
  );
}
