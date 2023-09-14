import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:conference_radio_flutter/services/talks_db_service.dart';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {
  Future<void> checkForUpdatesAndApply({required String lang}) async {
    final localVersion = await readLocalAppDataVersion();
    // final remoteVersion = await readRemoteAppDataVersion();
    const remoteVersion = 1;

    if (remoteVersion != localVersion) {
      await saveLocalVersion(remoteVersion);

      const csvUrl = 'https://www.conferenceradio.app/app_data/all.csv.gz';
      final conferenceRows = await fetchAndParseCsvGZipped(csvUrl);
      final talksDbService = await TalksDbService.init();
      await talksDbService.refreshDb(conferenceRows);
    } else {
      // Versions are the same, no need to refetch
      print('CSV file is up to date.');
    }
  }

// Placeholder functions (implement these according to your app's logic)

  Future<int> readLocalAppDataVersion() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt('app_data_version') ?? 0;
  }

  Future<void> saveLocalVersion(int version) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('app_data_version', version);
  }

  Future<int> readRemoteAppDataVersion() async {
    const versionUrl = 'https://www.conferenceradio.app/app_data/version.txt';
    try {
      final versionString = await fetchUrlString(versionUrl);
      final versionInt = int.tryParse(versionString.trim());
      if (versionInt != null) {
        return versionInt;
      } else {
        throw Exception('Failed to parse version number.');
      }
    } catch (e) {
      print('Error fetching version.txt: $e');
      return 1;
    }
  }

  Future<List<List<dynamic>>> fetchAndParseCsvGZipped(String url) async {
    final encodedBytes = await fetchUrlBytes(url);
    final unzippedData = gzip.decode(encodedBytes);
    final csvString = utf8.decode(unzippedData);
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvString, eol: "\n");
    return csvTable;
  }

  Future<Uint8List> fetchUrlBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to fetch CSV data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching CSV data: $e');
    }
  }

  Future<String> fetchUrlString(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to fetch CSV data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching CSV data: $e');
    }
  }
}
