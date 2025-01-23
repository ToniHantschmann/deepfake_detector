import 'package:deepfake_detector/exceptions/app_exceptions.dart';
import 'package:deepfake_detector/models/statistics_model.dart';
import 'package:deepfake_detector/storage/json_storage.dart';
import 'package:flutter/foundation.dart';

/// Repository zur Verwaltung von Statistiken (temporär und permanent)
class StatisticsRepository {
  late final JsonStorage _storage;
  final Map<String, UserStatistics> _statistics = {};
  bool _isInitialized = false;
  bool _isStorageProvided = false;

  static final StatisticsRepository _instance =
      StatisticsRepository._internal();
  factory StatisticsRepository() => _instance;

  StatisticsRepository._internal();

  @visibleForTesting
  factory StatisticsRepository.withStorage(JsonStorage storage) {
    final repository = StatisticsRepository._internal();
    repository._storage = storage;
    repository._isStorageProvided = true;
    repository._isInitialized = false;
    repository._statistics.clear();
    return repository;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _initStorage();
    await _loadStatistics();
    _isInitialized = true;
  }

  Future<void> _initStorage() async {
    if (!_isStorageProvided) {
      _storage = await JsonStorage.getInstance();
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final data = await _storage.readJsonFile(JsonStorage.statsFileName);
      _statistics.clear();

      final statisticsData = data['statistics'];
      if (statisticsData != null && statisticsData is Map) {
        for (final entry in statisticsData.entries) {
          if (entry.value is Map) {
            // Prüfen ob der Wert eine Map ist
            try {
              // Sichere Konvertierung zu Map<String, dynamic>
              final Map<String, dynamic> statsData =
                  Map<String, dynamic>.from(entry.value as Map);
              final stats = UserStatistics.fromJson(statsData);
              if (!stats.isTemporary && stats.pin != null) {
                _statistics[stats.pin!] = stats;
              }
            } catch (e) {
              print('Error parsing statistics for entry: $e');
              continue;
            }
          }
        }
      }
    } catch (e) {
      throw StatisticsException('Error when loading statistics: $e');
    }
  }

  /// Hole Statistiken für einen PIN
  /// Wenn keine existieren, werden neue permanente Statistiken erstellt
  Future<UserStatistics> getStatistics(String pin) async {
    if (!_isInitialized) await initialize();
    return _statistics[pin] ?? UserStatistics.withPin(pin);
  }

  /// Fügt einen neuen Versuch zu den Statistiken hinzu
  /// [pin]: PIN der Statistiken (optional für temporäre Stats)
  /// [attempt]: Der neue Spielversuch
  /// [stats]: Aktuelle Statistiken (optional, für temporäre Stats)
  /// Returns: Aktualisierte Statistiken
  Future<UserStatistics> addAttempt(
    GameAttempt attempt, {
    String? pin,
    UserStatistics? stats,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Behandle temporäre Statistiken
      if (pin == null) {
        if (stats == null) {
          throw StatisticsException(
              'Either PIN or current statistics must be provided');
        }
        return _updateTemporaryStats(stats, attempt);
      }

      // Behandle permanente Statistiken
      return await _updatePermanentStats(pin, attempt);
    } catch (e) {
      throw StatisticsException('Failed to add attempt: $e');
    }
  }

  /// Aktualisiert temporäre Statistiken (nicht persistent)
  UserStatistics _updateTemporaryStats(
    UserStatistics currentStats,
    GameAttempt attempt,
  ) {
    if (!currentStats.isTemporary) {
      throw StatisticsException('Cannot update permanent stats as temporary');
    }

    return currentStats.copyWith(
      totalAttempts: currentStats.totalAttempts + 1,
      correctGuesses:
          currentStats.correctGuesses + (attempt.wasCorrect ? 1 : 0),
      recentAttempts: [
        ...currentStats.recentAttempts,
        attempt,
      ].take(10).toList(),
    );
  }

  /// Aktualisiert permanente Statistiken (persistent)
  Future<UserStatistics> _updatePermanentStats(
    String pin,
    GameAttempt attempt,
  ) async {
    final stats = await getStatistics(pin);
    final updatedStats = stats.copyWith(
      totalAttempts: stats.totalAttempts + 1,
      correctGuesses: stats.correctGuesses + (attempt.wasCorrect ? 1 : 0),
      recentAttempts: [
        ...stats.recentAttempts,
        attempt,
      ].take(10).toList(),
    );

    _statistics[pin] = updatedStats;
    await _saveStatistics();
    return updatedStats;
  }

  /// Konvertiert und speichert temporäre Statistiken mit neuem PIN
  Future<UserStatistics> convertTemporaryStats(
    UserStatistics temporaryStats,
    String newPin,
  ) async {
    if (!temporaryStats.isTemporary) {
      throw StatisticsException('Statistics are already permanent');
    }

    if (_statistics.containsKey(newPin)) {
      throw StatisticsException('PIN already exists');
    }

    final permanentStats = temporaryStats.toPermanent(newPin);
    _statistics[newPin] = permanentStats;
    await _saveStatistics();
    return permanentStats;
  }

  /// Speichert alle permanenten Statistiken
  Future<void> _saveStatistics() async {
    try {
      final data = {
        'statistics': Map.fromEntries(
          _statistics.entries.map(
            (entry) => MapEntry(entry.key, entry.value.toJson()),
          ),
        ),
      };

      await _storage.writeJsonFile(JsonStorage.statsFileName, data);
    } catch (e) {
      throw StatisticsException('Failed to save statistics: $e');
    }
  }

  /// Löscht Statistiken für einen PIN
  Future<void> resetStatistics(String pin) async {
    if (!_isInitialized) await initialize();

    try {
      _statistics[pin] = UserStatistics.withPin(pin);
      await _saveStatistics();
    } catch (e) {
      throw StatisticsException('Failed to reset statistics: $e');
    }
  }

  /// Kopiert Statistiken von einem PIN zu einem anderen
  Future<void> copyStatistics(String fromPin, String toPin) async {
    if (!_isInitialized) await initialize();

    try {
      final sourceStats = _statistics[fromPin];
      if (sourceStats == null) {
        throw StatisticsException('Source PIN statistics not found');
      }

      _statistics[toPin] = sourceStats.copyWith(pin: toPin);
      await _saveStatistics();
    } catch (e) {
      if (e is StatisticsException) rethrow;
      throw StatisticsException('Failed to copy statistics: $e');
    }
  }
}
