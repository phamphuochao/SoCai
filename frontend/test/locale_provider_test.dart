import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:retail_revenue_manager/components/language/language_menu.dart';
import 'package:retail_revenue_manager/l10n/l10n.dart';
import 'package:retail_revenue_manager/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('locale selection is restored and persisted', () async {
    SharedPreferences.setMockInitialValues({'retail_locale': 'en'});
    final provider = await LocaleProvider.load();

    expect(provider.locale, const Locale('en'));
    expect(Intl.defaultLocale, 'en');

    await provider.setLocale(const Locale('vi'));

    expect(provider.locale, const Locale('vi'));
    expect(Intl.defaultLocale, 'vi');
    expect(
      (await SharedPreferences.getInstance()).getString('retail_locale'),
      'vi',
    );
  });

  testWidgets('language menu updates visible translations', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = await LocaleProvider.load();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: Consumer<LocaleProvider>(
          builder: (context, locale, _) => MaterialApp(
            locale: locale.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Builder(
              builder: (context) => Scaffold(
                body: Column(
                  children: [
                    Text(context.l10n.dashboard),
                    const LanguageMenu(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Tổng quan'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.language_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
  });
}
