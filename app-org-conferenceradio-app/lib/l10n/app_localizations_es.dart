// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get welcomeToConferenceRadio => 'Bienvenido a\nConference Radio';

  @override
  String get enjoyTalks =>
      'Disfruta de los discursos de la Conferencia General ';

  @override
  String get onShuffle => 'en modo aleatorio';

  @override
  String get pressPlayToBegin => 'Presiona \"play\" para comenzar';

  @override
  String get aprilLong => 'abril';

  @override
  String get aprilShort => 'abr';

  @override
  String get octoberLong => 'octubre';

  @override
  String get octoberShort => 'oct';

  @override
  String get pageTitleLanguage => 'Idioma';

  @override
  String get pageTitleFilter => 'Filtros';

  @override
  String get pageTitleLibrary => 'Biblioteca';

  @override
  String get contextMenuOptionReportBug => 'Reportar un error';

  @override
  String get contextMenuOptionRequestFeature => 'Solicitar una función';

  @override
  String get bookmarkSavedOn => 'Guardado';

  @override
  String get bookmarkActionOpenInGospelLibrary =>
      'Abrir en la Biblioteca del Evangelio';

  @override
  String get bookmarkActionShare => 'Compartir';

  @override
  String get bookmarkActionRemoveBookmark => 'Eliminar marcador';

  @override
  String get fromInContextOfFromDateToDate => 'desde';

  @override
  String get toInContextOfFromDateToDate => 'hasta';

  @override
  String get filterBySpeaker => 'Filtrar Por Orador';

  @override
  String get filterBetweenDates => 'Filtrar entre fechas';

  @override
  String get searchForSpeakerPlaceholder => 'Buscar un orador';

  @override
  String get speakerNoResultsHelpMessage =>
      '¿Buscas a alguien más? Intenta desactivar tu filtro de fecha.';

  @override
  String nTalksAvailable(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString discursos disponibles',
      one: '1 discurso disponible',
      zero: 'No hay discursos disponibles',
    );
    return '$_temp0';
  }

  @override
  String get playingFrom => 'REPRODUCIENDO DESDE';

  @override
  String sessionSaturdayMorning(String breakingChar) {
    return 'sábado${breakingChar}por la${breakingChar}mañana';
  }

  @override
  String sessionSaturdayAfternoon(String breakingChar) {
    return 'sábado${breakingChar}por la${breakingChar}tarde';
  }

  @override
  String sessionSaturdayEvening(String breakingChar) {
    return 'sábado${breakingChar}por la${breakingChar}noche';
  }

  @override
  String sessionSundayMorning(String breakingChar) {
    return 'domingo${breakingChar}por la${breakingChar}mañana';
  }

  @override
  String sessionSundayAfternoon(String breakingChar) {
    return 'domingo${breakingChar}por la${breakingChar}tarde';
  }

  @override
  String sessionPriesthood(String breakingChar) {
    return 'Sesión${breakingChar}del${breakingChar}sacerdocio';
  }

  @override
  String sessionWelfare(String breakingChar) {
    return 'Sesión${breakingChar}del bienestar${breakingChar}general';
  }

  @override
  String sessionMidweek(String breakingChar) {
    return 'Una sesión${breakingChar}de mitad${breakingChar}de semana';
  }

  @override
  String sessionWomens(String breakingChar) {
    return 'Sesión${breakingChar}de${breakingChar}mujeres';
  }

  @override
  String sessionYoungWomen(String breakingChar) {
    return 'Reunión general${breakingChar}de${breakingChar}jóvenes mujeres';
  }

  @override
  String sessionBroadcast(String breakingChar) {
    return 'Transmisión${breakingChar}especial';
  }

  @override
  String get sessionFireside => 'Fireside';

  @override
  String get loading => 'Cargando...';

  @override
  String get pickConference => 'Escoger conferencia';

  @override
  String get select => 'Seleccionar';
}
