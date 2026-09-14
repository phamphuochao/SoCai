import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../providers/locale_provider.dart';

class LanguageMenu extends StatelessWidget {
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final current = context.watch<LocaleProvider>().locale.languageCode;
    return PopupMenuButton<String>(
      tooltip: context.l10n.language,
      icon: const Icon(Icons.language_rounded),
      initialValue: current,
      onSelected: (code) =>
          context.read<LocaleProvider>().setLocale(Locale(code)),
      itemBuilder: (context) => [
        _item(context, 'vi', context.l10n.vietnamese, current),
        _item(context, 'en', context.l10n.english, current),
      ],
    );
  }

  PopupMenuItem<String> _item(
    BuildContext context,
    String code,
    String label,
    String current,
  ) => PopupMenuItem(
    value: code,
    child: Row(
      children: [
        SizedBox(
          width: 28,
          child: code == current
              ? Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
        ),
        Text(label),
      ],
    ),
  );
}
