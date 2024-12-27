import 'dart:convert';
import 'dart:io';
import 'package:deepfake_detector/exceptions/app_exceptions.dart';
import 'package:path_provider/path_provider.dart';

class JsonStorage {
  static const String statsFileName = 'stats.json';
  static const String usersFileName = 'users.json';

  static JsonStorage? _instance;
  late final Directory _directory;

  static Future<JsonStorage> getInstance() async {
    if (_instance == null) {
      final directory = await getApplicationDocumentsDirectory();
      _instance = JsonStorage._internal(directory);
    }
    return _instance!;
  }

  JsonStorage._internal(this._directory);

  Future<File> _getFile(String fileName) async {
    return File('${_directory.path}/$fileName');
  }

  Future<Map<String, dynamic>> readJsonFile(String fileName) async {
    try {
      final file = await _getFile(fileName);
      if (!await file.exists()) {
        return {};
      }
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      throw StorageException('Failed to read $fileName: $e');
    }
  }

  Future<void> writeJsonFile(String fileName, Map<String, dynamic> data) async {
    try {
      final file = await _getFile(fileName);
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      throw StorageException('Failed to write $fileName $e');
    }
  }
}
