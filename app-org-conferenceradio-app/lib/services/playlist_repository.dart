import 'package:conference_radio_flutter/services/talks_db_service.dart';

import 'sync_service.dart';

abstract class PlaylistRepository {
  Future<Talk> fetchNextTalk({String? idForSequential});
}

class DemoPlaylist extends PlaylistRepository {
  late final TalksDbService _talksDbService;
  bool hasInit = false;
  @override
  Future<Talk> fetchNextTalk({String? idForSequential}) async {
    if (!hasInit) {
      hasInit = true;
      _talksDbService = await TalksDbService.init();
      await SyncService().checkForUpdatesAndApply();
    }
    final id = idForSequential == null ? null : int.tryParse(idForSequential);
    if (id == null) {
      return _talksDbService.getRandomTalk();
    } else {
      return _talksDbService.getNextTalk(id: id);
    }
  }
}
