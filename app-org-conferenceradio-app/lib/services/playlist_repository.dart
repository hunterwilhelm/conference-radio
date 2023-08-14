import 'package:conference_radio_flutter/notifiers/filter_notifier.dart';
import 'package:conference_radio_flutter/services/talks_db_service.dart';

import 'sync_service.dart';

abstract class PlaylistRepository {
  Future<Talk?> fetchNextTalk({String? idForSequential, required Filter filter});
  Future<List<Talk>> fetchTalkPlaylist({required Filter filter});
}

class DemoPlaylist extends PlaylistRepository {
  late final TalksDbService _talksDbService;
  bool hasInit = false;
  @override
  Future<Talk?> fetchNextTalk({String? idForSequential, required Filter filter}) async {
    await ensureInitialized();
    final id = idForSequential == null ? null : int.tryParse(idForSequential);
    if (id == null) {
      return _talksDbService.getRandomTalk(filter: filter);
    } else {
      return _talksDbService.getNextTalk(id: id, filter: filter);
    }
  }

  @override
  Future<List<Talk>> fetchTalkPlaylist({required Filter filter}) async {
    await ensureInitialized();
    return _talksDbService.getTalkPlaylist(filter: filter);
  }

  Future<void> ensureInitialized() async {
    if (!hasInit) {
      hasInit = true;
      _talksDbService = await TalksDbService.init();
      await SyncService().checkForUpdatesAndApply();
    }
  }
}
