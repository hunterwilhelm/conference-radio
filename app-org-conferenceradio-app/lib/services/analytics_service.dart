import 'package:conference_radio_flutter/notifiers/filter_notifier.dart';
import 'package:conference_radio_flutter/services/talks_db_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  logNext(bool shuffle) {
    analytics.logEvent(name: "player_next", parameters: {"shuffle": shuffle ? 1 : 0});
  }

  logPrevious(bool shuffle) {
    analytics.logEvent(name: "player_previous", parameters: {"shuffle": shuffle ? 1 : 0});
  }

  logFilterChange(Filter filter) {
    analytics.logEvent(name: "filter_change", parameters: filter.toJson());
  }

  logLanguageChange(String lang) {
    analytics.logEvent(name: "language_change", parameters: {"lang": lang});
  }

  logAddBookmark(Talk talk) {
    analytics.logEvent(name: "bookmark", parameters: {"talk": talk.toMap(), "action": "add"});
  }

  logRemoveBookmark(Talk talk) {
    analytics.logEvent(name: "bookmark", parameters: {"talk": talk.toMap(), "action": "remove"});
  }

  logOpenInGospelLibrary(Talk talk) {
    analytics.logEvent(name: "open_in_gospel_library", parameters: {"talk": talk.toMap()});
  }

  logShareTalk(Talk talk) {
    analytics.logEvent(name: "share_talk", parameters: {"talk": talk.toMap()});
  }
}
