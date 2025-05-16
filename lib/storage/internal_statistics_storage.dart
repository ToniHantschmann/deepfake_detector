// internal_statistics_storage.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../exceptions/app_exceptions.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';

class InternalStatisticsStorage {
  static const String _statsBoxName = 'internal_statistics';
  static const String _statsKey = 'stats';

  late Box _box;
  bool _initialized = false;

  static final InternalStatisticsStorage _instance =
      InternalStatisticsStorage._internal();
  factory InternalStatisticsStorage() => _instance;
  InternalStatisticsStorage._internal();

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/deepfake_detector';

      // Ensure directory exists
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Initialize Hive with the specific path
      Hive.init(path);

      _box = await Hive.openBox(_statsBoxName);
      _initialized = true;
    } catch (e) {
      throw StorageException('Failed to initialize storage: $e');
    }
  }

  // Basis-Speicherfunktionen
  Future<String?> getRawData() async {
    await _ensureInitialized();
    return _box.get(_statsKey) as String?;
  }

  Future<void> saveRawData(String jsonString) async {
    await _ensureInitialized();
    await _box.put(_statsKey, jsonString);
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) await initialize();
  }

  @visibleForTesting
  Future<void> clear() async {
    await _ensureInitialized();
    await _box.clear();
  }
}
