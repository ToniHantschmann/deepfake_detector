import 'dart:convert';
import 'package:localstorage/localstorage.dart';
import '../exceptions/app_exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' show window;

class JsonStorage {
  static const String statsFileName = 'deepfake_stats';
  static const String usersFileName = 'deepfake_users';
  static const String videosFileName = 'assets/data/videos_db.json';

  static JsonStorage? _instance;
  late final LocalStorage _statsStorage;
  late final LocalStorage _usersStorage;
  bool _initialized = false;

  // Singleton instance management
  static Future<JsonStorage> getInstance() async {
    _instance ??= JsonStorage._internal();
    await _instance!._init();
    return _instance!;
  }

  JsonStorage._internal() {
    _statsStorage = LocalStorage(statsFileName);
    _usersStorage = LocalStorage(usersFileName);
  }

  Future<void> _init() async {
    if (!_initialized) {
      try {
        await Future.wait([_statsStorage.ready, _usersStorage.ready]);
        _initialized = true;
      } catch (e) {
        throw StorageException('Failed to initialize storage: $e');
      }
    }
  }

  /// Reads JSON data from storage
  Future<Map<String, dynamic>> readJsonFile(String fileName) async {
    await _ensureInitialized();

    try {
      // Handle asset files differently
      if (fileName == videosFileName) {
        return _readAssetFile(fileName);
      }

      final storage = _getStorageForFile(fileName);
      final rawData = await storage.getItem('data');

      // Handle missing or null data
      if (rawData == null) {
        final initialData = _getInitialDataStructure(fileName);
        return initialData;
      }

      return _parseStorageData(rawData, fileName);
    } catch (e) {
      debugPrint('Error reading from storage: $e');
      if (e is StorageException) rethrow;
      throw StorageException('Failed to read $fileName: $e');
    }
  }

  /// Writes JSON data to storage
  Future<void> writeJsonFile(String fileName, Map<String, dynamic> data) async {
    await _ensureInitialized();

    try {
      final storage = _getStorageForFile(fileName);
      final sanitizedData = _sanitizeDataForStorage(data);
      await storage.ready;

      // Ensure we're storing a valid data structure
      final dataToStore = switch (fileName) {
        statsFileName => {'statistics': sanitizedData['statistics'] ?? {}},
        usersFileName => {'users': sanitizedData['users'] ?? []},
        _ => sanitizedData
      };

      // Encode to ensure JSON compatibility
      //final jsonString = json.encode(dataToStore);
      await storage.setItem('data', dataToStore);
    } catch (e) {
      debugPrint('Error writing to storage: $e');
      throw StorageException('Failed to write $fileName: $e');
    }
  }

  // Helper methods
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

  Map<String, dynamic> _parseStorageData(dynamic rawData, String fileName) {
    try {
      if (rawData is Map) {
        return Map<String, dynamic>.from(rawData);
      }

      if (rawData is String) {
        // Parse string to Map<String, dynamic>
        final decoded = json.decode(rawData);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      }

      debugPrint('Invalid storage data type: ${rawData.runtimeType}');
      return _getInitialDataStructure(fileName);
    } catch (e) {
      debugPrint('Error parsing storage data: $e');
      return _getInitialDataStructure(fileName);
    }
  }

  Map<String, dynamic> _sanitizeDataForStorage(Map<String, dynamic> data) {
    try {
      // Convert to JSON and back to ensure data is serializable
      final jsonString = json.encode(data);
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw StorageException('Failed to sanitize data for storage: $e');
    }
  }

  LocalStorage _getStorageForFile(String fileName) {
    switch (fileName) {
      case statsFileName:
        return _statsStorage;
      case usersFileName:
        return _usersStorage;
      default:
        throw StorageException('Unknown file name: $fileName');
    }
  }

  Map<String, dynamic> _getInitialDataStructure(String fileName) {
    return switch (fileName) {
      statsFileName => {'statistics': {}},
      usersFileName => {'users': []},
      _ => {}
    };
  }

  @visibleForTesting
  Future<void> clearStorage() async {
    await _statsStorage.clear();
    await _usersStorage.clear();
  }
}
