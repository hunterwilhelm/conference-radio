import 'package:flutter/material.dart';
import 'package:conference_radio_flutter/l10n/app_localizations.dart';

AppLocalizations tr(BuildContext context) {
  return AppLocalizations.of(context)!;
}

String trSession(BuildContext context, String sessionKey, [breakingChar = " "]) {
  return switch (sessionKey) {
    "saturday-morning" => tr(context).sessionSaturdayMorning(breakingChar),
    "saturday-afternoon" => tr(context).sessionSaturdayAfternoon(breakingChar),
    "saturday-evening" => tr(context).sessionSaturdayEvening(breakingChar),
    "sunday-morning" => tr(context).sessionSundayMorning(breakingChar),
    "sunday-afternoon" => tr(context).sessionSundayAfternoon(breakingChar),
    "priesthood" => tr(context).sessionPriesthood(breakingChar),
    "welfare" => tr(context).sessionWelfare(breakingChar),
    "midweek" => tr(context).sessionMidweek(breakingChar),
    "women's" => tr(context).sessionWomens(breakingChar),
    "young-women" => tr(context).sessionYoungWomen(breakingChar),
    "broadcast" => tr(context).sessionBroadcast(breakingChar),
    "fireside" => tr(context).sessionFireside,
    _ => sessionKey,
  };
}

const langToLocale = {
  "eng": "en",
  "spa": "es",
  "por": "pt",
};

const localeToLang = {
  "en": "eng",
  "es": "spa",
  "pt": "por",
};
