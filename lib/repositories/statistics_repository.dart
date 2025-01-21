import 'package:deepfake_detector/exceptions/app_exceptions.dart';
import 'package:deepfake_detector/models/statistics_model.dart';
import 'package:deepfake_detector/storage/json_storage.dart';
import 'package:flutter/foundation.dart';

/// Repository class to manage statistics
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

      for (final entry in data.entries) {
        if (entry.value is Map<String, dynamic>) {
          _statistics[entry.key] =
              UserStatistics.fromJson(entry.value as Map<String, dynamic>);
        }
      }
    } catch (e) {
      throw StatisticsException('Error when loading statistics: $e');
    }
  }

  /// Get statistics for a specific PIN
  /// Returns [UserStatistics] for the given PIN
  /// Creates new statistics if none exist
  Future<UserStatistics> getStatistics(String pin) async {
    if (!_isInitialized) await initialize();

    return _statistics[pin] ?? UserStatistics.initial(pin);
  }

  /// Add a new attempt to a PIN's statistics
  /// [pin]: The PIN to add statistics for
  /// [attempt]: The GameAttempt to add
  /// Throws [StatisticsException] if the operation fails
  Future<void> addAttempt(String pin, GameAttempt attempt) async {
    if (!_isInitialized) await initialize();

    try {
      final stats = await getStatistics(pin);

      final updatedStats = stats.copyWith(
        totalAttempts: stats.totalAttempts + 1,
        correctGuesses: stats.correctGuesses + (attempt.wasCorrect ? 1 : 0),
        recentAttempts: [
          ...stats.recentAttempts,
          attempt,
        ].take(10).toList(), // Keep only last 10 attempts
      );

      _statistics[pin] = updatedStats;
      await _saveStatistics();
    } catch (e) {
      throw StatisticsException('Failed to add attempt: $e');
    }
  }

  /// Reset statistics for a specific PIN
  /// [pin]: The PIN to reset statistics for
  /// Throws [StatisticsException] if the operation fails
  Future<void> resetStatistics(String pin) async {
    if (!_isInitialized) await initialize();

    try {
      _statistics[pin] = UserStatistics.initial(pin);
      await _saveStatistics();
    } catch (e) {
      throw StatisticsException('Failed to reset statistics: $e');
    }
  }

  /// Save all statistics to storage
  Future<void> _saveStatistics() async {
    try {
      final data = Map<String, dynamic>.fromEntries(
        _statistics.entries
            .map((entry) => MapEntry(entry.key, entry.value.toJson())),
      );

      await _storage.writeJsonFile(JsonStorage.statsFileName, data);
    } catch (e) {
      throw StatisticsException('Failed to save statistics: $e');
    }
  }

  /// Copies statistics from one PIN to another
  /// [fromPin]: Source PIN
  /// [toPin]: Target PIN
  /// Throws [StatisticsException] if one of the PINs doesn't exist
  Future<void> copyStatistics(String fromPin, String toPin) async {
    if (!_isInitialized) await initialize();

    try {
      final sourceStats = _statistics[fromPin];
      if (sourceStats == null) {
        throw StatisticsException('Source PIN statistics not found');
      }

      // Create new statistics for the target PIN
      final newStats = UserStatistics(
        pin: toPin,
        totalAttempts: sourceStats.totalAttempts,
        correctGuesses: sourceStats.correctGuesses,
        recentAttempts: List.from(sourceStats.recentAttempts),
      );

      // Save the new statistics
      _statistics[toPin] = newStats;
      await _saveStatistics();
    } catch (e) {
      if (e is StatisticsException) rethrow;
      throw StatisticsException('Failed to copy statistics: $e');
    }
  }
}
