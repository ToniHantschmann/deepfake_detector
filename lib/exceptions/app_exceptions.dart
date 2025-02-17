class UserException implements Exception {
  final String message;
  UserException(this.message);

  @override
  String toString() => message;
}

class StatisticsException implements Exception {
  final String message;
  StatisticsException(this.message);

  @override
  String toString() => message;
}

class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => message;
}

class VideoException implements Exception {
  final String message;
  VideoException(this.message);

  @override
  String toString() => message;
}

class PinException implements Exception {
  final String message;
  PinException(this.message);

  @override
  String toString() => 'PinException: $message';
}

class PlayerNotFoundException implements Exception {
  @override
  String toString() => 'Player not found in internal statistics';
}

class RepositoryException implements Exception {
  final String message;
  RepositoryException(this.message);
  @override
  String toString() => 'RepositoryException: $message';
}
