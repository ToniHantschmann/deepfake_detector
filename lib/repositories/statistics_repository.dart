import 'package:deepfake_detector/exceptions/app_exceptions.dart';
import 'package:deepfake_detector/models/statistics_model.dart';
import 'package:deepfake_detector/storage/storage.dart';
import 'package:flutter/foundation.dart';

class StatisticsRepository {
  Storage? _storage;
  final Map<int, UserStatistics> _statistics = {};
  bool _isInitialized = false;

  static final StatisticsRepository _instance =
      StatisticsRepository._internal();
  factory StatisticsRepository() => _instance;

  StatisticsRepository._internal();

  @visibleForTesting
  factory StatisticsRepository.withStorage(Storage storage) {
    final repository = StatisticsRepository._internal();
    repository._storage = storage;
    return repository;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _initStorage();
    await _loadStatistics();
    _isInitialized = true;
  }

  Future<void> _initStorage() async {
    _storage ??= await Storage.getInstance();
  }

  Future<void> _loadStatistics() async {
    try {
      final statsMap = <String, dynamic>{};

      _statistics.forEach((pin, stats) {
        if (!stats.isTemporary) {
          statsMap[pin.toString()] = {
            'totalAttempts': stats.totalAttempts,
            'correctGuesses': stats.correctGuesses,
            'recentAttempts': stats.recentAttempts
                .map((attempt) => {
                      'timestamp': attempt.timestamp.toIso8601String(),
                      'wasCorrect': attempt.wasCorrect,
                      'videoIds': attempt.videoIds,
                      'selectedVideoId': attempt.selectedVideoId,
                    })
                .toList(),
          };
        }
      });

      await _storage!.writeJsonFile(
        Storage.statsFileName,
        {'statistics': statsMap},
      );
    } catch (e) {
      throw StatisticsException('Error loading statistics: $e');
    }
  }

  Future<UserStatistics> getStatistics(int pin) async {
    if (!_isInitialized) await initialize();
    return _statistics[pin] ?? UserStatistics.withPin(pin);
  }

  Future<UserStatistics> addAttempt(
    GameAttempt attempt, {
    int? pin,
    UserStatistics? stats,
  }) async {
    if (!_isInitialized) await initialize();
    try {
      if (pin == null) {
        if (stats == null) {
          throw StatisticsException(
              'Either PIN or current statistics must be provided');
        }
        return _updateTemporaryStats(stats, attempt);
      }
      final updatedStats = await _updatePermanentStats(pin, attempt);
      await _saveStatistics(); // Speichere nach jedem Update
      return updatedStats;
    } catch (e) {
      throw StatisticsException('Failed to add attempt: $e');
    }
  }

  UserStatistics _updateTemporaryStats(
      UserStatistics currentStats, GameAttempt attempt) {
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

  Future<UserStatistics> _updatePermanentStats(
      int pin, GameAttempt attempt) async {
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
    return updatedStats;
  }

  Future<UserStatistics> convertTemporaryStats(
      UserStatistics temporaryStats, int newPin) async {
    if (!_isInitialized) await initialize();
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

  Future<void> _saveStatistics() async {
    try {
      final statsMap = <String, dynamic>{};

      _statistics.forEach((pin, stats) {
        if (!stats.isTemporary) {
          statsMap[pin.toString()] = {
            'totalAttempts': stats.totalAttempts,
            'correctGuesses': stats.correctGuesses,
            'recentAttempts': stats.recentAttempts
                .map((attempt) => {
                      'timestamp': attempt.timestamp.toIso8601String(),
                      'wasCorrect': attempt.wasCorrect,
                      'videoIds': attempt.videoIds,
                      'selectedVideoId': attempt.selectedVideoId,
                    })
                .toList(),
          };
        }
      });

      await _storage!.writeJsonFile(
        Storage.statsFileName,
        {'statistics': statsMap},
      );
    } catch (e) {
      throw StatisticsException('Failed to save statistics: $e');
    }
  }

  Future<void> resetStatistics(int pin) async {
    if (!_isInitialized) await initialize();

    try {
      _statistics[pin] = UserStatistics.withPin(pin);
      await _saveStatistics();
    } catch (e) {
      throw StatisticsException('Failed to reset statistics: $e');
    }
  }

  Future<void> copyStatistics(int fromPin, int toPin) async {
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
