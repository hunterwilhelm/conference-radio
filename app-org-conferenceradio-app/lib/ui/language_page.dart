import 'package:conference_radio_flutter/constants/style_list.dart';
import 'package:conference_radio_flutter/providers/locale_provider.dart';
import 'package:conference_radio_flutter/routes.dart';
import 'package:conference_radio_flutter/share_preferences_keys.dart';
import 'package:conference_radio_flutter/ui/widgets/custom_app_bar.dart';
import 'package:conference_radio_flutter/utils/locales.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePage extends StatelessWidget {
  static const route = Routes.languagePage;
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProv = Provider.of<LocaleProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    handleLanguageChange(String languageCode) async {
      localeProv.set(Locale(languageCode));
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setString(SharedPreferencesKeys.localeLanguageCode, languageCode);
      navigator.pop();
    }

    return Container(
      decoration: StyleList.backgroundGradient,
      child: Scaffold(
        appBar: CustomAppBar(title: tr(context).pageTitleLanguage),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                flex: 2,
                child: Center(
                  child: SizedBox(
                    height: 300,
                    child: Column(
                      children: [
                        Expanded(
                          child: TextButton(
                            label: 'English',
                            onClick: () async {
                              handleLanguageChange('en');
                            },
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            label: 'Español',
                            onClick: () {
                              handleLanguageChange('es');
                            },
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            label: 'Português',
                            onClick: () {
                              handleLanguageChange('pt');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Flexible(child: Container()),
            ],
          ),
        ),
      ),
    );
  }
}

class TextButton extends StatelessWidget {
  final String label;
  final void Function() onClick;
  const TextButton({
    super.key,
    required this.label,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClick();
      },
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 25.67,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.05,
            ),
          ),
        ),
      ),
    );
  }
}
