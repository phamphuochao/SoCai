import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/retail_models.dart';

abstract class AuthApi {
  Future<String> login(String username, String password);
  Future<AppUser> currentUser();
}

class AuthService implements AuthApi {
  const AuthService(this._api);

  final ApiClient _api;

  @override
  Future<String> login(String username, String password) async {
    final data = Map<String, dynamic>.from(
      await _api.post(
            '${ApiConstants.auth}/login',
            data: {'username': username, 'password': password},
          )
          as Map,
    );
    return data['access_token']?.toString() ?? '';
  }

  @override
  Future<AppUser> currentUser() async {
    final data = Map<String, dynamic>.from(
      await _api.get('${ApiConstants.auth}/me') as Map,
    );
    return AppUser.fromJson(data);
  }
}
