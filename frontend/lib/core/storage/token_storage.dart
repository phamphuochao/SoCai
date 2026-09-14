import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'retail_access_token';

  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(_tokenKey);

  Future<void> write(String token) async {
    await (await SharedPreferences.getInstance()).setString(_tokenKey, token);
  }

  Future<void> clear() async {
    await (await SharedPreferences.getInstance()).remove(_tokenKey);
  }
}
