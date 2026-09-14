import 'package:flutter/material.dart';

import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_spacing.dart';

class PageContent extends StatelessWidget {
  const PageContent({super.key, required this.child, this.scrollable = true});

  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final horizontal = MediaQuery.sizeOf(context).width < 600
        ? AppSpacing.md
        : AppSpacing.lg;
    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.maxContentWidth,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontal,
            vertical: AppSpacing.lg,
          ),
          child: child,
        ),
      ),
    );
    return scrollable ? SingleChildScrollView(child: content) : content;
  }
}
