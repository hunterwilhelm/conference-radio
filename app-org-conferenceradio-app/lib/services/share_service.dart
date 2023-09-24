import 'package:conference_radio_flutter/services/analytics_service.dart';
import 'package:conference_radio_flutter/services/service_locator.dart';
import 'package:conference_radio_flutter/services/talks_db_service.dart';
import 'package:conference_radio_flutter/utils/get_church_link_from_talk.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareService {
  ShareService._();

  static void shareTalk(Talk talk) {
    Share.share(getChurchLinkFromTalk(talk));
    getIt<AnalyticsService>().logShareTalk(talk);
  }

  static void openTalkInGospelLibrary(Talk talk) {
    final url = Uri.parse(getChurchLinkFromTalk(talk));
    launchUrl(url, mode: LaunchMode.externalApplication);
    getIt<AnalyticsService>().logOpenInGospelLibrary(talk);
  }
}
