import 'package:deepfake_detector/exceptions/app_exceptions.dart';
import 'package:deepfake_detector/storage/storage.dart';
import 'package:deepfake_detector/utils/pin_generator_service.dart';
import 'package:flutter/foundation.dart';

class UserRepository {
  static UserRepository? _instance;
  Storage? _storage;
  Set<int> _users = {};
  bool _isInitialized = false;

  // Factory constructor for singleton instance
  factory UserRepository() {
    return _instance ??= UserRepository._internal();
  }

  UserRepository._internal();

  // Test constructor with dependency injection
  @visibleForTesting
  factory UserRepository.withStorage(Storage storage) {
    final repository = UserRepository._internal();
    repository._storage = storage;
    return repository;
  }

  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _initStorage();
    await _loadUsers();
    _isInitialized = true;
  }

  Future<void> _initStorage() async {
    _storage ??= await Storage.getInstance();
  }

  Future<void> _loadUsers() async {
    try {
      final List<int> data = await _storage!.getUsers();
      debugPrint('runTimeType of user data: ${data.runtimeType.toString()}');
      _users = data.toSet();
    } catch (e) {
      throw UserException('Error when loading users: $e');
    }
  }

  Future<void> _saveUsers() async {
    try {
      await _storage!.saveUsers(_users.toList());
    } catch (e) {
      throw UserException('Failed to save users: $e');
    }
  }

  Future<bool> pinExists(int pin) async {
    if (!_isInitialized) await initialize();
    return _users.contains(pin);
  }

  Future<int?> getUserByPin(int pin) async {
    if (!_isInitialized) await initialize();
    return _users.contains(pin) ? pin : null;
  }

  Future<int> createNewUser() async {
    if (!_isInitialized) await initialize();

    try {
      final pin = PinGeneratorService.generateUniquePin(_users);
      _users.add(pin);
      await _saveUsers();
      return pin;
    } catch (e) {
      throw UserException('Failed to create new user: $e');
    }
  }

  bool isValidPin(int pin) => pin >= 1000 && pin <= 9999; // 4-stellige PIN

  Future<void> removeUser(String pin) async {
    if (!_isInitialized) await initialize();

    if (!_users.contains(pin)) {
      throw UserException('User not found');
    }

    try {
      _users.remove(pin);
      await _saveUsers();
    } catch (e) {
      throw UserException('Failed to remove user: $e');
    }
  }
}
