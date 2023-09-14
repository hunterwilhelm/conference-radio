import 'package:conference_radio_flutter/notifiers/filter_notifier.dart';
import 'package:conference_radio_flutter/ui/filter_page.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

_onCreate(Database db, int version) async {
  await db.execute("""CREATE TABLE `talks` (
    `id` INTEGER,
    `lang` TEXT,
    `name` TEXT,
    `type` TEXT,
    `year` INTEGER,
    `month` INTEGER,
    `session_order` INTEGER,
    `talk_order` INTEGER,
    `title` TEXT,
    `base_uri` TEXT,
    `mp3` TEXT
)""");
  await db.execute("""CREATE TABLE `bookmarks` (
    `talk_id` INTEGER PRIMARY KEY,
    `created_date` DATETIME DEFAULT CURRENT_TIMESTAMP
)""");
}

class TalksDbService {
  Database db;
  TalksDbService._(this.db);
  static Future<TalksDbService> init() async {
    final db = await openDatabase(
      'talks.db',
      onCreate: _onCreate,
      version: 1,
    );
    return TalksDbService._(db);
  }

  Future<void> refreshDb(List<List> conferenceRows) async {
    await db.execute("""DELETE FROM `talks`""", []);
    await db.transaction((txn) async {
      for (final conferenceRow in conferenceRows) {
        await txn.rawInsert(
          """INSERT INTO `talks` (`id`,`lang`,`name`,`type`,`year`,`month`,`session_order`,`talk_order`,`title`,`base_uri`,`mp3`) VALUES (?,?,?,?,?,?,?,?,?,?,?)""",
          conferenceRow,
        );
      }
    });
  }

  Future<Talk> getRandomTalk({required String lang, required Filter filter}) async {
    final sortedFilter = filter.asSorted();
    final results = await db.rawQuery("""
SELECT * FROM `talks` 
WHERE `lang` = ? 
AND (year, month) <= (?, ?)
AND (year, month) >= (?, ?)
ORDER BY RANDOM() LIMIT 1
""", [
      lang,
      sortedFilter.start.year,
      sortedFilter.start.month,
      sortedFilter.end.year,
      sortedFilter.end.month,
    ]);
    return Talk.fromMap(results[0]);
  }

  Future<Talk?> getNextTalk({required String lang, required int id, required Filter filter}) async {
    final sortedFilter = filter.asSorted();
    final talkResults = await db.rawQuery(""" SELECT * FROM talks WHERE `id` = ? LIMIT 1 """, [id]);
    final currentTalk = Talk.fromMap(talkResults[0]);
    final talkDate = YearMonth(currentTalk.year, currentTalk.month).date;
    final comparison = talkDate.compareTo(sortedFilter.start.date) + talkDate.compareTo(sortedFilter.end.date);
    if (comparison == -2 || comparison == 2) {
      return getRandomTalk(filter: filter, lang: lang);
    }
    final results = await db.rawQuery("""
SELECT * FROM talks
WHERE `lang` = ? 
AND (year, month, session_order, talk_order) < (?, ?, ?, ?)
AND (year, month) <= (?, ?)
AND (year, month) >= (?, ?)
ORDER BY year DESC, month DESC, session_order DESC, talk_order DESC
LIMIT 1
""", [
      lang,
      currentTalk.year,
      currentTalk.month,
      currentTalk.sessionOrder,
      currentTalk.talkOrder,
      sortedFilter.start.year,
      sortedFilter.start.month,
      sortedFilter.end.year,
      sortedFilter.end.month,
    ]);
    return Talk.fromMap(results[0]);
  }

  Future<List<Talk>> getTalkPlaylist({required String lang, required Filter filter}) async {
    final sortedFilter = filter.asSorted();
    final results = await db.rawQuery("""
SELECT * FROM talks
WHERE `lang` = ? 
AND (year, month) <= (?, ?)
AND (year, month) >= (?, ?)
ORDER BY year ASC, month ASC, session_order ASC, talk_order ASC
""", [
      lang,
      sortedFilter.start.year,
      sortedFilter.start.month,
      sortedFilter.end.year,
      sortedFilter.end.month,
    ]);
    return results.map((map) => Talk.fromMap(map)).toList();
  }

  Future<List<Bookmark>> getBookmarkedTalks({required String lang}) async {
    try {
      final results = await db.rawQuery("""
SELECT * FROM bookmarks
INNER JOIN talks ON talks.id = bookmarks.talk_id
WHERE talks.`lang` = ? 
ORDER BY bookmarks.created_date DESC
""", [
        lang,
      ]);
      return results.map((map) => Bookmark.fromMap(map)).toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<void> saveBookmark(int talkId, bool bookmarked) async {
    const insertQuery = """
INSERT INTO bookmarks (talk_id) VALUES (?)
""";
    const deleteQuery = """
DELETE FROM bookmarks
WHERE bookmarks.talk_id = ? 
""";
    await db.rawQuery(bookmarked ? insertQuery : deleteQuery, [talkId]);
  }

  Future<bool> getIsBookmarked(int talkId) async {
    const countQuery = """
SELECT COUNT(*) as count FROM bookmarks WHERE talk_id = ?
""";
    final results = await db.rawQuery(countQuery, [talkId]);
    return results[0]["count"] == 1;
  }

  Future<Filter> getMaxRange({required String lang}) async {
    const countQuery = """
SELECT MAX(year + (CAST(month as REAL) / 20)) as end, MIN(year + (CAST(month as REAL) / 20)) as start FROM talks WHERE lang = ?
""";
    final results = await db.rawQuery(countQuery, [lang]);
    final start = results[0]["start"] as double;
    final startYear = start.floor();
    final startMonth = ((start - startYear) * 20).toInt();
    final end = results[0]["end"] as double;
    final endYear = end.floor();
    final endMonth = ((end - endYear) * 20).toInt();
    return Filter(YearMonth(startYear, startMonth), YearMonth(endYear, endMonth));
  }
}

class Bookmark {
  final DateTime createdDate;
  final Talk talk;

  Bookmark._({
    required this.createdDate,
    required this.talk,
  });

  static Bookmark fromMap(Map<String, Object?> map) {
    return Bookmark._(
      createdDate: DateTime.parse("${map["created_date"] as String}Z").toLocal(),
      talk: Talk.fromMap(map),
    );
  }
}

class Talk {
  final int talkId;
  final String lang;
  final String name;
  final String type;
  final int year;
  final int month;
  final int sessionOrder;
  final int talkOrder;
  final String title;
  final String baseUri;
  final String mp3;

  Talk._({
    required this.talkId,
    required this.lang,
    required this.name,
    required this.type,
    required this.year,
    required this.month,
    required this.sessionOrder,
    required this.talkOrder,
    required this.title,
    required this.baseUri,
    required this.mp3,
  });

  @override
  String toString() {
    return "Instance of Talk <${toMap().toString()}>";
  }

  Map<String, Object?> toMap() {
    return {
      "talk_id": talkId,
      "lang": lang,
      "name": name,
      "type": type,
      "year": year,
      "month": month,
      "session_order": sessionOrder,
      "talk_order": talkOrder,
      "title": title,
      "base_uri": baseUri,
      "mp3": mp3,
    };
  }

  static Talk fromMap(Map<String, Object?> map) {
    return Talk._(
      talkId: map["id"] as int,
      lang: map["lang"] as String,
      name: map["name"] as String,
      type: map["type"] as String,
      year: map["year"] as int,
      month: map["month"] as int,
      sessionOrder: map["session_order"] as int,
      talkOrder: map["talk_order"] as int,
      title: map["title"] as String,
      baseUri: map["base_uri"] as String,
      mp3: map["mp3"] as String,
    );
  }
}
