import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../l10n/l10n.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.page,
    required this.hasNext,
    required this.onPageChanged,
  });

  final int page;
  final bool hasNext;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.end,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.xs,
    children: [
      OutlinedButton.icon(
        onPressed: page > 1 ? () => onPageChanged(page - 1) : null,
        icon: const Icon(Icons.chevron_left),
        label: Text(context.l10n.previousPage),
      ),
      Semantics(
        liveRegion: true,
        child: Text(
          context.l10n.pageNumber(page),
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
      OutlinedButton.icon(
        onPressed: hasNext ? () => onPageChanged(page + 1) : null,
        iconAlignment: IconAlignment.end,
        icon: const Icon(Icons.chevron_right),
        label: Text(context.l10n.nextPage),
      ),
    ],
  );
}
