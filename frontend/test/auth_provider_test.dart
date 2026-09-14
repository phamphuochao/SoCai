import 'package:flutter_test/flutter_test.dart';
import 'package:retail_revenue_manager/core/storage/token_storage.dart';
import 'package:retail_revenue_manager/models/retail_models.dart';
import 'package:retail_revenue_manager/providers/auth_provider.dart';
import 'package:retail_revenue_manager/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const user = AppUser(
    id: 1,
    username: 'admin',
    fullName: 'Quản trị viên',
    role: 'admin',
  );

  test('restore token validates the current user and role', () async {
    SharedPreferences.setMockInitialValues({
      'retail_access_token': 'valid-token',
    });
    final provider = AuthProvider(_FakeAuthApi(user: user), TokenStorage());

    await provider.restoreSession();

    expect(provider.initialized, isTrue);
    expect(provider.isAuthenticated, isTrue);
    expect(provider.isAdmin, isTrue);
    expect(provider.user?.username, 'admin');
  });

  test('invalid restored token is cleared', () async {
    SharedPreferences.setMockInitialValues({
      'retail_access_token': 'expired-token',
    });
    final storage = TokenStorage();
    final provider = AuthProvider(
      _FakeAuthApi(user: user, failCurrentUser: true),
      storage,
    );

    await provider.restoreSession();

    expect(provider.isAuthenticated, isFalse);
    expect(await storage.read(), isNull);
  });
}

class _FakeAuthApi implements AuthApi {
  const _FakeAuthApi({required this.user, this.failCurrentUser = false});

  final AppUser user;
  final bool failCurrentUser;

  @override
  Future<AppUser> currentUser() async {
    if (failCurrentUser) throw Exception('expired');
    return user;
  }

  @override
  Future<String> login(String username, String password) async => 'valid-token';
}
