import 'package:flutter/foundation.dart';

import '../core/storage/token_storage.dart';
import '../models/retail_models.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authApi, this._storage, {AppUser? initialUser})
    : _user = initialUser;

  final AuthApi _authApi;
  final TokenStorage _storage;
  AppUser? _user;
  bool _busy = false;
  bool _initialized = false;
  String? _error;

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isBusy => _busy;
  bool get initialized => _initialized;
  String? get error => _error;

  Future<void> restoreSession() async {
    final token = await _storage.read();
    if (token != null && token.isNotEmpty) {
      try {
        _user = await _authApi.currentUser();
      } catch (_) {
        await _storage.clear();
        _user = null;
      }
    }
    _initialized = true;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final token = await _authApi.login(username, password);
      await _storage.write(token);
      _user = await _authApi.currentUser();
      return true;
    } catch (error) {
      await _storage.clear();
      _user = null;
      _error = error.toString();
      return false;
    } finally {
      _busy = false;
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.clear();
    _user = null;
    _error = null;
    notifyListeners();
  }

  Future<void> handleUnauthorized() async {
    if (_user == null && await _storage.read() == null) return;
    await _storage.clear();
    _user = null;
    notifyListeners();
  }
}
