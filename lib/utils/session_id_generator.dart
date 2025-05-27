import 'dart:math';

class SessionIdGenerator {
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static const int _sessionIdLength = 6;

  /// Generiert eine eindeutige Session-ID für die Studie
  static String generateSessionId() {
    final random = Random();
    String sessionId = '';

    // Generiere 6 zufällige Zeichen
    for (int i = 0; i < _sessionIdLength; i++) {
      sessionId += _chars[random.nextInt(_chars.length)];
    }

    return sessionId;
  }

  /// Generiert SoSci Survey URL mit r= Parameter
  static String generateSoSciSurveyUrl(String sessionId) {
    const baseUrl = 'https://survey.ifkw.lmu.de/deepfakeDetectionGame/';
    return '${baseUrl}?r=$sessionId';
  }
}
