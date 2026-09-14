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
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_spacing.dart';
import '../../core/network/api_client.dart';
import '../../core/routing/route_paths.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../l10n/l10n.dart';
import '../../models/retail_models.dart';
import '../../services/expense_service.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key, this.from, this.to, this.page = 1});

  final DateTime? from;
  final DateTime? to;
  final int page;

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late DateTime? _from = widget.from;
  late DateTime? _to = widget.to;
  List<Expense>? _expenses;
  late int _page = widget.page;
  bool _hasNext = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_expenses == null && _error == null) _load();
  }

  @override
  void didUpdateWidget(covariant ExpensesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.from != widget.from ||
        oldWidget.to != widget.to ||
        oldWidget.page != widget.page) {
      _from = widget.from;
      _to = widget.to;
      _page = widget.page;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _expenses = null;
      _error = null;
    });
    try {
      final values = await ExpenseService(context.read<ApiClient>()).expenses(
        dateFrom: _from,
        dateTo: _to,
        offset: PaginationConstants.offsetFor(_page),
        limit: PaginationConstants.fetchSize,
      );
      if (mounted) {
        setState(() {
          _hasNext = values.length > PaginationConstants.pageSize;
          _expenses = values.take(PaginationConstants.pageSize).toList();
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  void _applyUrl({int page = 1}) {
    final query = <String, String>{};
    if (_from != null) query['from'] = AppDateUtils.query(_from!);
    if (_to != null) query['to'] = AppDateUtils.query(_to!);
    if (page > 1) query['page'] = page.toString();
    context.go(
      Uri(path: RoutePaths.expenses, queryParameters: query).toString(),
    );
  }

  Future<void> _create() async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _ExpenseDialog(api: context.read<ApiClient>()),
    );
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total =
        _expenses?.fold<double>(0, (sum, expense) => sum + expense.amount) ?? 0;
    return PageContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: l10n.expenses,
            subtitle: l10n.expensesSubtitle,
            actions: [
              PrimaryButton(
                label: l10n.addExpense,
                icon: Icons.add,
                onPressed: _create,
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
                  width: 200,
                  child: AppDatePicker(
                    label: l10n.fromDate,
                    value: _from,
                    onChanged: (value) {
                      _from = value;
                      _applyUrl();
                    },
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: AppDatePicker(
                    label: l10n.toDate,
                    value: _to,
                    onChanged: (value) {
                      _to = value;
                      _applyUrl();
                    },
                  ),
                ),
                SecondaryButton(
                  label: l10n.filter,
                  icon: Icons.filter_alt_outlined,
                  onPressed: _applyUrl,
                ),
                Text(
                  l10n.pageTotalValue(CurrencyUtils.format(total)),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_error != null)
            ErrorView(message: _error!, onRetry: _load)
          else if (_expenses == null)
            const LoadingView()
          else if (_expenses!.isEmpty && _page == 1)
            EmptyView(message: l10n.noExpensesInRange)
          else ...[
            if (_expenses!.isEmpty)
              EmptyView(message: l10n.noExpensesInRange)
            else
              ResponsiveDataView(
                desktop: AppCard(
                  padding: EdgeInsets.zero,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text(l10n.date)),
                      DataColumn(label: Text(l10n.expenseType)),
                      DataColumn(label: Text(l10n.amount)),
                      DataColumn(label: Text(l10n.notes)),
                    ],
                    rows: _expenses!
                        .map(
                          (expense) => DataRow(
                            cells: [
                              DataCell(
                                Text(AppDateUtils.display(expense.date)),
                              ),
                              DataCell(Text(expense.type)),
                              DataCell(
                                Text(
                                  CurrencyUtils.format(expense.amount),
                                  style: const TextStyle(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                              DataCell(Text(expense.note ?? '—')),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
                compactItems: _expenses!
                    .map(
                      (expense) => AppCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(expense.type),
                          subtitle: Text(
                            '${AppDateUtils.display(expense.date)}\n${expense.note ?? ''}',
                          ),
                          trailing: Text(
                            CurrencyUtils.format(expense.amount),
                            style: const TextStyle(
                              color: AppColors.error,
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
}

class _ExpenseDialog extends StatefulWidget {
  const _ExpenseDialog({required this.api});

  final ApiClient api;

  @override
  State<_ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<_ExpenseDialog> {
  final _type = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  DateTime _date = DateTime.now();
  bool _busy = false;

  @override
  void dispose() {
    _type.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amount.text);
    if (_type.text.trim().isEmpty || amount == null || amount <= 0) {
      showMessage(context, context.l10n.invalidExpense, error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await ExpenseService(widget.api).create(
        type: _type.text.trim(),
        amount: amount,
        date: _date,
        note: _note.text.trim(),
      );
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
      title: context.l10n.addExpense,
      icon: Icons.payments_outlined,
      iconColor: AppColors.error,
    ),
    content: SizedBox(
      width: AppDimensions.dialogWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(controller: _type, label: context.l10n.expenseType),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _amount,
            label: context.l10n.amount,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          AppDatePicker(
            label: context.l10n.expenseDate,
            value: _date,
            onChanged: (value) => setState(() => _date = value),
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
