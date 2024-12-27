import '../models/statistics_model.dart';
import '../storage/json_storage.dart';

/// repository class for player statistics
class StatisticsRepository {
  late final JsonStorage _storage;

  static final StatisticsRepository _instance =
      StatisticsRepository._internal();

  factory StatisticsRepository() {
    return _instance;
  }

  StatisticsRepository._internal() {
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storage = await JsonStorage.getInstance();
  }

  Future<UserStatistics> getStatistics(String username) async {
    try {
      final data = await _storage.readJsonFile(JsonStorage.statsFileName);
      final userStats = data[username] as Map<String, dynamic>?;

      if (userStats == null) {
        return UserStatistics.initial(username);
      }

      return UserStatistics.fromJson(userStats);
    } catch (e) {
      throw Exception("Failed to load statistics $e");
    }
  }

  /// add new attempt to existing statistic
  Future<void> addAttempt(String username, GameAttempt attempt) async {
    try {
      final data = await _storage.readJsonFile(JsonStorage.statsFileName);
      final stats = await getStatistics(username);

      final updatedStats = stats.copyWith(
        totalAttempts: stats.totalAttempts + 1,
        correctGuesses: stats.correctGuesses + (attempt.wasCorrect ? 1 : 0),
        recentAttempts: [
          ...stats.recentAttempts,
          attempt,
        ].toList(),
      );

      data[username] = updatedStats.toJson();
      await _storage.writeJsonFile(JsonStorage.statsFileName, data);
    } catch (e) {
      throw Exception("Failed to add attempt: $e");
    }
  }

  Future<void> resetStatistics(String username) async {
    try {
      final data = await _storage.readJsonFile(JsonStorage.statsFileName);
      data[username] = UserStatistics.initial(username).toJson();
      await _storage.writeJsonFile(JsonStorage.statsFileName, data);
    } catch (e) {
      throw Exception("Failed to reset statistics $e");
    }
  }
}
