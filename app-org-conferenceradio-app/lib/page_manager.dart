import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:collection/collection.dart';
import 'package:conference_radio_flutter/services/talks_db_service.dart';
import 'package:conference_radio_flutter/ui/filter_page.dart';
import 'package:flutter/foundation.dart';

import 'notifiers/filter_notifier.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';
import 'services/talk_repository.dart';
import 'services/service_locator.dart';

class PageManager {
  // Listeners: Updates going to the UI
  final currentTalkNotifier = ValueNotifier<Talk?>(null);
  final currentBookmarkNotifier = ValueNotifier<bool>(false);
  final filterNotifier = FilterNotifier();
  final playlistNotifier = ValueNotifier<List<Talk>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

  final _audioHandler = getIt<AudioHandler>();
  final _songRepository = getIt<TalkRepository>();

  // Events: Calls coming from the UI
  void init() async {
    await _loadPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
  }

  Future<void> _loadPlaylist() async {
    await refreshPlaylist();
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
          _songRepository.getIsBookmarked(talk.talkId).then((value) {
            currentBookmarkNotifier.value = value;
          });
        }
      }
      _updateSkipButtons();
    });
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isLastSongNotifier.value = true;
    } else {
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
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

  void next() => _audioHandler.skipToNext();

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
  }

  void shuffle() async {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  Future<void> refreshPlaylist() async {
    final talks = await _songRepository.fetchTalkPlaylist(
      filter: filterNotifier.value,
    );
    final talkMediaItems = talks
        .map((talk) => MediaItem(
              id: talk.talkId.toString(),
              album: talk.year.toString(),
              artist: talk.name,
              title: talk.title,
              extras: {'url': talk.mp3},
              artUri: Uri.tryParse('https://www.conferenceradio.app/app_data/notification_icon.png'),
            ))
        .toList();
    await _audioHandler.updateQueue(talkMediaItems);
    playlistNotifier.value = talks;
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
    filterNotifier.value = Filter(newYearMonth, filterNotifier.value.end);
    refreshPlaylist();
  }

  void updateFilterEnd(YearMonth newYearMonth) {
    filterNotifier.value = Filter(filterNotifier.value.start, newYearMonth);
    refreshPlaylist();
  }

  void bookmark(bool bookmarked) {
    final id = currentTalkNotifier.value?.talkId;
    if (id == null) return;
    _songRepository.saveBookmark(id, bookmarked);
    currentBookmarkNotifier.value = bookmarked;
  }
}
