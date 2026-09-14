import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  final tokenStorage = TokenStorage();
  late final AuthProvider authProvider;
  final apiClient = ApiClient(
    tokenStorage: tokenStorage,
    onUnauthorized: () => authProvider.handleUnauthorized(),
  );
  authProvider = AuthProvider(AuthService(apiClient), tokenStorage);
  final localeProvider = await LocaleProvider.load();
  await authProvider.restoreSession();

  runApp(
    RetailRevenueApp(
      apiClient: apiClient,
      authProvider: authProvider,
      localeProvider: localeProvider,
    ),
  );
}
