import 'dart:math';

/// Service zur Verwaltung temporärer Benutzer
class TempUserService {
  // Private Konstruktor verhindert Instanziierung
  TempUserService._();

  // Konstanten für die Benutzernamen-Generierung
  static const String _prefix = 'player_';
  static const int _randomLength = 6;
  static const String _allowedChars = 'abcdefghijklmnopqrstuvwxyz0123456789';

  // Cache für bereits generierte Namen
  static final Set<String> _usedNames = {};

  /// Generiert einen einzigartigen temporären Benutzernamen
  /// Format: player_XXXXXX (X = zufälliges Zeichen)
  /// Returns: Eindeutiger Benutzername
  static String generateTempUsername() {
    String newUsername;
    final random = Random();

    // Generiere Namen bis ein einzigartiger gefunden wurde
    do {
      final randomPart = List.generate(_randomLength, (_) {
        return _allowedChars[random.nextInt(_allowedChars.length)];
      }).join();

      newUsername = '$_prefix$randomPart';
    } while (_usedNames.contains(newUsername));

    _usedNames.add(newUsername);
    return newUsername;
  }

  /// Überprüft, ob ein Benutzername temporär ist
  /// [username]: Der zu überprüfende Benutzername
  /// Returns: true wenn der Name temporär ist
  static bool isTemporaryUsername(String username) {
    return username.startsWith(_prefix);
  }
}
