import 'package:flutter/material.dart';

import '../../core/utils/date_utils.dart';
import '../../l10n/l10n.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final int maxLines;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
    ),
    obscureText: obscureText,
    keyboardType: keyboardType,
    validator: validator,
    onChanged: onChanged,
    onFieldSubmitted: onSubmitted,
    enabled: enabled,
    maxLines: maxLines,
  );
}

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
  });

  final T? value;
  final Map<T, String> items;
  final ValueChanged<T?>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items: items.entries
        .map(
          (entry) =>
              DropdownMenuItem<T>(value: entry.key, child: Text(entry.value)),
        )
        .toList(),
    onChanged: onChanged,
  );
}

class AppDatePicker extends StatelessWidget {
  const AppDatePicker({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () async {
      final result = await showDatePicker(
        context: context,
        initialDate: value ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        locale: Localizations.localeOf(context),
        helpText: context.l10n.selectDate,
        cancelText: context.l10n.cancel,
        confirmText: context.l10n.select,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(size: const Size(430, 700)),
          child: child!,
        ),
      );
      if (result != null) onChanged(result);
    },
    borderRadius: BorderRadius.circular(8),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      child: Text(
        value == null ? context.l10n.selectDate : AppDateUtils.display(value!),
      ),
    ),
  );
}
