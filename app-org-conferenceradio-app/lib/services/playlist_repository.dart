import 'package:conference_radio_flutter/services/talks_db_service.dart';

import 'sync_service.dart';

abstract class PlaylistRepository {
  Future<List<Talk>> fetchInitialPlaylist();
  Future<Talk> fetchAnotherTalk();
}

class DemoPlaylist extends PlaylistRepository {
  late final TalksDbService _talksDbService;
  @override
  Future<List<Talk>> fetchInitialPlaylist({int length = 3}) async {
    await SyncService().checkForUpdatesAndApply();
    _talksDbService = await TalksDbService.init();
    return Future.wait(List.generate(length, (index) => _nextSong()));
  }

  @override
  Future<Talk> fetchAnotherTalk() {
    return _nextSong();
  }

  Future<Talk> _nextSong() async {
    return _talksDbService.getRandomTalk();
  }
}
