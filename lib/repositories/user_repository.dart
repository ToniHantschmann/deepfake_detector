import 'package:deepfake_detector/exceptions/app_exceptions.dart';
import 'package:deepfake_detector/storage/json_storage.dart';
import 'package:flutter/foundation.dart';

class UserRepository {
  static UserRepository? _instance;
  late final JsonStorage _storage;
  List<String> _users = [];
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

  /// Constructor for testing purposes that allows injecting a mock storage
  @visibleForTesting
  factory UserRepository.withStorage(JsonStorage storage) {
    resetInstance();
    final repository = UserRepository._internal();
    repository._storage = storage;
    repository._isStorageProvided = true;
    return repository;
  }

  /// Initialize the repository by loading users
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
    _users = await _getAllUsers();
  }

  Future<List<String>> _getAllUsers() async {
    try {
      final data = await _storage.readJsonFile(JsonStorage.usersFileName);
      final usersList = (data['users'] as List?)?.cast<String>() ?? [];
      return usersList;
    } catch (e) {
      throw UserException('Error when loading users: $e');
    }
  }

  /// Get all registered users
  /// Returns a [List] of usernames
  Future<List<String>> getUsers() async {
    if (!_isInitialized) await initialize();
    return List<String>.from(_users);
  }

  /// Add a new user with the given [username]
  /// Throws [UserException] if username is invalid or already exists
  Future<void> addUser(String username) async {
    if (!_isInitialized) await initialize();

    if (!_isValidUsername(username)) {
      throw UserException('Invalid username');
    }

    if (_users.contains(username)) {
      throw UserException('Username already exists');
    }

    try {
      _users.add(username);
      await _storage.writeJsonFile(JsonStorage.usersFileName, {
        'users': _users,
      });
    } catch (e) {
      _users.remove(username); // Rollback on error
      throw UserException('Failed to add user: $e');
    }
  }

  /// Check if a user exists
  /// Returns [bool] indicating if the user exists
  Future<bool> userExists(String username) async {
    if (!_isInitialized) await initialize();
    return _users.contains(username);
  }

  /// Remove a user by username
  /// Throws [UserException] if user doesn't exist
  Future<void> removeUser(String username) async {
    if (!_isInitialized) await initialize();

    if (!_users.contains(username)) {
      throw UserException('User not found');
    }

    try {
      _users.remove(username);
      await _storage.writeJsonFile(JsonStorage.usersFileName, {
        'users': _users,
      });
    } catch (e) {
      _users.add(username); // Rollback on error
      throw UserException('Failed to remove user: $e');
    }
  }

  bool _isValidUsername(String username) {
    return username.isNotEmpty &&
        username.length <= 50 &&
        RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
  }
}
