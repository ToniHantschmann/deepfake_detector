import 'package:flutter/foundation.dart';
import '../storage/internal_statistics_storage.dart';
import '../exceptions/app_exceptions.dart';
import '../models/internal_statistics_model.dart';
import 'dart:convert';
import 'dart:js' as js;
import 'dart:html' as html;

class InternalStatisticsRepository {
  InternalStatisticsStorage? _storage;
  bool _isInitialized = false;

  // Singleton pattern
  static final InternalStatisticsRepository _instance =
      InternalStatisticsRepository._internal();
  factory InternalStatisticsRepository() => _instance;
  InternalStatisticsRepository._internal();

  // Test constructor for dependency injection
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

  // Hauptmethoden für die Spielstatistiken
  Future<void> recordGameStart(String playerId) async {
    await _ensureInitialized();
    try {
      await _storage!.recordGameCompletion(
        playerId: playerId,
        wasCorrect: false,
        completedFullGame: false,
        hasPinRegistered: false,
      );
    } catch (e) {
      throw RepositoryException('Failed to record game start: $e');
    }
  }

  Future<void> recordGameCompletion({
    required String playerId,
    required bool wasCorrect,
    required bool completedFullGame,
    required bool hasPinRegistered,
  }) async {
    await _ensureInitialized();
    try {
      await _storage!.recordGameCompletion(
        playerId: playerId,
        wasCorrect: wasCorrect,
        completedFullGame: completedFullGame,
        hasPinRegistered: hasPinRegistered,
      );
    } catch (e) {
      throw RepositoryException('Failed to record game completion: $e');
    }
  }

  Future<void> recordPinRegistration(
      String oldPlayerId, String newPinId) async {
    await _ensureInitialized();
    try {
      final currentStats = await _storage!.getPlayerStatistics(oldPlayerId);
      if (currentStats != null) {
        final updatedStats = currentStats.copyWith(
          id: newPinId,
          hasPinRegistered: true,
        );
        await _storage!.updatePlayerStatistics(updatedStats);
      }
    } catch (e) {
      throw RepositoryException('Failed to record PIN registration: $e');
    }
  }

  Future<void> recordPinLogin(String playerId) async {
    await _ensureInitialized();
    try {
      await _storage!.recordPinLogin(playerId);
    } catch (e) {
      throw RepositoryException('Failed to record PIN login: $e');
    }
  }

  // Methoden zum Abrufen der Statistiken
  Future<InternalStatistics> getOverallStatistics() async {
    await _ensureInitialized();
    try {
      return await _storage!.getStatistics();
    } catch (e) {
      throw RepositoryException('Failed to get overall statistics: $e');
    }
  }

  Future<InternalPlayerStatistics?> getPlayerStatistics(String playerId) async {
    await _ensureInitialized();
    try {
      return await _storage!.getPlayerStatistics(playerId);
    } catch (e) {
      if (e is PlayerNotFoundException) return null;
      throw RepositoryException('Failed to get player statistics: $e');
    }
  }

  // Neue Methode um formatierte Statistiken zu erhalten
  Future<Map<String, dynamic>> getFormattedStatistics() async {
    await _ensureInitialized();
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

  // Methode zum Registrieren der Konsolen-Funktionen
  void registerConsoleCommands() {
    // Füge die getStats Funktion zum window-Objekt hinzu
    js.context['getDeepfakeStats'] = () async {
      try {
        final stats = await getFormattedStatistics();
        final jsonString = JsonEncoder.withIndent('  ').convert(stats);
        js.context.callMethod('console.log', ['Deepfake Statistics:']);
        js.context.callMethod('console.log', [jsonString]);

        // Erstelle einen Blob und einen Download-Link
        final blob = html.Blob([jsonString], 'text/plain');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');

        final anchor = html.AnchorElement()
          ..href = url
          ..download = 'deepfake_stats_$timestamp.json'
          ..style.display = 'none';

        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        return stats;
      } catch (e) {
        js.context.callMethod(
            'console.error', ['Error getting statistics: ${e.toString()}']);
        return null;
      }
    };

    // Dokumentation in der Konsole ausgeben
    js.context.callMethod('console.info', [
      '''
Available commands for Deepfake Statistics:
- getDeepfakeStats(): Logs and downloads the current statistics
    '''
    ]);
  }

  @visibleForTesting
  Future<void> clear() async {
    await _ensureInitialized();
    await _storage!.clear();
  }
}
