import 'package:flutter/widgets.dart';

import 'app_breakpoints.dart';

WindowSizeClass windowSizeClass(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < AppBreakpoints.compact) return WindowSizeClass.compact;
  if (width < AppBreakpoints.medium) return WindowSizeClass.medium;
  if (width < AppBreakpoints.expanded) return WindowSizeClass.expanded;
  if (width < AppBreakpoints.large) return WindowSizeClass.large;
  return WindowSizeClass.extraLarge;
}
