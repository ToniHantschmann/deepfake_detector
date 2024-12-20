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
}
