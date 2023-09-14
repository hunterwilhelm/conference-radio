import 'package:conference_radio_flutter/services/talks_db_service.dart';

getChurchLinkFromTalk(Talk talk) {
  return "https://www.churchofjesuschrist.org${talk.baseUri}?lang=${talk.lang}";
}
