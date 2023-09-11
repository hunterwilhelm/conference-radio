import 'package:conference_radio_flutter/routes.dart';
import 'package:conference_radio_flutter/ui/bookmarks_page.dart';
import 'package:conference_radio_flutter/ui/filter_page.dart';
import 'package:conference_radio_flutter/ui/home_page.dart';
import 'package:conference_radio_flutter/ui/welcome_begin_page.dart';
import 'package:conference_radio_flutter/ui/welcome_language_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import 'page_manager.dart';
import 'services/service_locator.dart';

void main() async {
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulHookWidget {
  const MyApp({super.key});

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
    final router = useMemoized(() => AppRouter().router(context), []);
    return MaterialApp.router(
      theme: ThemeData(fontFamily: 'REM'),
      routerConfig: router,
    );
  }
}

class AppRouter {
  GoRouter router(BuildContext context) {
    final router = GoRouter(
      initialLocation: HomePage.route.path,
      routes: [
        GoRoute(
          path: WelcomeLanguagePage.route.path,
          builder: (context, state) => const WelcomeLanguagePage(),
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
