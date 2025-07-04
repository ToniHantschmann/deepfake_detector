// lib/repositories/internal_statistics_repository.dart (Erweiterte Version)
import 'dart:convert';
import '../exceptions/app_exceptions.dart';
import '../models/internal_statistics_model.dart';
import '../storage/internal_statistics_storage.dart';
import 'package:flutter/foundation.dart';

class InternalStatisticsRepository {
  static final InternalStatisticsRepository _instance =
      InternalStatisticsRepository._internal();
  factory InternalStatisticsRepository() => _instance;
  InternalStatisticsRepository._internal();

  final InternalStatisticsStorage _storage = InternalStatisticsStorage();
  bool _initialized = false;
  InternalStatistics? _cachedStatistics;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _storage.initialize();
      _initialized = true;
    }
  }

  // Laden der Statistiken, mit Caching
  Future<InternalStatistics> getStatistics() async {
    await _ensureInitialized();

    if (_cachedStatistics != null) {
      return _cachedStatistics!;
    }

    try {
      final jsonString = await _storage.getRawData();
      if (jsonString == null || jsonString.isEmpty) {
        _cachedStatistics = InternalStatistics(players: []);
        return _cachedStatistics!;
      }

      final parsedJson = json.decode(jsonString);
      _cachedStatistics = InternalStatistics.fromJson(parsedJson);
      return _cachedStatistics!;
    } catch (e) {
      throw RepositoryException('Failed to load statistics: $e');
    }
  }

  // Speichern der Statistiken
  Future<void> saveStatistics(InternalStatistics statistics) async {
    await _ensureInitialized();
    try {
      _cachedStatistics = statistics;
      final jsonString = json.encode(statistics.toJson());
      await _storage.saveRawData(jsonString);
    } catch (e) {
      throw RepositoryException('Failed to save statistics: $e');
    }
  }

  // Spieler finden oder erstellen
  Future<InternalPlayerStatistics> getOrCreatePlayer(String playerId) async {
    final stats = await getStatistics();
    final playerIndex = stats.players.indexWhere((p) => p.id == playerId);

    if (playerIndex >= 0) {
      return stats.players[playerIndex];
    } else {
      _cachedStatistics = null;
      return InternalPlayerStatistics.newPlayer(playerId);
    }
  }

  // Aufzeichnen eines Spielstarts
  Future<void> recordGameStart(String playerId) async {
    try {
      final stats = await getStatistics();
      final player = await getOrCreatePlayer(playerId);

      final updatedPlayer = player.copyWith(
        gamesPlayed: player.gamesPlayed + 1,
        lastGameTimestamp: DateTime.now(),
      );

      // Aktualisiere die Statistiken
      final updatedStats = stats.updatePlayer(updatedPlayer);
      await saveStatistics(updatedStats);
    } catch (e) {
      debugPrint('Error recording game start: $e');
    }
  }

  // Aufzeichnen eines PIN-Logins
  Future<void> recordPinLogin(String pin) async {
    try {
      final stats = await getStatistics();
      final player = await getOrCreatePlayer(pin);

      final updatedPlayer = player.copyWith(
        loginCount: player.loginCount + 1,
        hasReturnedWithPin: player.loginCount > 0,
      );

      final updatedStats = stats.updatePlayer(updatedPlayer);
      await saveStatistics(updatedStats);
    } catch (e) {
      debugPrint('Error recording PIN login: $e');
    }
  }

  // Aufzeichnen einer PIN-Registrierung
  Future<void> recordPinRegistration(
    String tempPlayerId,
    String newPin,
  ) async {
    try {
      final stats = await getStatistics();
      final tempPlayer = await getOrCreatePlayer(tempPlayerId);

      // Aktualisiere temporären Spieler
      final permanentPlayer = tempPlayer.copyWith(
        id: newPin,
        hasPinRegistered: true,
      );

      final updatedStats = stats.updatePlayer(
        permanentPlayer,
        replacePlayerId: tempPlayerId,
      );
      await saveStatistics(updatedStats);
    } catch (e) {
      debugPrint('Error recording PIN registration: $e');
    }
  }

  // Aufzeichnen eines Spielversuchs
  Future<void> recordGameAttempt({
    required String playerId,
    required bool wasCorrect,
    required bool hasPinRegistered,
  }) async {
    try {
      final stats = await getStatistics();
      final player = await getOrCreatePlayer(playerId);

      final updatedPlayer = player.copyWith(
        correctGuesses: player.correctGuesses + (wasCorrect ? 1 : 0),
        hasPinRegistered: hasPinRegistered,
      );

      final updatedStats = stats.updatePlayer(updatedPlayer);
      await saveStatistics(updatedStats);
    } catch (e) {
      debugPrint('Error recording game attempt: $e');
    }
  }

  // Aufzeichnen eines vollständigen Spiels
  Future<void> recordGameCompletion({
    required String playerId,
    required bool completedFullGame,
    required bool hasPinRegistered,
  }) async {
    try {
      final stats = await getStatistics();
      final player = await getOrCreatePlayer(playerId);

      final updatedPlayer = player.copyWith(
        hasCompletedGame: completedFullGame || player.hasCompletedGame,
        hasPinRegistered: hasPinRegistered,
      );

      final updatedStats = stats.updatePlayer(updatedPlayer);
      await saveStatistics(updatedStats);
    } catch (e) {
      debugPrint('Error recording game completion: $e');
    }
  }

  // Aufzeichnen der anfänglichen Selbsteinschätzung
  Future<void> recordConfidenceRating({
    required String playerId,
    required int rating,
  }) async {
    try {
      final stats = await getStatistics();
      final player = await getOrCreatePlayer(playerId);

      // Aktualisiere nur, wenn noch keine Bewertung vorhanden
      if (player.initialConfidenceRating == null) {
        final updatedPlayer = player.copyWith(
          initialConfidenceRating: rating,
        );

        final updatedStats = stats.updatePlayer(updatedPlayer);
        await saveStatistics(updatedStats);
      }
    } catch (e) {
      debugPrint('Error recording confidence rating: $e');
    }
  }

  Future<String?> getSessionIdForPlayer(String playerId) async {
    try {
      final stats = await getStatistics();
      final player = stats.players.firstWhere(
        (p) => p.id == playerId,
        orElse: () => throw Exception('Player not found'),
      );
      return player.sessionId;
    } catch (e) {
      debugPrint('Error getting session ID: $e');
      return null;
    }
  }

  // Desktop-Befehle für interne Statistiken (Erweiterung für Windows)
  void registerDesktopCommands() {
    // In der Desktop-Version können wir mehr Funktionalität bieten
    if (!kIsWeb && !kDebugMode) {
      debugPrint('Desktop-spezifische Befehle für Statistiken aktiviert');
    }
  }

  // Statistik-Zusammenfassung als String
  Future<String> getStatisticsSummary() async {
    try {
      final stats = await getStatistics();
      final buffer = StringBuffer();

      buffer.writeln('===== Deepfake Detector Statistiken =====');
      buffer.writeln('Gesamtanzahl an Spielern: ${stats.players.length}');
      buffer.writeln('Gespielte Spiele insgesamt: ${stats.totalGamesPlayed}');
      buffer.writeln(
          'Durchschnittliche Erfolgsrate: ${stats.averageSuccessRate.toStringAsFixed(2)}%');
      buffer.writeln('Spieler mit PIN: ${stats.playersWithPin}');
      buffer.writeln('Zurückgekehrte Spieler: ${stats.returnedPlayers}');
      buffer
          .writeln('Abbrecher beim ersten Versuch: ${stats.firstTimeQuitters}');

      return buffer.toString();
    } catch (e) {
      return 'Fehler beim Abrufen der Statistik: $e';
    }
  }

  // Löschen aller Statistiken (für Test- und Entwicklungszwecke)
  Future<void> clearAllStatistics() async {
    await _ensureInitialized();
    _cachedStatistics = InternalStatistics(players: []);
    await saveStatistics(_cachedStatistics!);
  }
}
