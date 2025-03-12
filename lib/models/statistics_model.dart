import 'package:deepfake_detector/config/localization/app_locale.dart';
import 'package:deepfake_detector/exceptions/app_exceptions.dart';
import 'package:deepfake_detector/utils/pin_generator_service.dart';

class UserStatistics {
  final int? pin;
  final int totalAttempts;
  final int correctGuesses;
  final List<GameAttempt> recentAttempts;
  final bool isTemporary;
  final Set<String> seenPairIds;
  final AppLocale locale;

  UserStatistics({
    this.pin,
    required this.totalAttempts,
    required this.correctGuesses,
    required this.recentAttempts,
    Set<String>? seenPairIds,
    bool? isTemporary,
    AppLocale? locale,
  })  : seenPairIds = seenPairIds ?? {},
        isTemporary = isTemporary ?? (pin == null),
        locale = locale ?? AppLocale.de {
    _validateStatistics();
  }

  void _validateStatistics() {
    if (!isTemporary &&
        (pin == null || !PinGeneratorService.isValidPin(pin!))) {
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
  factory UserStatistics.withPin(int pin) {
    return UserStatistics(
      pin: pin,
      totalAttempts: 0,
      correctGuesses: 0,
      recentAttempts: [],
    );
  }

  // Konvertierung zu permanenten Statistiken
  UserStatistics toPermanent(int newPin) {
    return copyWith(pin: newPin);
  }

  Map<String, dynamic> toJson() => {
        'pin': pin,
        'totalAttempts': totalAttempts,
        'correctGuesses': correctGuesses,
        'recentAttempts': recentAttempts.map((a) => a.toJson()).toList(),
        'seenPairIds': seenPairIds.toList(),
        'locale': locale.index,
      };

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      pin: json['pin'] as int?,
      totalAttempts: json['totalAttempts'] as int,
      correctGuesses: json['correctGuesses'] as int,
      recentAttempts: (json['recentAttempts'] as List).map((a) {
        // a ist hier Map<dynamic, dynamic>, muss erst gecastet werden
        final Map<String, dynamic> attemptMap =
            (a as Map<dynamic, dynamic>).cast<String, dynamic>();
        return GameAttempt.fromJson(attemptMap);
      }).toList(),
      seenPairIds: (json['seenPairIds'] as List?)?.cast<String>().toSet() ?? {},
      locale: AppLocale.values[json['locale'] as int],
    );
  }

  UserStatistics copyWith({
    int? pin,
    int? totalAttempts,
    int? correctGuesses,
    List<GameAttempt>? recentAttempts,
    Set<String>? seenPairIds,
    AppLocale? locale,
  }) {
    return UserStatistics(
      pin: pin ?? this.pin,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      correctGuesses: correctGuesses ?? this.correctGuesses,
      recentAttempts: recentAttempts ?? List.from(this.recentAttempts),
      seenPairIds: seenPairIds ?? Set.from(this.seenPairIds),
      locale: locale ?? this.locale,
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
  final bool userGuessIsDeepfake;
  final String pairId;

  GameAttempt({
    required this.timestamp,
    required this.wasCorrect,
    required this.videoIds,
    required this.userGuessIsDeepfake,
    required this.pairId,
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
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'wasCorrect': wasCorrect,
      'videoIds': videoIds,
      'userGuessIsDeepfake': userGuessIsDeepfake,
      'pairId': pairId,
    };
  }

  factory GameAttempt.fromJson(Map<String, dynamic> json) {
    try {
      if (!json.containsKey('timestamp') ||
          !json.containsKey('wasCorrect') ||
          !json.containsKey('videoIds') ||
          !json.containsKey('userGuessIsDeepfake') ||
          !json.containsKey('pairId')) {
        throw StatisticsException('Missing required field in JSON');
      }

      if (json['timestamp'] is! String ||
          json['wasCorrect'] is! bool ||
          json['videoIds'] is! List ||
          json['userGuessIsDeepfake'] is! bool ||
          json['pairId'] is! String) {
        throw StatisticsException('Invalid data types in JSON');
      }

      return GameAttempt(
        timestamp: DateTime.parse(json['timestamp'] as String),
        wasCorrect: json['wasCorrect'] as bool,
        videoIds: (json['videoIds'] as List).map((id) => id as String).toList(),
        userGuessIsDeepfake: json['userGuessIsDeepfake'] as bool,
        pairId: json['pairId'] as String,
      );
    } catch (e) {
      if (e is StatisticsException) rethrow;
      throw StatisticsException('Failed to parse GameAttempt from JSON: $e');
    }
  }
}
