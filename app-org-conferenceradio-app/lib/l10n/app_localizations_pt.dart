// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get welcomeToConferenceRadio => 'Bem-vindo a\nConference Radio';

  @override
  String get enjoyTalks => 'Aproveite os discursos da Conferência Geral ';

  @override
  String get onShuffle => 'em modo aleatório';

  @override
  String get pressPlayToBegin => 'Pressione \"play\" para iniciar';

  @override
  String get aprilLong => 'abril';

  @override
  String get aprilShort => 'abr';

  @override
  String get octoberLong => 'outubro';

  @override
  String get octoberShort => 'out';

  @override
  String get pageTitleLanguage => 'Linguagem';

  @override
  String get pageTitleFilter => 'Filtros';

  @override
  String get pageTitleLibrary => 'Biblioteca';

  @override
  String get contextMenuOptionReportBug => 'Reportar um erro';

  @override
  String get contextMenuOptionRequestFeature => 'Solicitar uma funcionalidade';

  @override
  String get bookmarkSavedOn => 'Salvou';

  @override
  String get bookmarkActionOpenInGospelLibrary =>
      'Abrir na Biblioteca do Evangelho';

  @override
  String get bookmarkActionShare => 'Compartilhar';

  @override
  String get bookmarkActionRemoveBookmark => 'Excluir favorito';

  @override
  String get fromInContextOfFromDateToDate => 'de';

  @override
  String get toInContextOfFromDateToDate => 'a';

  @override
  String get filterBySpeaker => 'Filtrar Por Orador';

  @override
  String get filterBetweenDates => 'Filtrar entre datas';

  @override
  String get searchForSpeakerPlaceholder => 'Procurar por um orador';

  @override
  String get speakerNoResultsHelpMessage =>
      'Procurando por outra pessoa? Tente desativar seu filtro de data.';

  @override
  String nTalksAvailable(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString discursos disponíveis',
      one: '1 discurso disponível',
      zero: 'Nenhum discurso disponível',
    );
    return '$_temp0';
  }

  @override
  String get playingFrom => 'JOGANDO DE';

  @override
  String sessionSaturdayMorning(String breakingChar) {
    return 'manhã${breakingChar}de${breakingChar}sábado';
  }

  @override
  String sessionSaturdayAfternoon(String breakingChar) {
    return 'tarde${breakingChar}de${breakingChar}sábado';
  }

  @override
  String sessionSaturdayEvening(String breakingChar) {
    return 'noite${breakingChar}de${breakingChar}sábado';
  }

  @override
  String sessionSundayMorning(String breakingChar) {
    return 'manhã${breakingChar}de${breakingChar}domingo';
  }

  @override
  String sessionSundayAfternoon(String breakingChar) {
    return 'tarde${breakingChar}de${breakingChar}domingo';
  }

  @override
  String sessionPriesthood(String breakingChar) {
    return 'geral${breakingChar}do${breakingChar}sacerdocio';
  }

  @override
  String sessionWelfare(String breakingChar) {
    return 'Sessão${breakingChar}de bem-estar${breakingChar}geral';
  }

  @override
  String sessionMidweek(String breakingChar) {
    return 'Uma sessão${breakingChar}no meio${breakingChar}da semana';
  }

  @override
  String sessionWomens(String breakingChar) {
    return 'Sessão${breakingChar}de${breakingChar}mulheres';
  }

  @override
  String sessionYoungWomen(String breakingChar) {
    return 'Assembleia${breakingChar}geral de${breakingChar}jovens';
  }

  @override
  String sessionBroadcast(String breakingChar) {
    return 'Transmissão${breakingChar}especial';
  }

  @override
  String get sessionFireside => 'Fireside';

  @override
  String get loading => 'Carregando...';

  @override
  String get pickConference => 'Elija conferencia';

  @override
  String get select => 'Seleccionar';
}
