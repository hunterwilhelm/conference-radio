import 'package:conference_radio_flutter/notifiers/filter_notifier.dart';
import 'package:conference_radio_flutter/services/talks_db_service.dart';

import 'sync_service.dart';

class TalkRepository {
  late final TalksDbService _talksDbService;
  bool hasInit = false;
  bool initializing = false;
  Future<Talk?> fetchNextTalk({String? idForSequential, required Filter filter}) async {
    await ensureInitialized();
    final id = idForSequential == null ? null : int.tryParse(idForSequential);
    if (id == null) {
      return _talksDbService.getRandomTalk(filter: filter);
    } else {
      return _talksDbService.getNextTalk(id: id, filter: filter);
    }
  }

  Future<Filter> getMaxRange() async {
    await ensureInitialized();
    return _talksDbService.getMaxRange();
  }

  Future<List<Talk>> fetchTalkPlaylist({required Filter filter}) async {
    await ensureInitialized();
    return _talksDbService.getTalkPlaylist(filter: filter);
  }

  Future<List<Bookmark>> getBookmarkedTalks() async {
    await ensureInitialized();
    return _talksDbService.getBookmarkedTalks();
  }

  Future<bool> getIsBookmarked(int talkId) async {
    await ensureInitialized();
    return _talksDbService.getIsBookmarked(talkId);
  }

  Future<void> saveBookmark(int id, bool bookmarked) async {
    await ensureInitialized();
    return _talksDbService.saveBookmark(id, bookmarked);
  }

  Future<void> ensureInitialized() async {
    if (initializing) {
      await Future.delayed(const Duration(milliseconds: 1));
      return ensureInitialized();
    }
    if (!hasInit) {
      initializing = true;
      _talksDbService = await TalksDbService.init();
      initializing = false;
      hasInit = true;
      await SyncService().checkForUpdatesAndApply();
    }
  }
}
