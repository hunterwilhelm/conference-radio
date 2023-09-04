import 'dart:async';
import 'dart:math' show max, min;

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
  final _player = AudioPlayer();
  final _subPlaylist = ConcatenatingAudioSource(
    children: [],
    useLazyPreparation: false, // I want it to pre-cache everything I put in this playlist.
  );

  /// A copy of the media items so we can access them later
  final List<MediaItem> _subPlaylistItems = [];

  /// The full list of media items to pull from
  final List<MediaItem> _fullPlaylist = [];

  /// Used for keeping track of how many tracks are in front of the current index of the player.
  int _playlistFrontLoadingCount = 0;

  /// Change this if you want the index to not start at the beginning
  static const kDefaultIndex = 0;

  /// Keeps track of the current index of the _fullPlaylist
  int _currentFullPlaylistIndex = kDefaultIndex;

  /// Used for cleaning up the subscriptions when disposed
  final List<StreamSubscription> _streamSubscriptions = [];

  /// Used for preventing race conditions in the _lazyLoadPlaylist
  bool _updatePlayerRunning = false;

  /// Used for preventing race conditions in the _lazyLoadPlaylist
  bool _updatePlayerWasCalledWhileRunning = false;

  /// Used for getting the index of the current item if it is shuffled or not
  int get _finalIndex => _shuffled ? _shuffleIndices[_currentFullPlaylistIndex] : _currentFullPlaylistIndex;

  /// Used for keeping track of the shuffle order
  final List<int> _shuffleIndices = [];

  /// Switches between the shuffleIndices order and regular indices
  bool _shuffled = false;

  /// Used for not skipping too many times if the [_subPlaylist] isn't done loading yet.
  int _directionOfSkipTo = 0;

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

  /// The index of the current index.
  int get currentIndex => _currentFullPlaylistIndex;

  /// How many tracks next and previous are loaded into ConcatenatingAudioSource
  /// * Ex. 3 would look like [`prev3`, `prev2`, `prev1`, `current`, `next1`, `next2`, `next3`]
  final int preloadPaddingCount;

  PlaylistManager({this.preloadPaddingCount = 3}) {
    _attachAudioSourceToPlayer();
    _listenForCurrentSongIndexChanges();
  }

  /// Used for loading the tracks. This will reset the current index and position.
  setQueue(List<MediaItem> mediaItems) async {
    _fullPlaylist.clear();
    _fullPlaylist.addAll(mediaItems);
    _subPlaylist.clear();
    _subPlaylistItems.clear();
    setShuffled(_shuffled, true);
    _lazyLoadPlaylist();
  }

  /// Use this instead of [player.seekToNext]
  Future<void> seekToNext() async {
    _directionOfSkipTo = 1;
    await _player.seekToNext();
  }

  /// Use this instead of [player.seekToPrevious]
  Future<void> seekToPrevious() async {
    _directionOfSkipTo = -1;
    await _player.seekToPrevious();
  }

  /// Use to shuffle the queue without losing the current media item
  ///
  /// If shuffled:
  ///   This will reset current queue so this current song will be first
  /// If not shuffled:
  ///   This will restore the regular queue so next/previous will go continue where you are
  void setShuffled(bool newShuffled, [bool? force]) {
    if (newShuffled == _shuffled && force != true) return;
    if (newShuffled) {
      final indices = List.generate(_fullPlaylist.length, (index) => index).where((element) => element != _currentFullPlaylistIndex).toList();
      shuffle(indices);
      _shuffleIndices.clear();
      _shuffleIndices.addAll(indices..insert(0, _currentFullPlaylistIndex));
      _currentFullPlaylistIndex = kDefaultIndex;
    } else if (_shuffleIndices.isNotEmpty) {
      _currentFullPlaylistIndex = _shuffleIndices[_currentFullPlaylistIndex];
    } else {
      _currentFullPlaylistIndex = kDefaultIndex;
    }
    _shuffled = newShuffled;
  }

  Future<void> _attachAudioSourceToPlayer() async {
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

      if (delta.sign == _directionOfSkipTo.sign) {
        _currentFullPlaylistIndex += delta;
        _playlistFrontLoadingCount += delta;
      }
    }));
  }

  int _getRelativeIndex(int offset) {
    return max(0, min(_currentFullPlaylistIndex + offset, _fullPlaylist.length - 1));
  }

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
    _updatePlayerRunning = true;

    final currentIndex_ = _currentFullPlaylistIndex;
    final playerIndex = _player.currentIndex ?? 0;

    // Pad/pre-cache the ending of the playlist
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

    // Pad/pre-cache the beginning of the playlist
    final currentPreviousPadding = _player.currentIndex ?? 0;
    final previousCountToAdd = preloadPaddingCount - currentPreviousPadding;
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
    _playlistManager.setShuffled(shuffleMode != AudioServiceShuffleMode.none);
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
