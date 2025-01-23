import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../exceptions/app_exceptions.dart';
import 'package:flutter/services.dart' show rootBundle;

class JsonStorage {
  static const String statsFileName = 'stats';
  static const String usersFileName = 'users';
  static const String videosFileName = 'assets/data/videos_db.json';

  static JsonStorage? _instance;
  late SharedPreferences _prefs;
  bool _initialized = false;

  static Future<JsonStorage> getInstance() async {
    if (_instance == null) {
      final instance = JsonStorage._internal();
      await instance._init();
      _instance = instance;
    }
    return _instance!;
  }

  JsonStorage._internal();

  Future<void> _init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  Future<Map<String, dynamic>> readJsonFile(String fileName) async {
    try {
      if (fileName == videosFileName) {
        final String jsonString = await rootBundle.loadString(fileName);
        return json.decode(jsonString) as Map<String, dynamic>;
      }

      final jsonStr = _prefs.getString('${fileName}_data');
      if (jsonStr == null) {
        // Initialisiere mit leerer Struktur
        if (fileName == statsFileName) {
          return {'statistics': {}};
        }
        if (fileName == usersFileName) {
          return {'users': {}};
        }
        return {};
      }

      return json.decode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      throw StorageException('Failed to read $fileName: $e');
    }
  }

  Future<void> writeJsonFile(String fileName, Map<String, dynamic> data) async {
    try {
      if (fileName == videosFileName) {
        throw StorageException('Cannot write to asset file');
      }

      final jsonStr = jsonEncode(data);
      await _prefs.setString('${fileName}_data', jsonStr);
    } catch (e) {
      throw StorageException('Failed to write $fileName: $e');
    }
  }
}
