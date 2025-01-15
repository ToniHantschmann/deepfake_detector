class PinValidator {
  static bool isValidPin(String pin) {
    return pin.length == 4 && RegExp(r'^\d{4}$').hasMatch(pin);
  }

  static bool doPinsMatch(String pin1, String pin2) {
    return pin1 == pin2;
  }
}
