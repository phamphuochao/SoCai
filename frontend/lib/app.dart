import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/design_system/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/routing/app_router.dart';
import 'l10n/l10n.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';

class RetailRevenueApp extends StatefulWidget {
  const RetailRevenueApp({
    super.key,
    required this.apiClient,
    required this.authProvider,
    required this.localeProvider,
  });

  final ApiClient apiClient;
  final AuthProvider authProvider;
  final LocaleProvider localeProvider;

  @override
  State<RetailRevenueApp> createState() => _RetailRevenueAppState();
}

class _RetailRevenueAppState extends State<RetailRevenueApp> {
  late final router = createAppRouter(widget.authProvider);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: widget.apiClient),
        ChangeNotifierProvider<AuthProvider>.value(value: widget.authProvider),
        ChangeNotifierProvider<LocaleProvider>.value(
          value: widget.localeProvider,
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) => MaterialApp.router(
          onGenerateTitle: (context) => context.l10n.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: localeProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
        ),
      ),
    );
  }
}
