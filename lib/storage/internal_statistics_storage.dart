// internal_statistics_storage.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:universal_html/html.dart' show window;
import '../exceptions/app_exceptions.dart';
import '../models/internal_statistics_model.dart';

class InternalStatisticsStorage {
  static const String _statsBoxName = 'internal_statistics';
  static const String _statsKey = 'stats';

  late Box _box;
  bool _initialized = false;

  // Helper für Electron-Erkennung
  bool get isElectron => kIsWeb && window.location.protocol == 'file:';

  static final InternalStatisticsStorage _instance =
      InternalStatisticsStorage._internal();
  factory InternalStatisticsStorage() => _instance;
  InternalStatisticsStorage._internal();

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      // Für Electron angepasst
      if (kIsWeb && isElectron) {
        // Für Electron - gebe einen Speicherort an
        await Hive.initFlutter('deepfake_detector_storage');
      }

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
