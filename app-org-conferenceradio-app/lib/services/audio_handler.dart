import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:collection/collection.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quiver/iterables.dart' show range;

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

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);
  final _reversePlaylist = ConcatenatingAudioSource(children: []);
  bool _shuffleMode = false;
  List<int> _shuffleIndices = [];

  MyAudioHandler() {
    _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print("Error: $e");
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
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
        }[_player.processingState]!,
        repeatMode: const {
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_player.loopMode]!,
        shuffleMode: (_player.shuffleModeEnabled) ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      print("durationStream");
      var index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      // if (_player.shuffleModeEnabled) {
      //   index = _player.shuffleIndices!.indexOf(index);
      // }
      final finalIndex = getFinalIndex(index);
      final oldMediaItem = newQueue[finalIndex];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[finalIndex] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      _lazyLoadTracks(index);
      final finalIndex = getFinalIndex(index);
      mediaItem.add(playlist[finalIndex]);
    });
  }

  Future<void> _lazyLoadTracks(int index) async {
    print("currentIndexStream");
    const downloadAhead = 5;
    final remainingTracksInPlaylist = _playlist.length - index - 1;
    if (remainingTracksInPlaylist <= downloadAhead && queue.value.isNotEmpty) {
      // manage Just Audio
      final audioSources = range(_playlist.length, min(queue.value.length, _playlist.length - 1 + downloadAhead)).map((index) {
        final finalIndex = getFinalIndex(index);
        print("final idnex: $finalIndex");
        return _createAudioSource(queue.value[finalIndex]);
      });
      print('adding... ${audioSources.length}');
      for (var audioItem in audioSources) {
        await _playlist.add(audioItem);
        await Future.microtask(() {});
      }
      print('done.');
    }
  }

  int getFinalIndex(num index) => _shuffleMode ? _shuffleIndices[index.toInt()] : index.toInt();

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      // final sequence = sequenceState?.effectiveSequence;
      // if (sequence == null || sequence.isEmpty) return;
      // final items = sequence.map((source) => source.tag as MediaItem);
      // queue.add(items.toList());
    });
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    print("addQueueItems");
    throw UnimplementedError();
    // manage Just Audio
    // final audioSource = mediaItems.map(_createAudioSource);
    // _playlist.addAll(audioSource.toList());

    // // notify system
    // final newQueue = queue.value..addAll(mediaItems);
    // queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    print("addQueueItem");
    throw UnimplementedError();
    // // manage Just Audio
    // final audioSource = _createAudioSource(mediaItem);
    // _playlist.add(audioSource);

    // // notify system
    // final newQueue = queue.value..add(mediaItem);
    // queue.add(newQueue);
  }

  @override
  Future<void> updateQueue(List<MediaItem> mediaItems) async {
    _playlist.clear();

    // notify system
    final newQueue = mediaItems;
    queue.add(newQueue);

    _lazyLoadTracks(0);
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.parse(mediaItem.extras!['url'] as String),
      tag: mediaItem,
    );
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    print("removeQueueItemAt");
    throw UnimplementedError();
    // // manage Just Audio
    // _playlist.removeAt(index);

    // // notify system
    // final newQueue = queue.value..removeAt(index);
    // queue.add(newQueue);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    print("skipToQueueItem");
    throw UnimplementedError();

    // if (index < 0 || index >= queue.value.length) return;
    // if (_player.shuffleModeEnabled) {
    //   index = _player.shuffleIndices![index];
    // }
    // _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> skipToNext() async {
    _player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.position.inSeconds > 5) {
      print("va");
      return _player.seek(Duration.zero);
    } else {
      print("vb");
      return _player.seekToPrevious();
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    print("setRepeatMode");
    throw UnimplementedError();

    // switch (repeatMode) {
    //   case AudioServiceRepeatMode.none:
    //     _player.setLoopMode(LoopMode.off);
    //     break;
    //   case AudioServiceRepeatMode.one:
    //     _player.setLoopMode(LoopMode.one);
    //     break;
    //   case AudioServiceRepeatMode.group:
    //   case AudioServiceRepeatMode.all:
    //     _player.setLoopMode(LoopMode.all);
    //     break;
    // }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.none) {
      _shuffleMode = false;
      // _player.setShuffleModeEnabled(false);
    } else {
      _shuffleMode = true;
      _shuffle();

      // _player.setShuffleModeEnabled(true);
    }
  }

  void _shuffle() {
    final currentIndex = playbackState.value.queueIndex ?? 0;
    final indices = List.generate(queue.value.length, (index) => index).where((element) => element != currentIndex).toList();
    shuffle(indices);
    _shuffleIndices = indices..insert(0, currentIndex);
    _playlist.clear();
    _lazyLoadTracks(0);
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
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
    await _player.stop();
    return super.stop();
  }
}
