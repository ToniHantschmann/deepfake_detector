import '../models/statistics_model.dart';

/// repository class for player statistics
class StatisticsRepository {
  Statistics _currentStats = Statistics.initial();

  static final StatisticsRepository _instance =
      StatisticsRepository._internal();

  factory StatisticsRepository() {
    return _instance;
  }

  StatisticsRepository._internal();

  Future<Statistics> getStatistics() async {
    try {
      /*
      TODO:
        get statistics database and parse data to [list] of statistics
      */
      return _currentStats;
    } catch (e) {
      throw Exception("Failed to load statistics $e");
    }
  }

  /*
  TODO:
    add helper methods for Statistics class
    addAttempt()
    _saveStatistics()
    resetStatistics()??
  */

  /// add new attempt to existing statistic
  Future<void> addAttempt(GameAttempt attempt) async {
    try {
      // get copy of list recentAttempts and add new attempt
      final updatedAttempts =
          List<GameAttempt>.from(_currentStats.recentAttempts);
      updatedAttempts.add(attempt);

      _currentStats = _currentStats.copyWith(
        totalAttempts: _currentStats.totalAttempts + 1,
        correctGuesses:
            _currentStats.correctGuesses + (attempt.wasCorrect ? 1 : 0),
        recentAttempts: updatedAttempts,
      );
      await _saveStatistics();
    } catch (e) {
      throw Exception("Failed to add attempt: $e");
    }
  }

  Future<void> _saveStatistics() async {
    //todo: implement database or json
  }

  Future<void> resetStatistics() async {
    try {
      _currentStats = Statistics.initial();
      await _saveStatistics();
    } catch (e) {
      throw Exception("Failed to reset statistics $e");
    }
  }
}
