import 'package:flutter/material.dart';

import '../../core/adaptive/app_breakpoints.dart';

class ResponsiveDataView extends StatelessWidget {
  const ResponsiveDataView({
    super.key,
    required this.desktop,
    required this.compactItems,
    this.switchWidth = AppBreakpoints.medium,
  });

  final Widget desktop;
  final List<Widget> compactItems;
  final double switchWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= switchWidth) return desktop;
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: compactItems.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, index) => compactItems[index],
      );
    },
  );
}
