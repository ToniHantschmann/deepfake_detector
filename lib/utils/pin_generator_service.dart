import 'dart:math';
import '../exceptions/app_exceptions.dart';

/// Service zur Generierung und Validierung von PINs
class PinGeneratorService {
  // Private Konstruktor verhindert Instanziierung
  PinGeneratorService._();

  // Konstanten für die PIN-Generierung
  static const int _pinLength = 4;
  static const int _maxGenerationAttempts = 100;
  static const String _allowedChars = '0123456789';

  /// Generiert einen zufälligen PIN
  /// Returns: 4-stelliger PIN
  static String generatePin() {
    final random = Random();
    return List.generate(_pinLength, (_) {
      return _allowedChars[random.nextInt(_allowedChars.length)];
    }).join();
  }

  /// Generiert einen einzigartigen PIN
  /// [existingPins]: Set von bereits vergebenen PINs
  /// Returns: Eindeutiger PIN
  /// Throws [PinException] wenn kein freier PIN gefunden werden kann
  static String generateUniquePin(Set<String> existingPins) {
    int attempts = 0;
    String pin;

    do {
      if (attempts >= _maxGenerationAttempts) {
        throw PinException(
            'Failed to generate unique PIN after $attempts attempts');
      }

      pin = generatePin();
      attempts++;
    } while (existingPins.contains(pin));

    return pin;
  }

  /// Überprüft, ob ein PIN valide ist
  /// [pin]: Der zu prüfende PIN
  /// Returns: true wenn der PIN valide ist
  static bool isValidPin(String pin) {
    return pin.length == _pinLength && RegExp(r'^\d{4}$').hasMatch(pin);
  }
}
