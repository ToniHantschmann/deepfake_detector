import 'package:deepfake_detector/exceptions/app_exceptions.dart';
import 'package:deepfake_detector/storage/json_storage.dart';
import 'package:deepfake_detector/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class UserRepository {
  static UserRepository? _instance;
  late final JsonStorage _storage;
  Map<String, User> _users = {}; // Geändert zu Map für schnelleren Zugriff
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
      final usersList =
          (data['users'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      _users = {
        for (var userData in usersList)
          userData['username'] as String: User.fromJson(userData)
      };
    } catch (e) {
      throw UserException('Error when loading users: $e');
    }
  }

  Future<List<String>> getUsers() async {
    if (!_isInitialized) await initialize();
    return _users.keys.toList();
  }

  Future<bool> userExists(String username) async {
    if (!_isInitialized) await initialize();
    return _users.containsKey(username);
  }

  Future<void> addUser(String username, {String? pin}) async {
    if (!_isInitialized) await initialize();

    if (!_isValidUsername(username)) {
      throw UserException('Invalid username');
    }

    if (_users.containsKey(username)) {
      throw UserException('Username already exists');
    }

    final userPin = pin ?? _generateRandomPin();
    if (!_isValidPin(userPin)) {
      throw UserException('Invalid PIN format');
    }

    try {
      final newUser = User(
        username: username,
        pin: userPin,
      );

      _users[username] = newUser;
      await _saveUsers();
    } catch (e) {
      _users.remove(username); // Rollback bei Fehler
      throw UserException('Failed to add user: $e');
    }
  }

  Future<List<User>> getUsersByPin(String pin) async {
    if (!_isInitialized) await initialize();

    return _users.values.where((user) => user.pin == pin).toList();
  }

  Future<bool> verifyPin(String username, String pin) async {
    if (!_isInitialized) await initialize();

    final user = _users[username];
    return user?.pin == pin;
  }

  Future<void> updatePin(String username, String newPin) async {
    if (!_isInitialized) await initialize();

    if (!_users.containsKey(username)) {
      throw UserException('User not found');
    }

    if (!_isValidPin(newPin)) {
      throw UserException('Invalid PIN format');
    }

    try {
      final user = _users[username]!;
      _users[username] = user.copyWith(pin: newPin);
      await _saveUsers();
    } catch (e) {
      throw UserException('Failed to update PIN: $e');
    }
  }

  Future<void> removeUser(String username) async {
    if (!_isInitialized) await initialize();

    if (!_users.containsKey(username)) {
      throw UserException('User not found');
    }

    try {
      _users.remove(username);
      await _saveUsers();
    } catch (e) {
      throw UserException('Failed to remove user: $e');
    }
  }

  Future<void> _saveUsers() async {
    try {
      final usersList = _users.values.map((user) => user.toJson()).toList();
      await _storage.writeJsonFile(JsonStorage.usersFileName, {
        'users': usersList,
      });
    } catch (e) {
      throw UserException('Failed to save users: $e');
    }
  }

  bool _isValidUsername(String username) {
    return username.isNotEmpty &&
        username.length <= 50 &&
        RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
  }

  bool _isValidPin(String pin) {
    return pin.length == 4 && RegExp(r'^\d{4}$').hasMatch(pin);
  }

  String _generateRandomPin() {
    // Generiere zufälligen 4-stelligen PIN
    final random = Random();
    final pin = List.generate(4, (_) => random.nextInt(10)).join();
    return pin;
  }
}
