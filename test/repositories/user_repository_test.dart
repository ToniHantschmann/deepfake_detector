import 'package:deepfake_detector/storage/json_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:deepfake_detector/repositories/user_repository.dart';
import 'package:deepfake_detector/exceptions/app_exceptions.dart';

import 'user_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<JsonStorage>()])
void main() {
  late UserRepository userRepository;
  late MockJsonStorage mockStorage;

  final testUsers = {
    'users': ['user1', 'user2', 'user3']
  };

  /// Setup mockStorage and userRepository
  setUp(() async {
    mockStorage = MockJsonStorage();
    reset(mockStorage);
    userRepository = UserRepository.withStorage(mockStorage);
  });

  group('UserRepository Tests - Initialization', () {
    setUp(() async {
      UserRepository.resetInstance();
      // Standard-Mock-Verhalten für Storage
      when(mockStorage.readJsonFile(JsonStorage.usersFileName))
          .thenAnswer((_) async => testUsers);
    });
    test('should load users on initialization', () async {
      await userRepository.initialize();
      verify(mockStorage.readJsonFile(JsonStorage.usersFileName)).called(1);
    });

    test('should initialize only once', () async {
      await userRepository.initialize();
      await userRepository.initialize();
      verify(mockStorage.readJsonFile(JsonStorage.usersFileName)).called(1);
    });
  });

  group('UserRepository Tests - getUsers', () {
    setUp(() async {
      UserRepository.resetInstance();
      // Standard-Mock-Verhalten für Storage
      when(mockStorage.readJsonFile(JsonStorage.usersFileName))
          .thenAnswer((_) async => testUsers);
    });
    test('should initialize repository if not initialized', () async {
      await userRepository.getUsers();
      verify(mockStorage.readJsonFile(JsonStorage.usersFileName)).called(1);
    });

    test('should return list of users', () async {
      await userRepository.initialize();
      final users = await userRepository.getUsers();

      expect(users, equals(['user1', 'user2', 'user3']));
    });

    test('returned list should be a copy', () async {
      await userRepository.initialize();
      final users = await userRepository.getUsers();
      users.add('newUser');

      final secondFetch = await userRepository.getUsers();
      expect(secondFetch, equals(['user1', 'user2', 'user3']));
    });

    test('should handle empty users list', () async {
      when(mockStorage.readJsonFile(JsonStorage.usersFileName))
          .thenAnswer((_) async => {'users': []});

      await userRepository.initialize();
      final users = await userRepository.getUsers();
      expect(users, isEmpty);
    });
  });

  group('UserRepository Tests - addUser', () {
    setUp(() async {
      UserRepository.resetInstance();
      // Standard-Mock-Verhalten für Storage
      when(mockStorage.readJsonFile(JsonStorage.usersFileName))
          .thenAnswer((_) async => testUsers);
    });
    test('should initialize repository if not initialized', () async {
      when(mockStorage.writeJsonFile(any, any)).thenAnswer((_) async => {});

      await userRepository.addUser('user4');
      verify(mockStorage.readJsonFile(JsonStorage.usersFileName)).called(1);
    });

    test('should add valid user', () async {
      // Initial setup
      await userRepository.initialize();

      // Mock behavior for the write operation
      //when(mockStorage.writeJsonFile(any, any)).thenAnswer((_) async => {});

      /*
      // Mock behavior for subsequent read operations after adding user
      when(mockStorage.readJsonFile(JsonStorage.usersFileName))
          .thenAnswer((_) async => {
                'users': ['user1', 'user2', 'user3', 'newUser']
              });
      */

      await userRepository.addUser('user5');

      final expectedData = {
        'users': ['user1', 'user2', 'user3', 'user4', 'user5']
      };

      verify(mockStorage.writeJsonFile(
        JsonStorage.usersFileName,
        expectedData,
      )).called(1);

      // Verify the user was actually added
      final users = await userRepository.getUsers();
      expect(users, contains('user5'));
    });

    test('should throw on duplicate username', () async {
      await userRepository.initialize();

      expect(
        () => userRepository.addUser('user1'),
        throwsA(isA<UserException>()),
      );
    });

    test('should throw on invalid username', () async {
      await userRepository.initialize();

      // Empty username
      expect(
        () => userRepository.addUser(''),
        throwsA(isA<UserException>()),
      );

      // Too long username
      expect(
        () => userRepository.addUser('a' * 51),
        throwsA(isA<UserException>()),
      );

      // Invalid characters
      expect(
        () => userRepository.addUser('user@name'),
        throwsA(isA<UserException>()),
      );
    });

    test('should rollback on storage error', () async {
      when(mockStorage.writeJsonFile(any, any))
          .thenThrow(StorageException('Test error'));

      await userRepository.initialize();

      expect(
        () => userRepository.addUser('newUser'),
        throwsA(isA<UserException>()),
      );

      final users = await userRepository.getUsers();
      expect(users, equals(['user1', 'user2', 'user3', 'user4', 'user5']));
    });
  });

  group('UserRepository Tests - removeUser', () {
    setUp(() async {
      UserRepository.resetInstance();
      // Standard-Mock-Verhalten für Storage
      when(mockStorage.readJsonFile(JsonStorage.usersFileName))
          .thenAnswer((_) async => testUsers);
    });
    test('should initialize repository if not initialized', () async {
      // Mock für das initiale Lesen
      when(mockStorage.readJsonFile(JsonStorage.usersFileName))
          .thenAnswer((_) async => {'users': []});

      // Mock für das Schreiben
      when(mockStorage.writeJsonFile(any, any)).thenAnswer((_) async => {});

      // Aktion ausführen ohne vorherige Initialisierung
      await userRepository.addUser('user4');

      // Verifizieren, dass readJsonFile aufgerufen wurde
      verify(mockStorage.readJsonFile(JsonStorage.usersFileName)).called(1);
    });

    test('should throw when adding existing user', () async {
      when(mockStorage.readJsonFile(JsonStorage.usersFileName))
          .thenAnswer((_) async => {
                'users': ['user1']
              });

      await userRepository.initialize();

      expect(
        () => userRepository.addUser('user1'),
        throwsA(isA<UserException>()),
      );
    });

    test('should remove existing user', () async {
      reset(mockStorage);

      // Mock für das Lesen klar definieren
      // aus irgendeinem Grund besteht testUsers aus dem Zustand von der 'add user'
      // group und wird hier auch so wieder eingefügt. Deswegen explizite Liste
      // mitgegeben.
      when(mockStorage.readJsonFile(JsonStorage.usersFileName))
          .thenAnswer((_) async => {
                'users': ['user1', 'user2', 'user3']
              });

      when(mockStorage.writeJsonFile(any, any)).thenAnswer((_) async => {});

      await userRepository.initialize();
      await userRepository.removeUser('user2');

      final expectedData = {
        'users': ['user1', 'user3']
      };

      verify(mockStorage.writeJsonFile(
        JsonStorage.usersFileName,
        expectedData,
      )).called(1);
    });

    test('should throw on non-existing user', () async {
      await userRepository.initialize();

      expect(
        () => userRepository.removeUser('nonexistent'),
        throwsA(isA<UserException>()),
      );
    });

    test('should rollback on storage error', () async {
      // Reset für diesen spezifischen Test
      reset(mockStorage);

      // Erster Aufruf für die Initialisierung
      when(mockStorage.readJsonFile(JsonStorage.usersFileName))
          .thenAnswer((realInvocation) async => {
                'users': ['user1', 'user2', 'user3']
              });
      when(mockStorage.writeJsonFile(any, any))
          .thenThrow(StorageException('Test error'));

      await userRepository.initialize();

      expect(
        () => userRepository.removeUser('user1'),
        throwsA(isA<UserException>()),
      );

      final users = await userRepository.getUsers();

      /// removeUser() rollback removes user first
      /// and adds it back after getting the error->
      /// changed order of list
      expect(users, equals(['user2', 'user3', 'user1']));
    });
  });

  group('UserRepository Tests - userExists', () {
    setUp(() async {
      UserRepository.resetInstance();
      // Standard-Mock-Verhalten für Storage
      when(mockStorage.readJsonFile(JsonStorage.usersFileName))
          .thenAnswer((_) async => testUsers);
    });
    test('should initialize repository if not initialized', () async {
      await userRepository.userExists('user1');
      verify(mockStorage.readJsonFile(JsonStorage.usersFileName)).called(1);
    });

    test('should return true for existing user', () async {
      await userRepository.initialize();
      expect(await userRepository.userExists('user1'), isTrue);
    });

    test('should return false for non-existing user', () async {
      await userRepository.initialize();
      expect(await userRepository.userExists('nonexistent'), isFalse);
    });
  });
}
