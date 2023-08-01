import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:conference_radio_flutter/service/talks_db_service.dart';
import 'package:flutter/material.dart';

class AudioPlayerService extends ChangeNotifier {
  final AssetsAudioPlayer audioPlayer = AssetsAudioPlayer.newPlayer();
  final List<Talk> _playlist = [];
  int index = 0;
  final List<StreamSubscription> _subscriptions = [];
  final TalksDbService talksDbService;
  late PlayerState playerState;

  AudioPlayerService._(this.talksDbService) {
    _subscriptions.add(audioPlayer.playlistAudioFinished.listen((finished) {
      print('playlistAudioFinished : $finished');
      _loadNextSong();
    }));
    _subscriptions.add(audioPlayer.playerState.listen((playerState) {
      print('playlistAudioFinished : $playerState');
      notifyListeners();
      this.playerState = playerState;
    }));
    playerState = audioPlayer.playerState.value;
    _loadNextSong();
  }
  static Future<AudioPlayerService> init() async {
    return AudioPlayerService._(await TalksDbService.init());
  }

  @override
  void dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    audioPlayer.showNotification = false;
    await audioPlayer.stop();
    await audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadNextSong() async {
    // // Fetch a new link from the API
    print("loading next song...");
    final newTalk = await talksDbService.getRandomTalk();
    _playlist.add(newTalk);
    // // Add the new song to the playlist
    // _playlist.add(newSongLink);

    // // Keep only the three latest songs in the playlist
    // if (_playlist.length > 3) {
    //   _playlist.removeAt(0);
    // }
  }

  void play({int indexDelta = 0}) {
    final possibleNewIndex = indexDelta + index;

    if (possibleNewIndex < _playlist.length && possibleNewIndex >= 0) {
      index += indexDelta;
    } else {
      print("invalid index");
      return;
    }

    audioPlayer.open(
      Audio.network(_playlist[index].mp3),
      showNotification: true,
      notificationSettings: NotificationSettings(
        customNextAction: (player) async {
          if (_playlist.length - index <= 2) {
            _loadNextSong();
          }
          play(indexDelta: 1);
        },
        customPrevAction: (player) async {
          play(indexDelta: -1);
        },
      ),
    );
  }

  void pause() {
    audioPlayer.pause();
  }

  void stop() {
    audioPlayer.stop();
  }
}
