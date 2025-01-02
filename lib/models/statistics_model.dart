import 'package:deepfake_detector/exceptions/app_exceptions.dart';

class UserStatistics {
  final String username;
  final int totalAttempts;
  final int correctGuesses;
  final List<GameAttempt> recentAttempts;

  UserStatistics({
    required this.username,
    required this.totalAttempts,
    required this.correctGuesses,
    required this.recentAttempts,
  });

  double get successRate =>
      totalAttempts > 0 ? (correctGuesses / totalAttempts) * 100 : 0;

  factory UserStatistics.initial(String username) {
    return UserStatistics(
      username: username,
      totalAttempts: 0,
      correctGuesses: 0,
      recentAttempts: [],
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'totalAttempts': totalAttempts,
        'correctGuesses': correctGuesses,
        'recentAttempts': recentAttempts.map((a) => a.toJson()).toList(),
      };

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      username: json['username'] as String,
      totalAttempts: json['totalAttempts'] as int,
      correctGuesses: json['correctGuesses'] as int,
      recentAttempts: (json['recentAttempts'] as List)
          .map((a) => GameAttempt.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  UserStatistics copyWith({
    String? username,
    int? totalAttempts,
    int? correctGuesses,
    List<GameAttempt>? recentAttempts,
  }) {
    return UserStatistics(
      username: username ?? this.username,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      correctGuesses: correctGuesses ?? this.correctGuesses,
      recentAttempts: recentAttempts ?? List.from(this.recentAttempts),
    );
  }
}

/// model for a single try
class GameAttempt {
  final DateTime timestamp;
  final bool wasCorrect;
  final List<String> videoIds;
  final String selectedVideoId;

  GameAttempt({
    required this.timestamp,
    required this.wasCorrect,
    required this.videoIds,
    required this.selectedVideoId,
  }) {
    _validateAttempt();
  }

  void _validateAttempt() {
    final now = DateTime.now();

    if (timestamp.isAfter(now)) {
      throw StatisticsException('Attempt timestamp cannot be in the future');
    }
    if (videoIds.length != 2) {
      throw StatisticsException('Exactly to video IDs are required');
    }
    if (videoIds[0] == videoIds[1]) {
      throw StatisticsException('Video IDs must be different');
    }
    if (!videoIds.contains(selectedVideoId)) {
      throw StatisticsException('Selected video must be in video list');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'wasCorrect': wasCorrect,
      'videoIds': videoIds,
      'selectedVideoId': selectedVideoId,
    };
  }

  factory GameAttempt.fromJson(Map<String, dynamic> json) {
    try {
      //check if all fields exist
      if (!json.containsKey('timestamp') ||
          !json.containsKey('wasCorrect') ||
          !json.containsKey('videoIds') ||
          !json.containsKey('selectedVideoId')) {
        throw StatisticsException('Missing required field in JSON');
      }

      //check if all fields contain correct datatypes
      if (json['timestamp'] is! String ||
          json['wasCorrect'] is! bool ||
          json['videoIds'] is! List ||
          json['selectedVideoId'] is! String) {
        throw StatisticsException('Invalid data types in JSON');
      }

      // get videoIds
      final videoIds = (json['videoIds'] as List).map((id) {
        if (id is! String) {
          throw StatisticsException('Video IDs must be strings');
        }
        return id;
      }).toList();

      return GameAttempt(
        timestamp: DateTime.parse(json['timestamp'] as String),
        wasCorrect: json['wasCorrect'] as bool,
        videoIds: videoIds,
        selectedVideoId: json['selectedVideoId'] as String,
      );
    } catch (e) {
      if (e is StatisticsException) {
        rethrow;
      }
      throw StatisticsException('failed to parse GameAttempt from JSON: $e');
    }
  }
}
