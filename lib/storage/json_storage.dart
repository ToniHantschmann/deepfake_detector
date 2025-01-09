import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../exceptions/app_exceptions.dart';

class JsonStorage {
  static const String statsFileName = 'stats';
  static const String usersFileName = 'users';
  static const String videosFileName = 'videos_db';

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
      final jsonStr = _prefs.getString('${fileName}_data');

      if (jsonStr == null) {
        return {};
      }

      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      throw StorageException('Failed to read $fileName: $e');
    }
  }

  Future<void> writeJsonFile(String fileName, Map<String, dynamic> data) async {
    try {
      final jsonStr = jsonEncode(data);
      await _prefs.setString('${fileName}_data', jsonStr);
    } catch (e) {
      throw StorageException('Failed to write $fileName: $e');
    }
  }
}
