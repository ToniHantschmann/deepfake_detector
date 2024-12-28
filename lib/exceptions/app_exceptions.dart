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
