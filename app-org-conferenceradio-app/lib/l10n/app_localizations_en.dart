// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeToConferenceRadio => 'Welcome to\nConference Radio';

  @override
  String get enjoyTalks => 'Enjoy talks from General Conference ';

  @override
  String get onShuffle => 'on shuffle';

  @override
  String get pressPlayToBegin => 'Press play to begin';

  @override
  String get aprilLong => 'April';

  @override
  String get aprilShort => 'Apr';

  @override
  String get octoberLong => 'October';

  @override
  String get octoberShort => 'Oct';

  @override
  String get pageTitleLanguage => 'Language';

  @override
  String get pageTitleFilter => 'Filters';

  @override
  String get pageTitleLibrary => 'Library';

  @override
  String get contextMenuOptionReportBug => 'Report a bug';

  @override
  String get contextMenuOptionRequestFeature => 'Request a feature';

  @override
  String get bookmarkSavedOn => 'Saved on';

  @override
  String get bookmarkActionOpenInGospelLibrary => 'Open in Gospel Library';

  @override
  String get bookmarkActionShare => 'Share';

  @override
  String get bookmarkActionRemoveBookmark => 'Remove Bookmark';

  @override
  String get fromInContextOfFromDateToDate => 'from';

  @override
  String get toInContextOfFromDateToDate => 'to';

  @override
  String get filterBySpeaker => 'Filter by Speaker';

  @override
  String get filterBetweenDates => 'Filter Between Dates';

  @override
  String get searchForSpeakerPlaceholder => 'Search for a speaker';

  @override
  String get speakerNoResultsHelpMessage =>
      'Looking for someone else? Try disabling your date filter.';

  @override
  String nTalksAvailable(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString talks available',
      one: '1 talk available',
      zero: 'No talks available',
    );
    return '$_temp0';
  }

  @override
  String get playingFrom => 'PLAYING FROM';

  @override
  String sessionSaturdayMorning(String breakingChar) {
    return 'Saturday${breakingChar}Morning${breakingChar}Session';
  }

  @override
  String sessionSaturdayAfternoon(String breakingChar) {
    return 'Saturday${breakingChar}Afternoon${breakingChar}Session';
  }

  @override
  String sessionSaturdayEvening(String breakingChar) {
    return 'Saturday${breakingChar}Evening${breakingChar}Session';
  }

  @override
  String sessionSundayMorning(String breakingChar) {
    return 'Sunday${breakingChar}Morning${breakingChar}Session';
  }

  @override
  String sessionSundayAfternoon(String breakingChar) {
    return 'Sunday${breakingChar}Afternoon${breakingChar}Session';
  }

  @override
  String sessionPriesthood(String breakingChar) {
    return 'Priesthood${breakingChar}Session';
  }

  @override
  String sessionWelfare(String breakingChar) {
    return 'General${breakingChar}Welfare${breakingChar}Session';
  }

  @override
  String sessionMidweek(String breakingChar) {
    return 'A${breakingChar}Midweek${breakingChar}Session';
  }

  @override
  String sessionWomens(String breakingChar) {
    return 'Women\'\'s${breakingChar}Session';
  }

  @override
  String sessionYoungWomen(String breakingChar) {
    return 'General Young${breakingChar}Women${breakingChar}Meeting';
  }

  @override
  String sessionBroadcast(String breakingChar) {
    return 'Special${breakingChar}Broadcast';
  }

  @override
  String get sessionFireside => 'Fireside';

  @override
  String get loading => 'Loading...';

  @override
  String get pickConference => 'Pick Conference';

  @override
  String get select => 'Select';
}
