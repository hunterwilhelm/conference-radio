import 'dart:async';
import 'dart:math' show Random, max, min;

import 'package:audio_service/audio_service.dart';
import 'package:collection/collection.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quiver/iterables.dart' show range;
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
  PlaylistManager({this.preloadPaddingCount = 1}) {
    _loadEmptyPlaylist();
    _listenForCurrentSongIndexChanges();
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSource(_subPlaylist);
    } catch (e) {
      print("Error: $e");
    }
  }

  void _listenForCurrentSongIndexChanges() {
    int? previousIndex = _player.currentIndex;
    _streamSubscriptions.add(_player.currentIndexStream.listen((index) {
      _updateMediaItem();
      _lazyLoadPlaylist();
      final previousIndex_ = previousIndex;
      previousIndex = index;
      if (previousIndex_ == null || index == null) return;
      final delta = index - previousIndex_;
      if (delta.sign == direction.sign) {
        currentIndex += delta;
        _playlistFrontLoadingCount += delta;
      }
    }));
  }

  /// How many tracks next and previous are loaded into ConcatenatingAudioSource
  /// * Ex. 3 would look like [`prev3`, `prev2`, `prev1`, `current`, `next1`, `next2`, `next3`]
  final int preloadPaddingCount;
  final _player = AudioPlayer();
  final _subPlaylist = ConcatenatingAudioSource(
    children: [],
    useLazyPreparation: false,
  );
  final List<MediaItem> _subPlaylistItems = [];
  final List<MediaItem> _fullPlaylist = [];
  int _playlistFrontLoadingCount = 0;
  static const kDefaultIndex = 10;
  int currentIndex = kDefaultIndex;
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

  int get finalIndex => _shuffled ? _shuffleIndices[currentIndex] : currentIndex;

  int _getRelativeIndex(int offset) {
    return max(0, min(currentIndex + offset, _fullPlaylist.length - 1));
  }

  setQueue(List<MediaItem> mediaItems) async {
    _fullPlaylist.clear();
    _fullPlaylist.addAll(mediaItems);
    _subPlaylist.clear();
    _subPlaylistItems.clear();
    setShuffled(_shuffled, true);
    _lazyLoadPlaylist();
  }

  bool _updatePlayerRunning = false;
  bool _updatePlayerWasCalledWhileRunning = false;
  _updateMediaItem() {
    if (_subPlaylistItems.isEmpty) return;

    final playerIndex = _player.currentIndex;
    if (playerIndex == null) return;
    final newMediaItem = _subPlaylistItems[playerIndex];
    mediaItem.add(newMediaItem);
  }

  _lazyLoadPlaylist() async {
    // prevent race conditions
    if (_updatePlayerRunning) {
      _updatePlayerWasCalledWhileRunning = true;
      return;
    }
    final id = Random().nextDouble();
    _updatePlayerRunning = true;
    final currentIndex_ = currentIndex;

    final playerIndex = _player.currentIndex ?? 0;
    // preload next
    final currentNextPadding = max(0, _subPlaylist.length - playerIndex);
    var nextCountToAdd = preloadPaddingCount - currentNextPadding + 1;
    if (nextCountToAdd > 0 && _fullPlaylist.isNotEmpty) {
      for (final iNum in range(nextCountToAdd)) {
        var mediaItem = _fullPlaylist[iNum.toInt() + currentIndex_];
        await _subPlaylist.add(_createAudioSource(mediaItem));
        _subPlaylistItems.add(mediaItem);
        await Future.microtask(() {});
      }
    }

    // preload previous
    final currentPreviousPadding = _player.currentIndex ?? 0;
    final previousCountToAdd = preloadPaddingCount - currentPreviousPadding;
    // Pad the beginning of the playlist
    if (previousCountToAdd > 0) {
      for (int i = 1; i <= previousCountToAdd; i++) {
        var index = currentIndex_ - currentPreviousPadding - _playlistFrontLoadingCount - i;
        if (index < 0 || _fullPlaylist.length <= index) continue;
        var mediaItem = _fullPlaylist[index];
        final future = _subPlaylist.insert(0, _createAudioSource(mediaItem));
        _subPlaylistItems.insert(0, mediaItem);
        _playlistFrontLoadingCount++;
        await future;
        await Future.microtask(() {});
      }
    }
    _updateMediaItem();

    // prevent race conditions
    _updatePlayerRunning = false;
    if (_updatePlayerWasCalledWhileRunning) {
      _updatePlayerWasCalledWhileRunning = false;
      Future.microtask(() {
        _lazyLoadPlaylist();
      });
    }
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.parse(mediaItem.extras!['url'] as String),
      tag: mediaItem,
    );
  }

  int direction = 0;
  Future<void> seekToNext() async {
    direction = 1;
    await _player.seekToNext();
  }

  Future<void> seekToPrevious() async {
    direction = -1;
    await _player.seekToPrevious();
  }

  void setShuffled(bool newShuffled, [bool? force]) {
    if (newShuffled == _shuffled && force != true) return;
    if (newShuffled) {
      final indices = List.generate(_fullPlaylist.length, (index) => index).where((element) => element != currentIndex).toList();
      shuffle(indices);
      _shuffleIndices.clear();
      _shuffleIndices.addAll(indices..insert(0, currentIndex));
      currentIndex = kDefaultIndex;
    } else if (_shuffleIndices.isNotEmpty) {
      currentIndex = _shuffleIndices[currentIndex];
    } else {
      currentIndex = kDefaultIndex;
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
