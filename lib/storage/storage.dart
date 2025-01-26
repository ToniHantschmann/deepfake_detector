import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' show window;
import '../exceptions/app_exceptions.dart';

class Storage {
  static const String statsFileName = 'deepfake_stats';
  static const String usersFileName = 'deepfake_users';
  static const String videosFileName = 'assets/data/videos_db.json';

  static Storage? _instance;
  late final Box<String> _statsBox;
  late final Box<String> _usersBox;
  bool _initialized = false;

  static Future<Storage> getInstance() async {
    _instance ??= Storage._internal();
    await _instance!._init();
    return _instance!;
  }

  Storage._internal();

  Future<void> _init() async {
    if (!_initialized) {
      try {
        await Hive.initFlutter();
        _statsBox = await Hive.openBox<String>(statsFileName);
        _usersBox = await Hive.openBox<String>(usersFileName);
        _initialized = true;
      } catch (e) {
        throw StorageException('Failed to initialize storage: $e');
      }
    }
  }

  Future<Map<String, dynamic>> readJsonFile(String fileName) async {
    await _ensureInitialized();

    try {
      if (fileName == videosFileName) {
        return _readAssetFile(fileName);
      }

      final box = _getBoxForFile(fileName);
      final rawData = box.get('data');

      if (rawData == null) {
        final initialData = _getInitialDataStructure(fileName);
        await writeJsonFile(fileName, initialData);
        return initialData;
      }

      return json.decode(rawData) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error reading from storage: $e');
      if (e is StorageException) rethrow;
      throw StorageException('Failed to read $fileName: $e');
    }
  }

  Future<void> writeJsonFile(String fileName, Map<String, dynamic> data) async {
    await _ensureInitialized();

    try {
      final box = _getBoxForFile(fileName);
      await box.put('data', json.encode(data));
      debugPrint('Successfully wrote to $fileName');
    } catch (e) {
      debugPrint('Error writing to storage: $e');
      throw StorageException('Failed to write $fileName: $e');
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _init();
    }
  }

  Future<Map<String, dynamic>> _readAssetFile(String fileName) async {
    try {
      final String jsonString =
          await window.fetch(fileName).then((response) => response.text());
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw StorageException('Failed to read asset file $fileName: $e');
    }
  }

  Box<String> _getBoxForFile(String fileName) {
    switch (fileName) {
      case statsFileName:
        return _statsBox;
      case usersFileName:
        return _usersBox;
      default:
        throw StorageException('Unknown file name: $fileName');
    }
  }

  Map<String, dynamic> _getInitialDataStructure(String fileName) {
    switch (fileName) {
      case statsFileName:
        return {'statistics': {}};
      case usersFileName:
        return {'users': {}};
      default:
        return {};
    }
  }

  @visibleForTesting
  Future<void> clearStorage() async {
    await _statsBox.clear();
    await _usersBox.clear();
  }
}
