import 'package:conference_radio_flutter/services/talks_db_service.dart';

const sessionTranslations = {
  "saturday-morning": "Saturday Morning Session",
  "saturday-afternoon": "Saturday Afternoon Session",
  "saturday-evening": "Saturday Evening Session",
  "sunday-morning": "Sunday Morning Session",
  "sunday-afternoon": "Sunday Afternoon Session",
  "priesthood": "Priesthood Session",
  "welfare": "General Welfare Session",
  "midweek": "A Midweek Session",
  "women's": "Women's Session",
  "young-women": "General Young Women Meeting",
  "broadcast": "Special Broadcast",
  "fireside": "Fireside",
};

getChurchLinkFromTalk(Talk talk) {
  return "https://www.churchofjesuschrist.org${talk.baseUri}?lang=${talk.lang}";
}
