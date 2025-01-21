class User {
  final String pin;
  final DateTime created;

  User({
    required this.pin,
    DateTime? created,
  }) : created = created ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'pin': pin,
        'created': created.toIso8601String(),
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      pin: json['pin'] as String,
      created: DateTime.parse(json['created'] as String),
    );
  }

  // Kopieren mit optionaler Änderung einzelner Felder
  User copyWith({
    String? pin,
    DateTime? created,
  }) {
    return User(
      pin: pin ?? this.pin,
      created: created ?? this.created,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          pin == other.pin &&
          created == other.created;

  @override
  int get hashCode => pin.hashCode ^ created.hashCode;

  @override
  String toString() => 'User(pin: $pin, created: $created)';
}
