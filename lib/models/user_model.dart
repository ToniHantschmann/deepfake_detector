class User {
  final String username;
  final String pin; // Neues Feld für PIN

  User({
    required this.username,
    required this.pin,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'pin': pin,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      pin: json['pin'] as String,
    );
  }

  // Kopieren mit optionaler Änderung einzelner Felder
  User copyWith({
    String? username,
    String? pin,
  }) {
    return User(
      username: username ?? this.username,
      pin: pin ?? this.pin,
    );
  }
}
