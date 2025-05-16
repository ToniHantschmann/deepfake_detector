import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../exceptions/app_exceptions.dart';
import '../models/statistics_model.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class Storage {
  static const String statsFileName = 'deepfake_stats';
  static const String usersFileName = 'deepfake_users';
  static const String videosFileName = 'assets/data/videos_db.json';

  static Storage? _instance;
  late final Box _statsBox;
  late final Box _usersBox;
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
        final appDocDirectory = await getApplicationDocumentsDirectory();
        Hive.init(appDocDirectory.path);
        _statsBox = await Hive.openBox(statsFileName);
        _usersBox = await Hive.openBox(usersFileName);
        _initialized = true;
      } catch (e) {
        throw StorageException('Failed to initialize storage: $e');
      }
    }
  }

  Future<List<int>> getUsers() async {
    await _ensureInitialized();
    final List<dynamic> rawData =
        _usersBox.get('users', defaultValue: <dynamic>[]);
    return rawData.cast<int>();
  }

  Future<void> saveUsers(List<int> users) async {
    await _ensureInitialized();
    final List<dynamic> rawData = users.cast<dynamic>();
    await _usersBox.put('users', rawData);
  }

  Future<Map<int, UserStatistics>> getStatistics() async {
    await _ensureInitialized();
    final Map<dynamic, dynamic> rawData =
        _statsBox.get('statistics', defaultValue: <dynamic, dynamic>{});

    // Convert Map<dynamic, dynamic> to Map<int, UserStatistics>
    return rawData.map((key, value) {
      final int userId = (key as dynamic) as int;
      final Map<String, dynamic> statsMap =
          (value as Map<dynamic, dynamic>).cast<String, dynamic>();
      return MapEntry(userId, UserStatistics.fromJson(statsMap));
    });
  }

  Future<void> saveStatistics(Map<int, UserStatistics> statistics) async {
    await _ensureInitialized();

    // Convert to Map<dynamic, dynamic> for storage
    final Map<dynamic, dynamic> rawData = statistics.map((key, value) {
      return MapEntry(key as dynamic, value.toJson() as dynamic);
    });

    await _statsBox.put('statistics', rawData);
  }

  Future<Map<String, dynamic>> getVideos() async {
    try {
      final String jsonString = await rootBundle.loadString(videosFileName);
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw StorageException('Failed to read asset file $videosFileName: $e');
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _init();
    }
  }

  @visibleForTesting
  Future<void> clearStorage() async {
    await _statsBox.clear();
    await _usersBox.clear();
  }
}
