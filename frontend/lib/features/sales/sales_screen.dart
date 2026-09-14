import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../components/buttons/app_buttons.dart';
import '../../components/cards/app_cards.dart';
import '../../components/feedback/app_feedback.dart';
import '../../components/inputs/app_inputs.dart';
import '../../components/layout/page_content.dart';
import '../../components/layout/page_header.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_spacing.dart';
import '../../core/network/api_client.dart';
import '../../core/routing/route_paths.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/validators.dart';
import '../../l10n/l10n.dart';
import '../../models/retail_models.dart';
import '../../services/product_service.dart';
import '../../services/sale_service.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key, this.search = ''});

  final String search;

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  late final _search = TextEditingController(text: widget.search);
  final _discount = TextEditingController(text: '0');
  final _customer = TextEditingController();
  List<Product>? _products;
  final Map<int, _CartLine> _cart = {};
  String _payment = 'CASH';
  String? _error;
  bool _submitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_products == null && _error == null) _loadProducts();
  }

  @override
  void didUpdateWidget(covariant SalesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.search != widget.search) {
      _search.text = widget.search;
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _products = null;
      _error = null;
    });
    try {
      final products = await ProductService(
        context.read<ApiClient>(),
      ).products(keyword: _search.text.trim(), activeOnly: true);
      if (mounted) setState(() => _products = products);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  void _applySearch() {
    final query = _search.text.trim().isEmpty
        ? const <String, String>{}
        : {'search': _search.text.trim()};
    context.go(Uri(path: RoutePaths.sales, queryParameters: query).toString());
  }

  void _add(Product product) {
    final current = _cart[product.id]?.quantity ?? 0;
    if (current >= product.stockQuantity) {
      showMessage(context, context.l10n.cartStockLimit, error: true);
      return;
    }
    setState(() => _cart[product.id] = _CartLine(product, current + 1));
  }

  void _changeQuantity(Product product, int change) {
    final next = (_cart[product.id]?.quantity ?? 0) + change;
    setState(() {
      if (next <= 0) {
        _cart.remove(product.id);
      } else if (next <= product.stockQuantity) {
        _cart[product.id] = _CartLine(product, next);
      }
    });
  }

  double get _estimatedSubtotal => _cart.values.fold(
    0,
    (sum, line) => sum + line.product.sellingPrice * line.quantity,
  );

  Future<void> _checkout() async {
    if (_cart.isEmpty) {
      showMessage(context, context.l10n.addAtLeastOneProduct, error: true);
      return;
    }
    final discount = double.tryParse(_discount.text);
    if (discount == null || discount < 0) {
      showMessage(context, context.l10n.discountMustNotBeNegative, error: true);
      return;
    }
    setState(() => _submitting = true);
    try {
      final sale = await SaleService(context.read<ApiClient>()).create(
        items: _cart.values
            .map(
              (line) => {
                'product_id': line.product.id,
                'quantity': line.quantity,
              },
            )
            .toList(),
        discountAmount: discount,
        paymentMethod: _payment,
        customerName: _customer.text.trim().isEmpty
            ? null
            : _customer.text.trim(),
      );
      if (!mounted) return;
      setState(() => _cart.clear());
      showMessage(
        context,
        context.l10n.invoiceCreated(
          sale.invoiceCode,
          CurrencyUtils.format(sale.totalAmount),
        ),
      );
      context.go(RoutePaths.invoice(sale.id));
    } catch (error) {
      if (mounted) showMessage(context, error.toString(), error: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _discount.dispose();
    _customer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PageContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(title: l10n.sales, subtitle: l10n.salesSubtitle),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final products = _productPanel();
              final cart = _cartPanel();
              if (constraints.maxWidth < 980) {
                return Column(
                  children: [
                    products,
                    const SizedBox(height: AppSpacing.md),
                    cart,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: products),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(flex: 2, child: cart),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _productPanel() => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.productList,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _search,
          hint: context.l10n.searchNameOrSku,
          prefixIcon: Icons.search,
          onSubmitted: (_) => _applySearch(),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_error != null)
          ErrorView(message: _error!, onRetry: _loadProducts)
        else if (_products == null)
          const LoadingView()
        else if (_products!.isEmpty)
          EmptyView(message: context.l10n.noActiveProducts)
        else
          ..._products!.map(
            (product) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.paleBlue,
                child: Text(product.name.characters.first),
              ),
              title: Text(product.name),
              subtitle: Text(
                '${product.sku} • ${context.l10n.stockValue(product.stockQuantity)}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(CurrencyUtils.format(product.sellingPrice)),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton.filled(
                    tooltip: context.l10n.addToCart,
                    style: IconButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: product.stockQuantity > 0
                        ? () => _add(product)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );

  Widget _cartPanel() => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.invoiceCart,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (_cart.isNotEmpty)
              TextButton(
                onPressed: () => setState(_cart.clear),
                child: Text(context.l10n.clearAll),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_cart.isEmpty)
          EmptyView(
            message: context.l10n.emptyCart,
            icon: Icons.shopping_cart_outlined,
          )
        else
          ..._cart.values.map(
            (line) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.product.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(CurrencyUtils.format(line.product.sellingPrice)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _changeQuantity(line.product, -1),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('${line.quantity}'),
                  IconButton(
                    onPressed: () => _changeQuantity(line.product, 1),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                  Text(
                    CurrencyUtils.format(
                      line.product.sellingPrice * line.quantity,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const Divider(),
        AppTextField(
          controller: _customer,
          label: context.l10n.customerOptional,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _discount,
          label: context.l10n.discount,
          keyboardType: TextInputType.number,
          validator: (value) => Validators.nonNegativeNumber(
            value,
            invalidMessage: context.l10n.mustBeNumber(context.l10n.discount),
            negativeMessage: context.l10n.mustNotBeNegative(
              context.l10n.discount,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppDropdown<String>(
          value: _payment,
          label: context.l10n.paymentMethod,
          items: {
            'CASH': context.l10n.cash,
            'TRANSFER': context.l10n.bankTransfer,
            'CARD': context.l10n.card,
          },
          onChanged: (value) => setState(() => _payment = value ?? 'CASH'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.l10n.estimatedSubtotal),
            Text(
              CurrencyUtils.format(_estimatedSubtotal),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.l10n.paymentConfirmationNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: context.l10n.checkout,
          icon: Icons.payments_outlined,
          loading: _submitting,
          expand: true,
          onPressed: _checkout,
        ),
      ],
    ),
  );
}

class _CartLine {
  const _CartLine(this.product, this.quantity);

  final Product product;
  final int quantity;
}
