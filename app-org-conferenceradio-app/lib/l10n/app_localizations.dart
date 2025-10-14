import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// No description provided for @welcomeToConferenceRadio.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nConference Radio'**
  String get welcomeToConferenceRadio;

  /// No description provided for @enjoyTalks.
  ///
  /// In en, this message translates to:
  /// **'Enjoy talks from General Conference '**
  String get enjoyTalks;

  /// No description provided for @onShuffle.
  ///
  /// In en, this message translates to:
  /// **'on shuffle'**
  String get onShuffle;

  /// No description provided for @pressPlayToBegin.
  ///
  /// In en, this message translates to:
  /// **'Press play to begin'**
  String get pressPlayToBegin;

  /// No description provided for @aprilLong.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get aprilLong;

  /// No description provided for @aprilShort.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get aprilShort;

  /// No description provided for @octoberLong.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get octoberLong;

  /// No description provided for @octoberShort.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get octoberShort;

  /// No description provided for @pageTitleLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get pageTitleLanguage;

  /// No description provided for @pageTitleFilter.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get pageTitleFilter;

  /// No description provided for @pageTitleLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get pageTitleLibrary;

  /// No description provided for @contextMenuOptionReportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a bug'**
  String get contextMenuOptionReportBug;

  /// No description provided for @contextMenuOptionRequestFeature.
  ///
  /// In en, this message translates to:
  /// **'Request a feature'**
  String get contextMenuOptionRequestFeature;

  /// No description provided for @bookmarkSavedOn.
  ///
  /// In en, this message translates to:
  /// **'Saved on'**
  String get bookmarkSavedOn;

  /// No description provided for @bookmarkActionOpenInGospelLibrary.
  ///
  /// In en, this message translates to:
  /// **'Open in Gospel Library'**
  String get bookmarkActionOpenInGospelLibrary;

  /// No description provided for @bookmarkActionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get bookmarkActionShare;

  /// No description provided for @bookmarkActionRemoveBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove Bookmark'**
  String get bookmarkActionRemoveBookmark;

  /// No description provided for @fromInContextOfFromDateToDate.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get fromInContextOfFromDateToDate;

  /// No description provided for @toInContextOfFromDateToDate.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get toInContextOfFromDateToDate;

  /// No description provided for @filterBySpeaker.
  ///
  /// In en, this message translates to:
  /// **'Filter by Speaker'**
  String get filterBySpeaker;

  /// No description provided for @filterBetweenDates.
  ///
  /// In en, this message translates to:
  /// **'Filter Between Dates'**
  String get filterBetweenDates;

  /// No description provided for @searchForSpeakerPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search for a speaker'**
  String get searchForSpeakerPlaceholder;

  /// No description provided for @speakerNoResultsHelpMessage.
  ///
  /// In en, this message translates to:
  /// **'Looking for someone else? Try disabling your date filter.'**
  String get speakerNoResultsHelpMessage;

  /// A plural message
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No talks available} =1{1 talk available} other{{count} talks available}}'**
  String nTalksAvailable(num count);

  /// No description provided for @playingFrom.
  ///
  /// In en, this message translates to:
  /// **'PLAYING FROM'**
  String get playingFrom;

  /// No description provided for @sessionSaturdayMorning.
  ///
  /// In en, this message translates to:
  /// **'Saturday{breakingChar}Morning{breakingChar}Session'**
  String sessionSaturdayMorning(String breakingChar);

  /// No description provided for @sessionSaturdayAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Saturday{breakingChar}Afternoon{breakingChar}Session'**
  String sessionSaturdayAfternoon(String breakingChar);

  /// No description provided for @sessionSaturdayEvening.
  ///
  /// In en, this message translates to:
  /// **'Saturday{breakingChar}Evening{breakingChar}Session'**
  String sessionSaturdayEvening(String breakingChar);

  /// No description provided for @sessionSundayMorning.
  ///
  /// In en, this message translates to:
  /// **'Sunday{breakingChar}Morning{breakingChar}Session'**
  String sessionSundayMorning(String breakingChar);

  /// No description provided for @sessionSundayAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Sunday{breakingChar}Afternoon{breakingChar}Session'**
  String sessionSundayAfternoon(String breakingChar);

  /// No description provided for @sessionPriesthood.
  ///
  /// In en, this message translates to:
  /// **'Priesthood{breakingChar}Session'**
  String sessionPriesthood(String breakingChar);

  /// No description provided for @sessionWelfare.
  ///
  /// In en, this message translates to:
  /// **'General{breakingChar}Welfare{breakingChar}Session'**
  String sessionWelfare(String breakingChar);

  /// No description provided for @sessionMidweek.
  ///
  /// In en, this message translates to:
  /// **'A{breakingChar}Midweek{breakingChar}Session'**
  String sessionMidweek(String breakingChar);

  /// No description provided for @sessionWomens.
  ///
  /// In en, this message translates to:
  /// **'Women\'\'s{breakingChar}Session'**
  String sessionWomens(String breakingChar);

  /// No description provided for @sessionYoungWomen.
  ///
  /// In en, this message translates to:
  /// **'General Young{breakingChar}Women{breakingChar}Meeting'**
  String sessionYoungWomen(String breakingChar);

  /// No description provided for @sessionBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Special{breakingChar}Broadcast'**
  String sessionBroadcast(String breakingChar);

  /// No description provided for @sessionFireside.
  ///
  /// In en, this message translates to:
  /// **'Fireside'**
  String get sessionFireside;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @pickConference.
  ///
  /// In en, this message translates to:
  /// **'Pick Conference'**
  String get pickConference;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
