import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:collection/collection.dart';
import 'package:conference_radio_flutter/services/analytics_service.dart';
import 'package:conference_radio_flutter/services/audio_handler.dart';
import 'package:conference_radio_flutter/services/talks_db_service.dart';
import 'package:conference_radio_flutter/share_preferences_keys.dart';
import 'package:conference_radio_flutter/ui/filter_page.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notifiers/filter_notifier.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'services/service_locator.dart';
import 'services/talk_repository.dart';

class PageManager {
  // Listeners: Updates going to the UI
  final currentTalkNotifier = ValueNotifier<Talk?>(null);
  final currentBookmarkNotifier = ValueNotifier<bool>(false);
  final bookmarkListNotifier = ValueNotifier<List<Bookmark>>([]);
  final filterNotifier = FilterNotifier();
  final maxRangeNotifier = FilterNotifier();
  final playlistNotifier = ValueNotifier<List<Talk>>([]);
  final progressNotifier = ProgressNotifier();
  final playButtonNotifier = PlayButtonNotifier();
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  final langNotifier = ValueNotifier<String>("eng");

  final _audioHandler = getIt<MyAudioHandler>();
  final _talkRepository = getIt<TalkRepository>();

  // Events: Calls coming from the UI
  void init() async {
    await _loadPlaylist();
    _refreshBookmarks();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
  }

  Future<void> _loadPlaylist() async {
    refreshPlaylist(initialData: await getInitialPlayerData());
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading || processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      SharedPreferences.getInstance().then((sharedPreferences) {
        sharedPreferences.setInt(SharedPreferencesKeys.playerPositionInSeconds, position.inSeconds);
      });

      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem != null) {
        final talk = playlistNotifier.value.firstWhereOrNull((element) => element.talkId.toString() == mediaItem.id);
        currentTalkNotifier.value = talk;
        if (talk != null) {
          _talkRepository.getIsBookmarked(talk.talkId, lang: langNotifier.value).then((value) {
            currentBookmarkNotifier.value = value;
          });
        }
      }
    });
  }

  void _refreshBookmarks() async {
    bookmarkListNotifier.value = await _talkRepository.getBookmarkedTalks(lang: langNotifier.value);
  }

  void play() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    _audioHandler.play();
  }

  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void previous() {
    _audioHandler.skipToPrevious();
  }

  Future<void> next() => _audioHandler.skipToNext();

  Stream<bool> get hasNextStream => _audioHandler.hasNextStream;
  Stream<bool> get hasPreviousStream => _audioHandler.hasPreviousStream;

  void shuffle() async {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  Future<void> refreshPlaylist({InitialPlayerData? initialData}) async {
    final maxRange = await _talkRepository.getMaxRange(lang: langNotifier.value);
    maxRangeNotifier.value = maxRange;

    if (initialData != null) {
      final filter = initialData.filter;
      if (filter != null) {
        filterNotifier.value = filter;
      } else {
        filterNotifier.value = Filter(maxRange.end.previous().previous(), maxRange.end);
      }
      langNotifier.value = initialData.lang;
    }
    if (filterNotifier.value.start.isBefore(maxRange.start)) {
      filterNotifier.value = Filter(maxRange.start, filterNotifier.value.end);
    }
    if (filterNotifier.value.end.isAfter(maxRange.end)) {
      filterNotifier.value = Filter(filterNotifier.value.start, maxRange.end);
    }

    final talks = await _talkRepository.fetchTalkPlaylist(
      filter: filterNotifier.value,
      lang: langNotifier.value,
    );
    final talkMediaItems = [
      for (final talk in talks)
        MediaItem(
          id: talk.talkId.toString(),
          album: talk.year.toString(),
          artist: talk.name,
          title: talk.title,
          extras: {'url': talk.mp3},
          artUri: Uri.tryParse('https://www.conferenceradio.app/app_data/notification_icon.png'),
        ),
    ];
    final index = initialData == null ? null : talks.indexWhere((element) => element.talkId == initialData.talkId);
    await _audioHandler.setQueue(
      talkMediaItems,
      index: index == -1 ? null : index,
      position: initialData?.position,
      shuffled: initialData?.shuffled,
    );
    playlistNotifier.value = talks;
    if (initialData?.shuffled == true) {
      isShuffleModeEnabledNotifier.value = true;
    }
  }

  void remove() {
    final lastIndex = _audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    _audioHandler.removeQueueItemAt(lastIndex);
    playlistNotifier.value = [...playlistNotifier.value]..removeLast();
  }

  void dispose() {
    _audioHandler.customAction('dispose');
  }

  Future<void> stop() async {
    await _audioHandler.stop();
  }

  void updateFilterStart(YearMonth newYearMonth) {
    filterNotifier.value = Filter(newYearMonth, filterNotifier.value.end).asSorted();
    _saveFilter();
    refreshPlaylist();
  }

  void updateFilterEnd(YearMonth newYearMonth) {
    filterNotifier.value = Filter(filterNotifier.value.start, newYearMonth).asSorted();
    _saveFilter();
    refreshPlaylist();
  }

  void setLang(String lang) {
    SharedPreferences.getInstance().then((sharedPreferences) {
      sharedPreferences.setString(SharedPreferencesKeys.playerFilterLang, lang);
    });
    langNotifier.value = lang;
    refreshPlaylist();
  }

  void _saveFilter() {
    SharedPreferences.getInstance().then((sharedPreferences) {
      sharedPreferences.setInt(SharedPreferencesKeys.playerFilterStartYear, filterNotifier.value.start.year);
      sharedPreferences.setInt(SharedPreferencesKeys.playerFilterStartMonth, filterNotifier.value.start.month);
      sharedPreferences.setInt(SharedPreferencesKeys.playerFilterEndYear, filterNotifier.value.end.year);
      sharedPreferences.setInt(SharedPreferencesKeys.playerFilterEndMonth, filterNotifier.value.end.month);
    });
    getIt<AnalyticsService>().logFilterChange(filterNotifier.value);
  }

  void bookmark(bool bookmarked, [Talk? talk]) {
    final talk_ = talk ?? currentTalkNotifier.value;
    if (talk_ == null) return;
    final id = talk_.talkId;
    _talkRepository.saveBookmark(id, bookmarked, lang: langNotifier.value);
    currentBookmarkNotifier.value = bookmarked;
    _refreshBookmarks();
    if (bookmarked) {
      getIt<AnalyticsService>().logAddBookmark(talk_);
    } else {
      getIt<AnalyticsService>().logRemoveBookmark(talk_);
    }
  }
}

class InitialPlayerData {
  final Duration? position;
  final int? talkId;
  final Filter? filter;
  final bool? shuffled;
  final String lang;

  InitialPlayerData({
    required this.position,
    required this.talkId,
    required this.filter,
    required this.shuffled,
    required this.lang,
  });
}

Future<InitialPlayerData> getInitialPlayerData() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final talkId = sharedPreferences.getInt(SharedPreferencesKeys.playerTalkId);
  final playerShuffled = sharedPreferences.getBool(SharedPreferencesKeys.playerShuffled);
  final positionInSeconds = sharedPreferences.getInt(SharedPreferencesKeys.playerPositionInSeconds);
  final filterStartYear = sharedPreferences.getInt(SharedPreferencesKeys.playerFilterStartYear);
  final filterStartMonth = sharedPreferences.getInt(SharedPreferencesKeys.playerFilterStartMonth);
  final filterEndYear = sharedPreferences.getInt(SharedPreferencesKeys.playerFilterEndYear);
  final filterEndMonth = sharedPreferences.getInt(SharedPreferencesKeys.playerFilterEndMonth);
  final lang = sharedPreferences.getString(SharedPreferencesKeys.playerFilterLang) ?? "eng";
  Filter? filter;
  if (filterStartYear != null && filterStartMonth != null && filterEndYear != null && filterEndMonth != null) {
    filter = Filter(
      YearMonth(filterStartYear, filterStartMonth),
      YearMonth(filterEndYear, filterEndMonth),
    );
  }
  return InitialPlayerData(
    filter: filter,
    position: positionInSeconds == null ? null : Duration(seconds: positionInSeconds),
    talkId: talkId,
    shuffled: playerShuffled == true,
    lang: lang,
  );
}
