import 'dart:math';
import '../exceptions/app_exceptions.dart';

/// Service zur Generierung und Validierung von PINs
class PinGeneratorService {
  static const int _minPin = 1000; // 4-stellige PIN
  static const int _maxPin = 9999;
  static const int _maxAttempts = 100;

  static int generateUniquePin(Set<int> existingPins) {
    if (existingPins.length >= _maxPin - _minPin + 1) {
      throw PinException('Keine weiteren PINs verfügbar');
    }

    int attempts = 0;
    while (attempts < _maxAttempts) {
      final pin = _generatePin();
      if (!existingPins.contains(pin)) {
        return pin;
      }
      attempts++;
    }

    // Fallback: Sequentiell nach freier PIN suchen
    for (int pin = _minPin; pin <= _maxPin; pin++) {
      if (!existingPins.contains(pin)) {
        return pin;
      }
    }

    throw PinException('Konnte keine eindeutige PIN generieren');
  }

  static int _generatePin() {
    return _minPin +
        (DateTime.now().millisecondsSinceEpoch % (_maxPin - _minPin + 1));
  }

  static bool isValidPin(int pin) {
    return pin >= _minPin && pin <= _maxPin;
  }
}
