import 'package:deepfake_detector/utils/session_id_generator.dart';

class InternalPlayerStatistics {
  final String id; // Unique ID für den Spieler (z.B. Pin oder UUID)
  final String sessionId;
  final int gamesPlayed; // Anzahl gespielter Spiele
  final int correctGuesses; // Anzahl richtiger Vermutungen
  final int loginCount; // Wie oft hat sich der Spieler eingeloggt
  final bool
      hasCompletedGame; // Hat mindestens ein Spiel komplett durchgespielt
  final bool hasPinRegistered; // Hat sich einen Pin registriert
  final bool hasReturnedWithPin; // Ist mit Pin zurückgekehrt
  final DateTime firstGameTimestamp; // Zeitstempel des ersten Spiels
  final DateTime? lastGameTimestamp; // Zeitstempel des letzten Spiels
  final int? initialConfidenceRating;

  InternalPlayerStatistics({
    required this.id,
    required this.sessionId,
    this.gamesPlayed = 0,
    this.correctGuesses = 0,
    this.loginCount = 0,
    this.hasCompletedGame = false,
    this.hasPinRegistered = false,
    this.hasReturnedWithPin = false,
    required this.firstGameTimestamp,
    this.lastGameTimestamp,
    this.initialConfidenceRating,
  });

  // Berechne Erfolgsrate
  double get successRate =>
      gamesPlayed > 0 ? (correctGuesses / gamesPlayed) * 100 : 0;

  // Factory für neue Spieler
  factory InternalPlayerStatistics.newPlayer(String id) {
    return InternalPlayerStatistics(
      id: id,
      sessionId: SessionIdGenerator.generateSessionId(),
      firstGameTimestamp: DateTime.now(),
    );
  }

  // Kopieren mit optionaler Änderung einzelner Felder
  InternalPlayerStatistics copyWith({
    String? id,
    String? sessionId,
    int? gamesPlayed,
    int? correctGuesses,
    int? loginCount,
    bool? hasCompletedGame,
    bool? hasPinRegistered,
    bool? hasReturnedWithPin,
    DateTime? lastGameTimestamp,
    int? initialConfidenceRating,
  }) {
    return InternalPlayerStatistics(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      correctGuesses: correctGuesses ?? this.correctGuesses,
      loginCount: loginCount ?? this.loginCount,
      hasCompletedGame: hasCompletedGame ?? this.hasCompletedGame,
      hasPinRegistered: hasPinRegistered ?? this.hasPinRegistered,
      hasReturnedWithPin: hasReturnedWithPin ?? this.hasReturnedWithPin,
      firstGameTimestamp: firstGameTimestamp,
      lastGameTimestamp: lastGameTimestamp ?? this.lastGameTimestamp,
      initialConfidenceRating:
          initialConfidenceRating ?? this.initialConfidenceRating,
    );
  }

  // Konvertierung in JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'gamesPlayed': gamesPlayed,
        'correctGuesses': correctGuesses,
        'loginCount': loginCount,
        'hasCompletedGame': hasCompletedGame,
        'hasPinRegistered': hasPinRegistered,
        'hasReturnedWithPin': hasReturnedWithPin,
        'firstGameTimestamp': firstGameTimestamp.toIso8601String(),
        'lastGameTimestamp': lastGameTimestamp?.toIso8601String(),
        'initialConfidenceRating': initialConfidenceRating,
      };

  // Erstellung aus JSON
  factory InternalPlayerStatistics.fromJson(Map<String, dynamic> json) {
    return InternalPlayerStatistics(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      gamesPlayed: json['gamesPlayed'] as int,
      correctGuesses: json['correctGuesses'] as int,
      loginCount: json['loginCount'] as int,
      hasCompletedGame: json['hasCompletedGame'] as bool,
      hasPinRegistered: json['hasPinRegistered'] as bool,
      hasReturnedWithPin: json['hasReturnedWithPin'] as bool,
      firstGameTimestamp: DateTime.parse(json['firstGameTimestamp'] as String),
      lastGameTimestamp: json['lastGameTimestamp'] != null
          ? DateTime.parse(json['lastGameTimestamp'] as String)
          : null,
      initialConfidenceRating: json['initialConfidenceRating'] as int?,
    );
  }
}

class InternalStatistics {
  final List<InternalPlayerStatistics> players;

  InternalStatistics({
    required this.players,
  });

  // Gesamtanzahl der gespielten Spiele
  int get totalGamesPlayed =>
      players.fold(0, (sum, player) => sum + player.gamesPlayed);

  // Durchschnittliche Erfolgsrate
  double get averageSuccessRate {
    if (players.isEmpty) return 0;
    final totalRate =
        players.fold(0.0, (sum, player) => sum + player.successRate);
    return totalRate / players.length;
  }

  // Anzahl der Abbrecher (nur Spieler die beim ersten Versuch abgebrochen haben)
  int get firstTimeQuitters => players
      .where((player) => !player.hasCompletedGame && player.gamesPlayed == 1)
      .length;

  // Anzahl der Spieler mit registriertem Pin
  int get playersWithPin =>
      players.where((player) => player.hasPinRegistered).length;

  // Anzahl der Spieler die mit Pin zurückgekehrt sind
  int get returnedPlayers =>
      players.where((player) => player.hasReturnedWithPin).length;

  // Konvertierung in JSON
  Map<String, dynamic> toJson() => {
        'players': players.map((player) => player.toJson()).toList(),
      };

  // Erstellung aus JSON
  factory InternalStatistics.fromJson(Map<String, dynamic> json) {
    final playersList = (json['players'] as List)
        .map((playerJson) => InternalPlayerStatistics.fromJson(
            playerJson as Map<String, dynamic>))
        .toList();

    return InternalStatistics(players: playersList);
  }

  // Spieler hinzufügen oder aktualisieren
  InternalStatistics updatePlayer(
    InternalPlayerStatistics updatedPlayer, {
    String? replacePlayerId,
  }) {
    final List<InternalPlayerStatistics> updatedPlayers = List.from(players);

    // Bestimme welche ID zum Suchen verwendet werden soll
    final searchId = replacePlayerId ?? updatedPlayer.id;
    final playerIndex = updatedPlayers.indexWhere((p) => p.id == searchId);

    if (playerIndex >= 0) {
      // Existierenden Spieler ersetzen
      updatedPlayers[playerIndex] = updatedPlayer;
    } else {
      // Neuen Spieler hinzufügen (falls nicht gefunden)
      updatedPlayers.add(updatedPlayer);
    }

    return InternalStatistics(players: updatedPlayers);
  }
}
