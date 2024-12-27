import 'package:deepfake_detector/exceptions/app_exceptions.dart';
import 'package:deepfake_detector/storage/json_storage.dart';

class UserRepository {
  late final JsonStorage _storage;
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;

  UserRepository._internal() {
    _initStorage;
  }

  Future<void> _initStorage() async {
    _storage = await JsonStorage.getInstance();
  }

  Future<List<String>> getUsers() async {
    final data = await _storage.readJsonFile(JsonStorage.usersFileName);
    return (data['users'] as List?)?.cast<String>() ?? [];
  }

  Future<void> addUser(String username) async {
    if (!_isValidUsername(username)) {
      throw UserException('Invalid username');
    }
    final data = await _storage.readJsonFile(JsonStorage.usersFileName);
    final users = (data['users'] as List?)?.cast<String>() ?? [];

    if (users.contains(username)) {
      throw UserException('Username already exists');
    }
    users.add(username);
    await _storage.writeJsonFile(JsonStorage.usersFileName, {'users': users});
  }

  bool _isValidUsername(String username) {
    return username.isNotEmpty &&
        username.length <= 50 &&
        RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
  }
}
