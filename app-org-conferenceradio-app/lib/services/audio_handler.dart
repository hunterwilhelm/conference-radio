import 'dart:async';
import 'dart:math' show max, min;

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'org.conferenceradio.app.audio',
      androidNotificationChannelName: 'Conference Radio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class PlaylistManager {
  final _player = AudioPlayer();
  final _audioSource = ConcatenatingAudioSource(children: []);

  /// Shuffle indexes to pull from
  final List<int> _shuffleIndexes = [];

  /// The full list of media items to pull from
  final List<MediaItem> _fullPlaylist = [];

  /// Change this if you want the index to not start at the beginning
  static const kDefaultIndex = 0;

  /// Used for cleaning up the subscriptions when disposed
  final List<StreamSubscription> _streamSubscriptions = [];

  bool _ignoreIndexChangedOnce = true;

  /// Used for keeping track of both shuffled and normal order
  int _currentIndex = kDefaultIndex;
  int get currentIndex => _currentIndex;

  // PUBLIC VARS / GETTERS

  /// Notifies the system of the current media item
  final BehaviorSubject<MediaItem> mediaItem = BehaviorSubject();

  /// Use this to get the live data of what the state is of the player
  ///
  /// Don't perform actions like skip on this object because there is extra logic
  /// attached to the functions in this class. For example, use [seekToNext] instead of [player.seekToNext]
  AudioPlayer get player => _player;

  /// The index of the next item to be played
  int get nextIndex => _getRelativeIndex(1);

  /// The index of the previous item in play order
  int get previousIndex => _getRelativeIndex(-1);

  PlaylistManager() {
    _attachAudioSourceToPlayer();
    _listenForCurrentSongIndexChanges();
  }

  Future<void> _attachAudioSourceToPlayer() async {
    try {
      await _player.setAudioSource(_audioSource);
    } catch (e) {
      print("Error: $e");
    }
  }

  void _listenForCurrentSongIndexChanges() {
    _streamSubscriptions.add(_player.currentIndexStream.listen((index) {
      if (index == null) return;
      if (_ignoreIndexChangedOnce) {
        _ignoreIndexChangedOnce = false;
      } else {
        _updatePlayer();
      }
    }));
  }

  /// Used for loading the tracks. This will reset the current index and position.
  setQueue(List<MediaItem> mediaItems) async {
    _fullPlaylist.clear();
    _fullPlaylist.addAll(mediaItems);
    _currentIndex = 0;
    await _updatePlayer();
  }

  /// Use this instead of [player.seekToNext]
  Future<void> seekToNext() async {
    _ignoreIndexChangedOnce = true;
    await _updatePlayer(offset: 1);
  }

  /// Use this instead of [player.seekToPrevious]
  Future<void> seekToPrevious() async {
    _ignoreIndexChangedOnce = true;
    await _updatePlayer(offset: -1);
  }

  int _getRelativeIndex(int offset) {
    return max(0, min(currentIndex + offset, _fullPlaylist.length - 1));
  }

  Future<void> _updatePlayer({int offset = 0}) async {
    final newIndex = max(0, min(offset + _currentIndex, _fullPlaylist.length - 1));
    if (newIndex == currentIndex && _audioSource.length != 0) return;
    _currentIndex = newIndex;

    final newMediaItemCurrent = _fullPlaylist[_getRelativeIndex(0)];
    final newMediaItemNext = _fullPlaylist[_getRelativeIndex(1)];

    mediaItem.add(newMediaItemCurrent);
    if (_audioSource.length == 0) {
      await _audioSource.add(_createAudioSource(newMediaItemCurrent));
    }

    if (_player.currentIndex == _audioSource.length - 1) {
      await _audioSource.add(_createAudioSource(newMediaItemNext));
    }

    if (offset == 1) {
      await _player.seekToNext();
    } else if (offset == -1) {
      await _player.seekToPrevious();
    }
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.parse(mediaItem.extras!['url'] as String),
      tag: mediaItem,
    );
  }

  Future<void> dispose() async {
    for (final subscription in _streamSubscriptions) {
      await subscription.cancel();
    }
    _streamSubscriptions.clear();
    return _player.dispose();
  }
}

class MyAudioHandler extends BaseAudioHandler {
  final _playlistManager = PlaylistManager();
  final List<StreamSubscription> _streamSubscriptions = [];

  MyAudioHandler() {
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _streamSubscriptions.add(_playlistManager.player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _playlistManager.player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_playlistManager.player.processingState]!,
        repeatMode: const {
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_playlistManager.player.loopMode]!,
        shuffleMode: (_playlistManager.player.shuffleModeEnabled) ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
        playing: playing,
        updatePosition: _playlistManager.player.position,
        bufferedPosition: _playlistManager.player.bufferedPosition,
        speed: _playlistManager.player.speed,
        queueIndex: event.currentIndex,
      ));
    }));
  }

  void _listenForDurationChanges() {
    _streamSubscriptions.add(_playlistManager.player.durationStream.listen((duration) {
      final oldMediaItem = _playlistManager.mediaItem.valueOrNull;
      if (oldMediaItem == null) return;
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      mediaItem.add(newMediaItem);
    }));
  }

  void _listenForCurrentSongIndexChanges() {
    _streamSubscriptions.add(_playlistManager.mediaItem.listen((newMediaItem) {
      final newMediaItemWithDuration = newMediaItem.copyWith(duration: _playlistManager.player.duration);
      mediaItem.add(newMediaItemWithDuration);
    }));
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    throw UnimplementedError("addQueueItems");
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    throw UnimplementedError("addQueueItem");
  }

  @override
  Future<void> updateQueue(List<MediaItem> mediaItems) async {
    // notify system
    final newQueue = mediaItems;
    queue.add(newQueue);
    _playlistManager.setQueue(mediaItems);
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    throw UnimplementedError("removeQueueItemAt");
  }

  @override
  Future<void> play() => _playlistManager.player.play();

  @override
  Future<void> pause() => _playlistManager.player.pause();

  @override
  Future<void> seek(Duration position) => _playlistManager.player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    throw UnimplementedError("skipToQueueItem");
  }

  @override
  Future<void> skipToNext() async {
    _playlistManager.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_playlistManager.player.position.inSeconds > 5 || _playlistManager.currentIndex == 0) {
      return _playlistManager.player.seek(Duration.zero);
    } else {
      return _playlistManager.seekToPrevious();
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    throw UnimplementedError("setRepeatMode");
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    throw UnimplementedError("setShuffleMode");
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      for (final subscription in _streamSubscriptions) {
        await subscription.cancel();
      }
      _streamSubscriptions.clear();

      await _playlistManager.dispose();
      super.stop();
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    stop();
    super.onTaskRemoved();
  }

  @override
  Future<void> stop() async {
    await _playlistManager.player.stop();
    return super.stop();
  }
}
