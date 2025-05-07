import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' show window;
import '../exceptions/app_exceptions.dart';
import '../models/statistics_model.dart';
import 'dart:js' as js;

class Storage {
  static const String statsFileName = 'deepfake_stats';
  static const String usersFileName = 'deepfake_users';
  static const String videosFileName = 'assets/data/videos_db.json';

  static Storage? _instance;
  late final Box _statsBox;
  late final Box _usersBox;
  bool _initialized = false;

  bool get isElectron => kIsWeb && window.location.protocol == 'file:';

  static Future<Storage> getInstance() async {
    _instance ??= Storage._internal();
    await _instance!._init();
    return _instance!;
  }

  Storage._internal();

  Future<void> _init() async {
    if (!_initialized) {
      try {
        // Modified initialization for Electron compatibility
        if (kIsWeb) {
          if (isElectron) {
            // For Electron, we specify a storage path
            await Hive.initFlutter('deepfake_detector_storage');
          } else {
            // Regular web initialization
            await Hive.initFlutter();
          }
        } else {
          // Native app initialization
          await Hive.initFlutter();
        }

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
      String jsonString;

      if (isElectron) {
        // Für Electron, verwenden wir einen anderen Ansatz zum Laden von Assets
        jsonString = await _loadAssetInElectron(videosFileName);
      } else {
        // Originaler Web-Ansatz
        jsonString = await window
            .fetch(videosFileName)
            .then((response) => response.text());
      }

      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw StorageException('Failed to read asset file $videosFileName: $e');
    }
  }

  Future<String> _loadAssetInElectron(String assetPath) async {
    try {
      // Versuche zuerst, die Electron-spezifische API zu verwenden
      if (js.context.hasProperty('electronFileSystem')) {
        final result = js.context
            .callMethod('electronFileSystem.readAssetFile', [assetPath]);
        return result.toString();
      }

      // Fallback: Verwende XMLHttpRequest (funktioniert besser mit file:// Protokoll)
      final completer = Completer<String>();

      try {
        final xhr = js.context.callMethod('eval', ['new XMLHttpRequest()']);

        js.context.callMethod('eval', [
          '''
          (function(xhr, path, completer) {
            xhr.open('GET', path, true);
            xhr.onload = function() {
              if (xhr.status == 200) {
                completer(xhr.responseText);
              } else {
                completer("Error: " + xhr.statusText);
              }
            };
            xhr.onerror = function() {
              completer("Error loading asset");
            };
            xhr.send();
          })(arguments[0], arguments[1], arguments[2]);
        ''',
          xhr,
          assetPath,
          (result) {
            if (result.toString().startsWith('Error:')) {
              completer.completeError(result.toString());
            } else {
              completer.complete(result.toString());
            }
          }
        ]);

        return await completer.future;
      } catch (e) {
        throw StorageException('Failed to load asset with XHR: $e');
      }
    } catch (e) {
      throw StorageException('All attempts to load asset failed: $e');
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
