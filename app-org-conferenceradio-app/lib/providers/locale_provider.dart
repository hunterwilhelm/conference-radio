import 'package:conference_radio_flutter/services/analytics_service.dart';
import 'package:conference_radio_flutter/services/service_locator.dart';
import 'package:conference_radio_flutter/share_preferences_keys.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider() {
    _restoreFromMemory();
  }

  _restoreFromMemory() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final localeLanguageCode = sharedPreferences.getString(SharedPreferencesKeys.localeLanguageCode);
    if (localeLanguageCode == null) return;
    if (!AppLocalizations.supportedLocales.map((v) => v.languageCode).contains(localeLanguageCode)) return;
    set(Locale(localeLanguageCode));
  }

  Locale? _locale;

  Locale? get locale => _locale;

  void set(Locale locale) {
    _locale = locale;
    notifyListeners();
    getIt<AnalyticsService>().logLanguageChange(locale.languageCode);
  }
}
