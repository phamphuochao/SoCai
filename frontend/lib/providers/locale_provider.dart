import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider._(this._locale) {
    Intl.defaultLocale = _locale.toLanguageTag();
  }

  static const _storageKey = 'retail_locale';
  static const _fallback = Locale('vi');
  static const supportedLanguageCodes = {'vi', 'en'};

  Locale _locale;

  Locale get locale => _locale;

  static Future<LocaleProvider> load() async {
    final saved = (await SharedPreferences.getInstance()).getString(
      _storageKey,
    );
    final locale = supportedLanguageCodes.contains(saved)
        ? Locale(saved!)
        : _fallback;
    return LocaleProvider._(locale);
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLanguageCodes.contains(locale.languageCode) ||
        locale.languageCode == _locale.languageCode) {
      return;
    }
    _locale = Locale(locale.languageCode);
    Intl.defaultLocale = _locale.toLanguageTag();
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString(
      _storageKey,
      _locale.languageCode,
    );
  }
}
