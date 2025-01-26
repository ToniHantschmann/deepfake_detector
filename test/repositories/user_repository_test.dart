import 'package:deepfake_detector/storage/storage.dart';
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
    'users': {
      '1234': {'pin': '1234', 'created': '2024-01-01T10:00:00.000Z'},
      '5678': {'pin': '5678', 'created': '2024-01-02T10:00:00.000Z'}
    }
  };

  setUp(() {
    mockStorage = MockJsonStorage();
    when(mockStorage.readJsonFile(JsonStorage.usersFileName))
        .thenAnswer((_) async => testUsers);
    userRepository = UserRepository.withStorage(mockStorage);
  });

  group('UserRepository Tests - Initialization', () {
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

  group('UserRepository Tests - getUserByPin', () {
    test('should initialize repository if not initialized', () async {
      await userRepository.getUserByPin('1234');
      verify(mockStorage.readJsonFile(JsonStorage.usersFileName)).called(1);
    });

    test('should return user for existing PIN', () async {
      await userRepository.initialize();
      final user = await userRepository.getUserByPin('1234');

      expect(user, isNotNull);
      expect(user?.pin, '1234');
      expect(user?.created, DateTime.parse('2024-01-01T10:00:00.000Z'));
    });

    test('should return null for non-existing PIN', () async {
      await userRepository.initialize();
      final user = await userRepository.getUserByPin('9999');
      expect(user, isNull);
    });
  });

  group('UserRepository Tests - createNewUser', () {
    test('should initialize repository if not initialized', () async {
      when(mockStorage.writeJsonFile(any, any)).thenAnswer((_) async => {});

      await userRepository.createNewUser();
      verify(mockStorage.readJsonFile(JsonStorage.usersFileName)).called(1);
    });

    test('should create user with valid PIN', () async {
      when(mockStorage.writeJsonFile(any, any)).thenAnswer((_) async => {});

      final pin = await userRepository.createNewUser();

      expect(pin.length, 4);
      expect(int.tryParse(pin), isNotNull);

      verify(mockStorage.writeJsonFile(
        JsonStorage.usersFileName,
        any,
      )).called(1);
    });

    test('should not create duplicate PINs', () async {
      when(mockStorage.writeJsonFile(any, any)).thenAnswer((_) async => {});

      // Mock PinGeneratorService um zuerst einen existierenden PIN zu generieren
      // und dann einen neuen
      final pin = await userRepository.createNewUser();
      expect(pin, isNot(equals('1234')));
      expect(pin, isNot(equals('5678')));
    });

    test('should throw on storage error', () async {
      when(mockStorage.writeJsonFile(any, any))
          .thenThrow(StorageException('Test error'));

      expect(
        () => userRepository.createNewUser(),
        throwsA(isA<UserException>()),
      );
    });
  });

  group('UserRepository Tests - removeUser', () {
    test('should remove existing user', () async {
      when(mockStorage.writeJsonFile(any, any)).thenAnswer((_) async => {});

      await userRepository.initialize();
      await userRepository.removeUser('1234');

      final expectedData = {
        'users': {
          '5678': {'pin': '5678', 'created': '2024-01-02T10:00:00.000Z'}
        }
      };

      verify(mockStorage.writeJsonFile(
        JsonStorage.usersFileName,
        expectedData,
      )).called(1);
    });

    test('should throw on non-existing user', () async {
      await userRepository.initialize();
      expect(
        () => userRepository.removeUser('9999'),
        throwsA(isA<UserException>()),
      );
    });
  });

  group('UserRepository Tests - pinExists', () {
    test('should return true for existing PIN', () async {
      await userRepository.initialize();
      expect(await userRepository.pinExists('1234'), isTrue);
    });

    test('should return false for non-existing PIN', () async {
      await userRepository.initialize();
      expect(await userRepository.pinExists('9999'), isFalse);
    });
  });
}
