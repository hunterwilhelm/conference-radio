import 'package:sqflite/sqflite.dart';

_onCreate(Database db, int version) async {
  await db.execute("""CREATE TABLE `talks` (
    `talk_id` INTEGER,
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
          """INSERT INTO `talks` (`talk_id`,`lang`,`name`,`type`,`year`,`month`,`session_order`,`talk_order`,`title`,`base_uri`,`mp3`) VALUES (?,?,?,?,?,?,?,?,?,?,?)""",
          conferenceRow,
        );
      }
    });
  }

  Future<Talk> getRandomTalk({String lang = "eng"}) async {
    final results = await db.rawQuery("""SELECT * FROM `talks` WHERE `lang` = ? ORDER BY RANDOM() LIMIT 1 """, [lang]);
    return Talk.fromMap(results[0]);
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
      talkId: map["talk_id"] as int,
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
