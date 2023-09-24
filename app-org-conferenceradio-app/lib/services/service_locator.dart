import 'package:conference_radio_flutter/services/analytics_service.dart';
import 'package:get_it/get_it.dart';

import '../page_manager.dart';
import 'audio_handler.dart';
import 'talk_repository.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // services
  getIt.registerSingleton<MyAudioHandler>(await initAudioService());
  getIt.registerLazySingleton<TalkRepository>(() => TalkRepository());

  // page state
  getIt.registerLazySingleton<PageManager>(() => PageManager());
  getIt.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
}
