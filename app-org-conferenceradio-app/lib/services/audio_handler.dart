import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:collection/collection.dart';
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
  PlaylistManager() {
    _listenForEndOfSong();
  }

  _listenForEndOfSong() {
    _streamSubscriptions.add(_player.playbackEventStream.listen((playbackEvent) {
      if (playbackEvent.processingState == ProcessingState.completed && playbackEvent.updatePosition == _player.duration) {
        Future.microtask(() async {
          await seekToNext();
          await player.play();
        });
      }
    }));
  }

  final _player = AudioPlayer();
  final List<MediaItem> _playlist = [];
  int currentIndex = 0;
  AudioPlayer get player => _player;
  final BehaviorSubject<MediaItem> mediaItem = BehaviorSubject();
  final List<int> _shuffleIndices = [];
  final List<StreamSubscription> _streamSubscriptions = [];
  bool _shuffled = false;

  /// The index of the next item to be played, or `null` if there is no next
  /// item.
  int get nextIndex => _getRelativeIndex(1);

  /// The index of the previous item in play order, or `null` if there is no
  /// previous item.
  int get previousIndex => _getRelativeIndex(-1);

  int _getRelativeIndex(int offset) {
    return max(0, min(currentIndex + offset, _playlist.length - 1));
  }

  setPlaylist(List<MediaItem> mediaItems) {
    _playlist.clear();
    _playlist.addAll(mediaItems);
    setShuffled(_shuffled, true);
    _updatePlayer();
  }

  _updatePlayer() async {
    final finalIndex = _shuffled ? _shuffleIndices[currentIndex] : currentIndex;
    final newMediaItem = _playlist[finalIndex];
    mediaItem.add(newMediaItem);
    await _player.setAudioSource(_createAudioSource(newMediaItem));
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.parse(mediaItem.extras!['url'] as String),
      tag: mediaItem,
    );
  }

  Future<void> seekToNext() async {
    if (currentIndex != nextIndex) {
      currentIndex = nextIndex;
      await _updatePlayer();
    }
  }

  Future<void> seekToPrevious() async {
    if (currentIndex != previousIndex) {
      currentIndex = previousIndex;
      _updatePlayer();
    }
  }

  void setShuffled(bool newShuffled, [bool? force]) {
    if (newShuffled == _shuffled && force != true) return;
    if (newShuffled) {
      final indices = List.generate(_playlist.length, (index) => index).where((element) => element != currentIndex).toList();
      shuffle(indices);
      _shuffleIndices.clear();
      _shuffleIndices.addAll(indices..insert(0, currentIndex));
      currentIndex = 0;
    } else if (_shuffleIndices.isNotEmpty) {
      currentIndex = _shuffleIndices[currentIndex];
    } else {
      currentIndex = 0;
    }
    _shuffled = newShuffled;
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
  int index = 0;
  final _playlistManager = PlaylistManager();
  final List<StreamSubscription> streamSubscriptions = [];

  MyAudioHandler() {
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    streamSubscriptions.add(_playlistManager.player.playbackEventStream.listen((PlaybackEvent event) {
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
    streamSubscriptions.add(_playlistManager.player.durationStream.listen((duration) {
      final oldMediaItem = _playlistManager.mediaItem.valueOrNull;
      if (oldMediaItem == null) return;
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      mediaItem.add(newMediaItem);
    }));
  }

  void _listenForCurrentSongIndexChanges() {
    streamSubscriptions.add(_playlistManager.mediaItem.listen((newMediaItem) {
      mediaItem.add(newMediaItem);
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
    _playlistManager.setPlaylist(mediaItems);
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
    if (_playlistManager.player.position.inSeconds > 5) {
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
    _playlistManager.setShuffled(shuffleMode != AudioServiceShuffleMode.none);
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      for (final subscription in streamSubscriptions) {
        await subscription.cancel();
      }
      streamSubscriptions.clear();

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
