class User {
  final String pin;

  User({
    required this.pin,
    DateTime? created,
  });

  Map<String, dynamic> toJson() => {
        'pin': pin,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      pin: json['pin'] as String,
    );
  }

  // Kopieren mit optionaler Änderung einzelner Felder
  User copyWith({
    String? pin,
    DateTime? created,
  }) {
    return User(
      pin: pin ?? this.pin,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && pin == other.pin;
}
