class UsernameValidator {
  static const int maxLength = 50;

  static String? validate(String username) {
    if (username.isEmpty) {
      return 'Please enter a username';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    if (username.length > maxLength) {
      return 'Username is too long (max $maxLength characters)';
    }

    return null;
  }
}
