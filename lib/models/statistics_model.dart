import 'package:deepfake_detector/exceptions/app_exceptions.dart';

class UserStatistics {
  final String? pin; // Optional PIN für temporäre Statistiken
  final int totalAttempts;
  final int correctGuesses;
  final List<GameAttempt> recentAttempts;
  final bool isTemporary; // Neues Flag für temporäre Statistiken

  UserStatistics({
    this.pin,
    required this.totalAttempts,
    required this.correctGuesses,
    required this.recentAttempts,
  }) : isTemporary = pin == null {
    _validateStatistics();
  }

  void _validateStatistics() {
    if (!isTemporary && (pin == null || pin!.isEmpty)) {
      throw StatisticsException('Permanent statistics require a valid PIN');
    }

    if (totalAttempts < 0) {
      throw StatisticsException('Total attempts cannot be negative');
    }

    if (correctGuesses < 0 || correctGuesses > totalAttempts) {
      throw StatisticsException('Invalid number of correct guesses');
    }
  }

  double get successRate =>
      totalAttempts > 0 ? (correctGuesses / totalAttempts) * 100 : 0;

  // Factory für temporäre Statistiken
  factory UserStatistics.temporary() {
    return UserStatistics(
      pin: null,
      totalAttempts: 0,
      correctGuesses: 0,
      recentAttempts: [],
    );
  }

  // Factory für permanente Statistiken
  factory UserStatistics.withPin(String pin) {
    if (pin.isEmpty) {
      throw StatisticsException('PIN cannot be empty');
    }
    return UserStatistics(
      pin: pin,
      totalAttempts: 0,
      correctGuesses: 0,
      recentAttempts: [],
    );
  }

  // Konvertierung zu permanenten Statistiken
  UserStatistics toPermanent(String newPin) {
    if (newPin.isEmpty) {
      throw StatisticsException('Cannot convert to permanent with empty PIN');
    }
    return copyWith(pin: newPin);
  }

  Map<String, dynamic> toJson() => {
        'pin': pin,
        'totalAttempts': totalAttempts,
        'correctGuesses': correctGuesses,
        'recentAttempts': recentAttempts.map((a) => a.toJson()).toList(),
        'isTemporary': isTemporary,
      };

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      pin: json['pin'] as String?,
      totalAttempts: json['totalAttempts'] as int,
      correctGuesses: json['correctGuesses'] as int,
      recentAttempts: (json['recentAttempts'] as List)
          .map((a) => GameAttempt.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  UserStatistics copyWith({
    String? pin,
    int? totalAttempts,
    int? correctGuesses,
    List<GameAttempt>? recentAttempts,
  }) {
    return UserStatistics(
      pin: pin ?? this.pin,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      correctGuesses: correctGuesses ?? this.correctGuesses,
      recentAttempts: recentAttempts ?? List.from(this.recentAttempts),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatistics &&
          pin == other.pin &&
          totalAttempts == other.totalAttempts &&
          correctGuesses == other.correctGuesses;

  @override
  int get hashCode =>
      pin.hashCode ^ totalAttempts.hashCode ^ correctGuesses.hashCode;
}

/// Model for a single game attempt
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
      throw StatisticsException('Exactly two video IDs are required');
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
      if (!json.containsKey('timestamp') ||
          !json.containsKey('wasCorrect') ||
          !json.containsKey('videoIds') ||
          !json.containsKey('selectedVideoId')) {
        throw StatisticsException('Missing required field in JSON');
      }

      if (json['timestamp'] is! String ||
          json['wasCorrect'] is! bool ||
          json['videoIds'] is! List ||
          json['selectedVideoId'] is! String) {
        throw StatisticsException('Invalid data types in JSON');
      }

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
      if (e is StatisticsException) rethrow;
      throw StatisticsException('Failed to parse GameAttempt from JSON: $e');
    }
  }
}
