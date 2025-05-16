import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../storage/internal_statistics_storage.dart';
import '../exceptions/app_exceptions.dart';
import '../models/internal_statistics_model.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';

class InternalStatisticsRepository {
  InternalStatisticsStorage? _storage;
  bool _isInitialized = false;

  static final InternalStatisticsRepository _instance =
      InternalStatisticsRepository._internal();
  factory InternalStatisticsRepository() => _instance;
  InternalStatisticsRepository._internal();

  @visibleForTesting
  factory InternalStatisticsRepository.withStorage(
      InternalStatisticsStorage storage) {
    final repository = InternalStatisticsRepository._internal();
    repository._storage = storage;
    return repository;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _initStorage();
    _isInitialized = true;
  }

  Future<void> _initStorage() async {
    _storage ??= InternalStatisticsStorage();
    await _storage!.initialize();
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) await initialize();
  }

  // Grundlegende Datenzugriffsmethoden
  Future<InternalStatistics> _loadStatistics() async {
    await _ensureInitialized();
    try {
      final jsonString = await _storage!.getRawData();
      if (jsonString == null) {
        return InternalStatistics(players: []);
      }
      return InternalStatistics.fromJson(jsonDecode(jsonString));
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      return InternalStatistics(players: []);
    }
  }

  Future<void> _saveStatistics(InternalStatistics statistics) async {
    await _ensureInitialized();
    try {
      final jsonString = jsonEncode(statistics.toJson());
      await _storage!.saveRawData(jsonString);
    } catch (e) {
      throw RepositoryException('Failed to save statistics: $e');
    }
  }

  // Spieler-bezogene Methoden
  Future<InternalPlayerStatistics?> getPlayerStatistics(String playerId) async {
    final statistics = await _loadStatistics();
    return statistics.players.where((p) => p.id == playerId).firstOrNull;
  }

  Future<void> _updatePlayer(InternalPlayerStatistics player) async {
    final statistics = await _loadStatistics();
    final updatedStats = statistics.updatePlayer(player);
    await _saveStatistics(updatedStats);
  }

  // Öffentliche API-Methoden
  Future<void> recordGameStart(String playerId) async {
    try {
      final currentStats = await getPlayerStatistics(playerId);
      final now = DateTime.now();

      final InternalPlayerStatistics updatedStats;
      if (currentStats != null) {
        updatedStats = currentStats.copyWith(
          lastGameTimestamp: now,
        );
      } else {
        updatedStats = InternalPlayerStatistics(
          id: playerId,
          gamesPlayed: 0, // Start mit 0
          correctGuesses: 0,
          loginCount: 0,
          hasCompletedGame: false,
          hasPinRegistered: false,
          hasReturnedWithPin: false,
          firstGameTimestamp: now,
          lastGameTimestamp: now,
        );
      }

      await _updatePlayer(updatedStats);
    } catch (e) {
      throw RepositoryException('Failed to record game start: $e');
    }
  }

  Future<void> recordGameAttempt({
    required String playerId,
    required bool wasCorrect,
    required bool hasPinRegistered,
  }) async {
    try {
      final currentStats = await getPlayerStatistics(playerId);
      final now = DateTime.now();

      final InternalPlayerStatistics updatedStats;
      if (currentStats != null) {
        updatedStats = currentStats.copyWith(
          gamesPlayed: currentStats.gamesPlayed + 1,
          correctGuesses: currentStats.correctGuesses + (wasCorrect ? 1 : 0),
          hasPinRegistered: currentStats.hasPinRegistered || hasPinRegistered,
          lastGameTimestamp: now,
        );
      } else {
        updatedStats = InternalPlayerStatistics(
          id: playerId,
          gamesPlayed: 1,
          correctGuesses: wasCorrect ? 1 : 0,
          loginCount: 0,
          hasCompletedGame: false,
          hasPinRegistered: hasPinRegistered,
          hasReturnedWithPin: false,
          firstGameTimestamp: now,
          lastGameTimestamp: now,
        );
      }

      await _updatePlayer(updatedStats);
    } catch (e) {
      throw RepositoryException('Failed to record game attempt: $e');
    }
  }

  // Für die Aufzeichnung der kompletten Spieldurchführung
  Future<void> recordGameCompletion({
    required String playerId,
    required bool completedFullGame,
    required bool hasPinRegistered,
  }) async {
    try {
      final currentStats = await getPlayerStatistics(playerId);
      final now = DateTime.now();

      if (currentStats != null) {
        final updatedStats = currentStats.copyWith(
          hasCompletedGame: currentStats.hasCompletedGame || completedFullGame,
          hasPinRegistered: currentStats.hasPinRegistered || hasPinRegistered,
          lastGameTimestamp: now,
        );
        await _updatePlayer(updatedStats);
      }
    } catch (e) {
      throw RepositoryException('Failed to record game completion: $e');
    }
  }

  Future<void> recordPinRegistration(
      String oldPlayerId, String newPinId) async {
    try {
      final currentStats = await getPlayerStatistics(oldPlayerId);
      if (currentStats != null) {
        final updatedStats = currentStats.copyWith(
          id: newPinId,
          hasPinRegistered: true,
        );
        await _updatePlayer(updatedStats);
      }
    } catch (e) {
      throw RepositoryException('Failed to record PIN registration: $e');
    }
  }

  Future<void> recordPinLogin(String playerId) async {
    try {
      final currentStats = await getPlayerStatistics(playerId);
      final now = DateTime.now();

      final InternalPlayerStatistics updatedStats;
      if (currentStats != null) {
        updatedStats = currentStats.copyWith(
          loginCount: currentStats.loginCount + 1,
          hasReturnedWithPin: true,
          lastGameTimestamp: now,
        );
      } else {
        updatedStats = InternalPlayerStatistics(
          id: playerId,
          gamesPlayed: 0,
          correctGuesses: 0,
          loginCount: 1,
          hasCompletedGame: false,
          hasPinRegistered: true,
          hasReturnedWithPin: true,
          firstGameTimestamp: now,
          lastGameTimestamp: now,
        );
      }

      await _updatePlayer(updatedStats);
    } catch (e) {
      throw RepositoryException('Failed to record pin login: $e');
    }
  }

  // Statistik-Abruf-Methoden
  Future<InternalStatistics> getOverallStatistics() async {
    return await _loadStatistics();
  }

  Future<Map<String, dynamic>> getFormattedStatistics() async {
    try {
      final stats = await getOverallStatistics();
      return {
        'metadata': {
          'totalPlayers': stats.players.length,
          'timestamp': DateTime.now().toIso8601String(),
          'version': '1.0',
        },
        'overallStats': {
          'totalGamesPlayed': stats.totalGamesPlayed,
          'averageSuccessRate': stats.averageSuccessRate.toStringAsFixed(2),
          'firstTimeQuitters': stats.firstTimeQuitters,
          'playersWithPin': stats.playersWithPin,
          'returnedPlayers': stats.returnedPlayers,
        },
        'playerStats': stats.players
            .map((player) => {
                  'id': player.id,
                  'gamesPlayed': player.gamesPlayed,
                  'successRate': player.successRate.toStringAsFixed(2),
                  'loginCount': player.loginCount,
                  'hasCompletedGame': player.hasCompletedGame,
                  'hasPinRegistered': player.hasPinRegistered,
                  'hasReturnedWithPin': player.hasReturnedWithPin,
                  'firstGame': player.firstGameTimestamp.toIso8601String(),
                  'lastGame': player.lastGameTimestamp?.toIso8601String(),
                })
            .toList(),
      };
    } catch (e) {
      throw RepositoryException('Failed to get formatted statistics: $e');
    }
  }

  Future<void> recordConfidenceRating({
    required String playerId,
    required int rating,
  }) async {
    try {
      final currentStats = await getPlayerStatistics(playerId);

      final InternalPlayerStatistics updatedStats;
      if (currentStats != null) {
        // Aktualisiere das Confidence-Rating
        updatedStats = currentStats.copyWith(
          initialConfidenceRating: rating,
        );
      } else {
        // Neuer Spieler
        updatedStats = InternalPlayerStatistics(
          id: playerId,
          gamesPlayed: 0,
          correctGuesses: 0,
          loginCount: 0,
          hasCompletedGame: false,
          hasPinRegistered: false,
          hasReturnedWithPin: false,
          firstGameTimestamp: DateTime.now(),
          lastGameTimestamp: DateTime.now(),
          initialConfidenceRating: rating,
        );
      }

      await _updatePlayer(updatedStats);
    } catch (e) {
      throw RepositoryException('Failed to record confidence rating: $e');
    }
  }

  // Diese Methode muss komplett überarbeitet werden, da sie JS-Interop verwendet
  void registerDesktopCommands() {
    // Statt Konsolen-Befehlen implementieren wir Desktop-Funktionalität
    // z.B. über Tastenkürzel oder ein Admin-Menü
    debugPrint(
        'Desktop commands registered. Use the export menu option to download statistics.');

    // Hier könnten später Tastaturkürzel oder System-Tray-Menü implementiert werden
  }

  Future<void> exportStatisticsToFile(String filePath) async {
    try {
      final stats = await getFormattedStatistics();
      final jsonString = const JsonEncoder.withIndent('  ').convert(stats);

      final file = File(filePath);
      await file.writeAsString(jsonString);
    } catch (e) {
      throw RepositoryException('Failed to export statistics: $e');
    }
  }

  @visibleForTesting
  Future<void> clear() async {
    await _ensureInitialized();
    await _storage!.clear();
  }
}
