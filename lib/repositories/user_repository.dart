import 'package:deepfake_detector/exceptions/app_exceptions.dart';
import 'package:deepfake_detector/storage/json_storage.dart';
import 'package:deepfake_detector/models/user_model.dart';
import 'package:deepfake_detector/utils/pin_generator_service.dart';
import 'package:flutter/foundation.dart';

class UserRepository {
  static UserRepository? _instance;
  late final JsonStorage _storage;
  Map<String, User> _users = {};
  bool _isInitialized = false;
  bool _isStorageProvided = false;

  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }

  factory UserRepository() {
    return _instance ??= UserRepository._internal();
  }

  UserRepository._internal();

  @visibleForTesting
  factory UserRepository.withStorage(JsonStorage storage) {
    resetInstance();
    final repository = UserRepository._internal();
    repository._storage = storage;
    repository._isStorageProvided = true;
    return repository;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _initStorage();
    await _loadUsers();
    _isInitialized = true;
  }

  Future<void> _initStorage() async {
    if (!_isStorageProvided) {
      _storage = await JsonStorage.getInstance();
    }
  }

  Future<void> _loadUsers() async {
    try {
      final data = await _storage.readJsonFile(JsonStorage.usersFileName);
      _users.clear();

      final usersMap = data['users'] as Map<String, dynamic>? ?? {};
      for (final entry in usersMap.entries) {
        _users[entry.key] = User.fromJson(entry.value as Map<String, dynamic>);
      }
    } catch (e) {
      throw UserException('Error when loading users: $e');
    }
  }

  Future<bool> pinExists(String pin) async {
    if (!_isInitialized) await initialize();
    return _users.containsKey(pin);
  }

  Future<User?> getUserByPin(String pin) async {
    if (!_isInitialized) await initialize();
    return _users[pin];
  }

  /// Erstellt einen neuen Benutzer mit einem generierten PIN
  /// Returns den generierten PIN
  /// Throws [UserException] bei Fehlern
  Future<String> createNewUser() async {
    if (!_isInitialized) await initialize();

    try {
      final pin = PinGeneratorService.generateUniquePin(_users.keys.toSet());
      final user = User(pin: pin);

      _users[pin] = user;
      await _saveUsers();

      return pin;
    } catch (e) {
      throw UserException('Failed to create new user: $e');
    }
  }

  Future<void> removeUser(String pin) async {
    if (!_isInitialized) await initialize();

    if (!_users.containsKey(pin)) {
      throw UserException('User not found');
    }

    try {
      _users.remove(pin);
      await _saveUsers();
    } catch (e) {
      throw UserException('Failed to remove user: $e');
    }
  }

  Future<void> _saveUsers() async {
    try {
      final data = {
        'users': Map.fromEntries(
          _users.entries.map(
            (entry) => MapEntry(entry.key, entry.value.toJson()),
          ),
        ),
      };

      await _storage.writeJsonFile(JsonStorage.usersFileName, data);
    } catch (e) {
      throw UserException('Failed to save users: $e');
    }
  }

  bool isValidPin(String pin) => PinGeneratorService.isValidPin(pin);
}
