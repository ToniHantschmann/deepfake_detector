import 'dart:math';

class TempUserService {
  TempUserService._();

  static const String _prefix = 'player_';
  static const int _randomLength = 6;
  static const String _allowedChars = 'abcdefghijklmnopqrstuvwxyz0123456789';

  static final Set<String> _usedNames = {};

  static String generateTempUsername() {
    String newUsername;
    final random = Random();
    do {
      final randomPart = List.generate(_randomLength, (_) {
        return _allowedChars[random.nextInt(_allowedChars.length)];
      }).join();

      newUsername = '$_prefix$randomPart';
    } while (_usedNames.contains(newUsername));

    _usedNames.add(newUsername);
    return newUsername;
  }

  static bool isTemporaryUsername(String username) {
    return username.startsWith(_prefix);
  }
}
