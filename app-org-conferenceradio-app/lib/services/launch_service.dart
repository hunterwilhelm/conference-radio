import 'package:conference_radio_flutter/services/analytics_service.dart';
import 'package:conference_radio_flutter/services/service_locator.dart';
import 'package:conference_radio_flutter/services/talks_db_service.dart';
import 'package:conference_radio_flutter/utils/get_church_link_from_talk.dart';
import 'package:conference_radio_flutter/utils/uri.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchService {
  LaunchService._();

  static void shareTalk(Talk talk) {
    Share.share(getChurchLinkFromTalk(talk));
    getIt<AnalyticsService>().logShareTalk(talk);
  }

  static void openTalkInGospelLibrary(Talk talk) {
    final url = Uri.parse(getChurchLinkFromTalk(talk));
    launchUrl(url, mode: LaunchMode.externalApplication);
    getIt<AnalyticsService>().logOpenInGospelLibrary(talk);
  }

  static void openEmailForBugReport() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support+conferenceradio@hntr.io',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Bug Report',
        'body': 'Include any screenshots or screen recordings that you think are necessary.\n\n\n\n\n\n\nVersion: ${packageInfo.version}',
      }),
    );
    launchUrl(emailLaunchUri);
  }

  static void openEmailForFeatureRequest() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support+conferenceradio@hntr.io',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Feature Request',
      }),
    );
    launchUrl(emailLaunchUri);
  }
}
