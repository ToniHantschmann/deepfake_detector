import 'package:deepfake_detector/exceptions/app_exceptions.dart';
import 'package:deepfake_detector/models/statistics_model.dart';
import 'package:deepfake_detector/storage/json_storage.dart';
import 'package:flutter/foundation.dart';

/// Repository class to manage user statistics
class StatisticsRepository {
  late final JsonStorage _storage;
  final Map<String, UserStatistics> _statistics = {};
  bool _isInitialized = false;
  bool _isStorageProvided = false;

  static final StatisticsRepository _instance =
      StatisticsRepository._internal();

  factory StatisticsRepository() => _instance;

  StatisticsRepository._internal();

  /// Constructor for testing purposes that allows injecting a mock storage
  @visibleForTesting
  factory StatisticsRepository.withStorage(JsonStorage storage) {
    final repository = StatisticsRepository._internal();
    repository._storage = storage;
    repository._isStorageProvided = true;
    repository._isInitialized = false;
    repository._statistics.clear();
    return repository;
  }

  /// Initialize the repository
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

  /// Get statistics for a specific user
  /// Returns [UserStatistics] for the given username
  /// Creates new statistics if none exist
  Future<UserStatistics> getStatistics(String username) async {
    if (!_isInitialized) await initialize();

    return _statistics[username] ?? UserStatistics.initial(username);
  }

  /// Add a new attempt to a user's statistics
  /// Throws [StatisticsException] if the operation fails
  Future<void> addAttempt(String username, GameAttempt attempt) async {
    if (!_isInitialized) await initialize();

    try {
      final stats = await getStatistics(username);

      final updatedStats = stats.copyWith(
        totalAttempts: stats.totalAttempts + 1,
        correctGuesses: stats.correctGuesses + (attempt.wasCorrect ? 1 : 0),
        recentAttempts: [
          ...stats.recentAttempts,
          attempt,
        ].take(10).toList(), // Keep only last 10 attempts
      );

      _statistics[username] = updatedStats;

      await _saveStatistics();
    } catch (e) {
      throw StatisticsException('Failed to add attempt: $e');
    }
  }

  /// Reset statistics for a specific user
  /// Throws [StatisticsException] if the operation fails
  Future<void> resetStatistics(String username) async {
    if (!_isInitialized) await initialize();

    try {
      _statistics[username] = UserStatistics.initial(username);
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

  /// Kopiert die Statistiken von einem User zu einem anderen
  /// [fromUsername]: Quell-Username
  /// [toUsername]: Ziel-Username
  /// Throws [StatisticsException] wenn einer der User nicht existiert
  Future<void> copyStatistics(String fromUsername, String toUsername) async {
    if (!_isInitialized) await initialize();

    try {
      // Prüfe ob Source-Statistiken existieren
      final sourceStats = _statistics[fromUsername];
      if (sourceStats == null) {
        throw StatisticsException('Source user statistics not found');
      }

      // Erstelle neue Statistiken für den Ziel-User
      final newStats = UserStatistics(
        username: toUsername,
        totalAttempts: sourceStats.totalAttempts,
        correctGuesses: sourceStats.correctGuesses,
        recentAttempts: List.from(sourceStats.recentAttempts),
      );

      // Speichere die neuen Statistiken
      _statistics[toUsername] = newStats;
      await _saveStatistics();
    } catch (e) {
      if (e is StatisticsException) rethrow;
      throw StatisticsException('Failed to copy statistics: $e');
    }
  }
}
