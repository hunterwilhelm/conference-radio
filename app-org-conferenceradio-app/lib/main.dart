import 'package:conference_radio_flutter/page_manager.dart';
import 'package:conference_radio_flutter/providers/locale_provider.dart';
import 'package:conference_radio_flutter/routes.dart';
import 'package:conference_radio_flutter/services/service_locator.dart';
import 'package:conference_radio_flutter/share_preferences_keys.dart';
import 'package:conference_radio_flutter/ui/bookmarks_page.dart';
import 'package:conference_radio_flutter/ui/filter_page.dart';
import 'package:conference_radio_flutter/ui/home_page.dart';
import 'package:conference_radio_flutter/ui/language_page.dart';
import 'package:conference_radio_flutter/ui/welcome_begin_page.dart';
import 'package:conference_radio_flutter/utils/locales.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  await setupServiceLocator();
  final sharedPreferences = await SharedPreferences.getInstance();
  final welcomeScreenDismissed = sharedPreferences.getBool(SharedPreferencesKeys.welcomeScreenDismissed) == true;
  runApp(MyApp(welcomeScreenDismissed));
}

class MyApp extends StatefulHookWidget {
  final bool welcomeScreenDismissed;
  const MyApp(this.welcomeScreenDismissed, {super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    getIt<PageManager>().init();
  }

  @override
  void dispose() {
    getIt<PageManager>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = useMemoized(() => AppRouter().router(context, widget.welcomeScreenDismissed), []);
    final localeProvider = useMemoized(() => LocaleProvider(), []);
    useEffect(() {
      listener() {
        try {
          final lang = localeToLang[localeProvider.locale?.languageCode];
          if (lang == null) return;
          getIt<PageManager>().setLang(lang);
        } catch (e) {
          // pass
        }
      }

      localeProvider.addListener(listener);
      return () => localeProvider.removeListener(listener);
    }, []);
    return ChangeNotifierProvider.value(
      value: localeProvider,
      child: Consumer<LocaleProvider>(builder: (context, localProv, child) {
        return MaterialApp.router(
          locale: localProv.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(fontFamily: 'REM'),
          routerConfig: router,
        );
      }),
    );
  }
}

class AppRouter {
  GoRouter router(BuildContext context, bool welcomeScreenDismissed) {
    final router = GoRouter(
      initialLocation: welcomeScreenDismissed ? HomePage.route.path : WelcomeBeginPage.route.path,
      routes: [
        GoRoute(
          path: LanguagePage.route.path,
          builder: (context, state) => const LanguagePage(),
        ),
        GoRoute(
          path: WelcomeBeginPage.route.path,
          builder: (context, state) => const WelcomeBeginPage(),
        ),
        GoRoute(
          path: HomePage.route.path,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: FilterPage.route.path,
          builder: (context, state) => const FilterPage(),
        ),
        GoRoute(
          path: BookmarksPage.route.path,
          builder: (context, state) => const BookmarksPage(),
        ),
      ],
    );
    return router;
  }
}
