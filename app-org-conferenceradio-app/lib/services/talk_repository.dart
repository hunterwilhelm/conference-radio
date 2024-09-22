import 'package:conference_radio_flutter/notifiers/filter_notifier.dart';
import 'package:conference_radio_flutter/services/talks_db_service.dart';

import 'sync_service.dart';

class TalkRepository {
  late final TalksDbService _talksDbService;
  bool hasInit = false;
  bool initializing = false;

  Future<DateFilter> getMaxRange({required String lang}) async {
    await ensureInitialized(lang: lang);
    return _talksDbService.getMaxRange(lang: lang);
  }

  Future<List<Talk>> fetchTalkPlaylist({required Filter filter, required String lang}) async {
    await ensureInitialized(lang: lang);
    return _talksDbService.getTalkPlaylist(filter: filter, lang: lang);
  }

  Future<List<Bookmark>> getBookmarkedTalks({required String lang}) async {
    await ensureInitialized(lang: lang);
    return _talksDbService.getBookmarkedTalks(lang: lang);
  }

  Future<bool> getIsBookmarked(int talkId, {required String lang}) async {
    await ensureInitialized(lang: lang);
    return _talksDbService.getIsBookmarked(talkId);
  }

  Future<void> saveBookmark(int id, bool bookmarked, {required String lang}) async {
    await ensureInitialized(lang: lang);
    return _talksDbService.saveBookmark(id, bookmarked);
  }

  Future<List<SpeakerResult>> getAllSpeakers({required String lang}) async {
    await ensureInitialized(lang: lang);
    return _talksDbService.getAllSpeakers(lang: lang);
  }

  Future<List<SpeakerResult>> getFilteredSpeakers(Filter filter, {required String lang}) async {
    await ensureInitialized(lang: lang);
    return _talksDbService.getFilteredSpeakers(dateFilter: filter.dateFilter, lang: lang);
  }

  Future<void> ensureInitialized({required String lang}) async {
    if (initializing) {
      await Future.delayed(const Duration(milliseconds: 1));
      return ensureInitialized(lang: lang);
    }
    if (!hasInit) {
      initializing = true;
      _talksDbService = await TalksDbService.init();
      initializing = false;
      hasInit = true;
      await SyncService().checkForUpdatesAndApply(lang: lang);
    }
  }
}
