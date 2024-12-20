/// model class to define statistics structure
class Statistics {
  final int totalAttempts;
  final int correctGuesses;
  final List<GameAttempt> recentAttempts;

  Statistics({
    required this.totalAttempts,
    required this.correctGuesses,
    required this.recentAttempts,
  });

  double get successRate =>
      totalAttempts > 0 ? (correctGuesses / totalAttempts) * 100 : 0;

  factory Statistics.initial() {
    return Statistics(
      totalAttempts: 0,
      correctGuesses: 0,
      recentAttempts: [],
    );
  }

  Statistics copyWith({
    int? totalAttempts,
    int? correctGuesses,
    List<GameAttempt>? recentAttempts,
  }) {
    return Statistics(
      totalAttempts: totalAttempts ?? this.totalAttempts,
      correctGuesses: correctGuesses ?? this.correctGuesses,
      recentAttempts: recentAttempts ?? this.recentAttempts,
    );
  }
}

/// model for a single try
class GameAttempt {
  final DateTime timestamp;
  final bool wasCorrect;
  final List<String> videoIds;

  GameAttempt({
    required this.timestamp,
    required this.wasCorrect,
    required this.videoIds,
  });
}
