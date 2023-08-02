import 'package:audio_service/audio_service.dart';
import 'package:conference_radio_flutter/services/talks_db_service.dart';
import 'package:conference_radio_flutter/ui/filter_page.dart';
import 'package:flutter/foundation.dart';

import 'notifiers/filter_notifier.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';
import 'services/playlist_repository.dart';
import 'services/service_locator.dart';

class PageManager {
  // Listeners: Updates going to the UI
  final currentTalkNotifier = ValueNotifier<Talk?>(null);
  final filterNotifier = FilterNotifier();
  final playlistNotifier = ValueNotifier<List<Talk>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

  final _audioHandler = getIt<AudioHandler>();

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
    for (var _ in Iterable.generate(3)) {
      await add();
    }
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
      final prev = currentTalkNotifier.value;
      if (mediaItem != null) {
        currentTalkNotifier.value = playlistNotifier.value.firstWhere((element) => element.talkId.toString() == mediaItem.id);
      }
      final index = _audioHandler.queue.value.indexWhere((element) => element.id == mediaItem?.id);
      if (prev != currentTalkNotifier.value && index >= _audioHandler.queue.value.length - 2) {
        add();
      }
      _updateSkipButtons();
    });
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void previous() => _audioHandler.skipToPrevious();
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
    remove();
    remove();
    await add();
    await add();
  }

  Future<void> add() async {
    final songRepository = getIt<PlaylistRepository>();
    final prevTalk = _audioHandler.queue.value.isEmpty ? null : _audioHandler.queue.value.last;
    final shuffled = isShuffleModeEnabledNotifier.value;
    final talk = await songRepository.fetchNextTalk(
      idForSequential: shuffled ? null : prevTalk?.id,
      filter: filterNotifier.value,
    );
    if (talk == null) {
      return;
    }
    final mediaItem = MediaItem(
      id: talk.talkId.toString(),
      album: talk.year.toString(),
      artist: talk.name,
      title: talk.title,
      extras: {'url': talk.mp3},
      artUri: Uri.tryParse('https://www.conferenceradio.app/app_data/notification_icon.png'),
    );
    _audioHandler.addQueueItem(mediaItem);
    playlistNotifier.value = [...playlistNotifier.value, talk];
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

  void stop() {
    _audioHandler.stop();
  }

  void updateFilterStart(YearMonth newYearMonth) {
    filterNotifier.value = Filter(newYearMonth, filterNotifier.value.end);
  }

  void updateFilterEnd(YearMonth newYearMonth) {
    filterNotifier.value = Filter(filterNotifier.value.start, newYearMonth);
  }
}
