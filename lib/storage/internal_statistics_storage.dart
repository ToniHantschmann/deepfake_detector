// internal_statistics_storage.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../exceptions/app_exceptions.dart';
import '../models/internal_statistics_model.dart';

class InternalStatisticsStorage {
  static const String _statsBoxName = 'internal_statistics';
  static const String _statsKey = 'stats';

  late Box _box;
  bool _initialized = false;

  // Singleton pattern
  static final InternalStatisticsStorage _instance =
      InternalStatisticsStorage._internal();

  factory InternalStatisticsStorage() => _instance;

  InternalStatisticsStorage._internal();

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _box = await Hive.openBox(_statsBoxName);
      _initialized = true;
    } catch (e) {
      throw StorageException('Failed to initialize internal statistics: $e');
    }
  }

  Future<InternalStatistics> getStatistics() async {
    await _ensureInitialized();

    try {
      final jsonString = _box.get(_statsKey);
      if (jsonString == null) {
        return InternalStatistics(players: []);
      }

      final Map<String, dynamic> jsonData =
          jsonDecode(jsonString) as Map<String, dynamic>;
      return InternalStatistics.fromJson(jsonData);
    } catch (e) {
      debugPrint('Error loading internal statistics: $e');
      return InternalStatistics(players: []);
    }
  }

  Future<void> saveStatistics(InternalStatistics statistics) async {
    await _ensureInitialized();

    try {
      final jsonString = jsonEncode(statistics.toJson());
      await _box.put(_statsKey, jsonString);
    } catch (e) {
      throw StorageException('Failed to save internal statistics: $e');
    }
  }

  Future<void> updatePlayerStatistics(InternalPlayerStatistics player) async {
    await _ensureInitialized();

    try {
      final statistics = await getStatistics();
      final updatedStatistics = statistics.updatePlayer(player);
      await saveStatistics(updatedStatistics);
    } catch (e) {
      throw StorageException('Failed to update player statistics: $e');
    }
  }

  Future<InternalPlayerStatistics?> getPlayerStatistics(String playerId) async {
    await _ensureInitialized();

    try {
      final statistics = await getStatistics();
      return statistics.players.firstWhere(
        (player) => player.id == playerId,
        orElse: () => throw PlayerNotFoundException(),
      );
    } on PlayerNotFoundException {
      return null;
    } catch (e) {
      throw StorageException('Failed to get player statistics: $e');
    }
  }

  Future<void> recordGameCompletion({
    required String playerId,
    required bool wasCorrect,
    bool completedFullGame = false,
    bool hasPinRegistered = false,
  }) async {
    await _ensureInitialized();

    try {
      final currentStats = await getPlayerStatistics(playerId);
      final now = DateTime.now();

      final updatedStats = currentStats != null
          ? currentStats.copyWith(
              gamesPlayed: currentStats.gamesPlayed + 1,
              correctGuesses:
                  currentStats.correctGuesses + (wasCorrect ? 1 : 0),
              hasCompletedGame:
                  currentStats.hasCompletedGame || completedFullGame,
              hasPinRegistered:
                  currentStats.hasPinRegistered || hasPinRegistered,
              lastGameTimestamp: now,
            )
          : InternalPlayerStatistics.newPlayer(playerId).copyWith(
              gamesPlayed: 1,
              correctGuesses: wasCorrect ? 1 : 0,
              hasCompletedGame: completedFullGame,
              hasPinRegistered: hasPinRegistered,
              lastGameTimestamp: now,
            );

      await updatePlayerStatistics(updatedStats);
    } catch (e) {
      throw StorageException('Failed to record game completion: $e');
    }
  }

  Future<void> recordPinLogin(String playerId) async {
    await _ensureInitialized();

    try {
      final currentStats = await getPlayerStatistics(playerId);
      if (currentStats == null) {
        throw PlayerNotFoundException();
      }

      final updatedStats = currentStats.copyWith(
        loginCount: currentStats.loginCount + 1,
        hasReturnedWithPin: true,
      );

      await updatePlayerStatistics(updatedStats);
    } catch (e) {
      throw StorageException('Failed to record pin login: $e');
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  @visibleForTesting
  Future<void> clear() async {
    await _ensureInitialized();
    await _box.clear();
  }
}
