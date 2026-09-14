import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:retail_revenue_manager/core/routing/app_router.dart';
import 'package:retail_revenue_manager/core/storage/token_storage.dart';
import 'package:retail_revenue_manager/l10n/l10n.dart';
import 'package:retail_revenue_manager/models/retail_models.dart';
import 'package:retail_revenue_manager/providers/auth_provider.dart';
import 'package:retail_revenue_manager/providers/locale_provider.dart';
import 'package:retail_revenue_manager/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('protected deep link redirects to login with return URL', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final auth = AuthProvider(_FakeAuthApi(), TokenStorage());
    await auth.restoreSession();
    final locale = await LocaleProvider.load();
    final router = createAppRouter(
      auth,
      initialLocation: '/products?search=coca',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: locale),
        ],
        child: MaterialApp.router(
          locale: locale.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/login');
    expect(
      router.routeInformationProvider.value.uri.queryParameters['from'],
      '/products?search=coca',
    );
    router.dispose();
  });

  testWidgets('unknown URL shows a real 404 page for authenticated user', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final auth = AuthProvider(
      _FakeAuthApi(),
      TokenStorage(),
      initialUser: const AppUser(
        id: 1,
        username: 'admin',
        fullName: 'Admin',
        role: 'admin',
      ),
    );
    final locale = await LocaleProvider.load();
    final router = createAppRouter(auth, initialLocation: '/khong-ton-tai');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: locale),
        ],
        child: MaterialApp.router(
          locale: locale.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('404'), findsOneWidget);
    expect(find.text('Trang bạn mở không tồn tại.'), findsOneWidget);
    router.dispose();
  });
}

class _FakeAuthApi implements AuthApi {
  @override
  Future<AppUser> currentUser() async =>
      const AppUser(id: 1, username: 'admin', fullName: 'Admin', role: 'admin');

  @override
  Future<String> login(String username, String password) async => 'token';
}
