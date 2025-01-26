import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' show window;
import '../exceptions/app_exceptions.dart';
import '../models/statistics_model.dart';

class Storage {
  static const String statsFileName = 'deepfake_stats';
  static const String usersFileName = 'deepfake_users';
  static const String videosFileName = 'assets/data/videos_db.json';

  static Storage? _instance;
  late final Box<Map<int, UserStatistics>> _statsBox;
  late final Box<List<int>> _usersBox;
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
        _statsBox = await Hive.openBox<Map<int, UserStatistics>>(statsFileName);
        _usersBox = await Hive.openBox<List<int>>(usersFileName);
        _initialized = true;
      } catch (e) {
        throw StorageException('Failed to initialize storage: $e');
      }
    }
  }

  Future<List<int>> getUsers() async {
    await _ensureInitialized();
    return _usersBox.get('users', defaultValue: <int>[])!;
  }

  Future<void> saveUsers(List<int> users) async {
    await _ensureInitialized();
    await _usersBox.put('users', users);
  }

  Future<Map<int, UserStatistics>> getStatistics() async {
    await _ensureInitialized();
    return _statsBox.get('statistics', defaultValue: <int, UserStatistics>{})!;
  }

  Future<void> saveStatistics(Map<int, UserStatistics> statistics) async {
    await _ensureInitialized();
    await _statsBox.put('statistics', statistics);
  }

  Future<Map<String, dynamic>> getVideos() async {
    try {
      final String jsonString = await window
          .fetch(videosFileName)
          .then((response) => response.text());
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
