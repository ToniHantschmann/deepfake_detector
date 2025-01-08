import 'package:deepfake_detector/storage/json_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:deepfake_detector/repositories/statistics_repository.dart';
import 'package:deepfake_detector/exceptions/app_exceptions.dart';
import 'package:deepfake_detector/models/statistics_model.dart';

import 'statistics_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<JsonStorage>()])
void main() {
  late StatisticsRepository statisticsRepository;
  late MockJsonStorage mockStorage;

  final testStats = {
    'user1': {
      'username': 'user1',
      'totalAttempts': 10,
      'correctGuesses': 7,
      'recentAttempts': [
        {
          'timestamp': '2024-01-01T10:00:00.000Z',
          'wasCorrect': true,
          'videoIds': ['video1', 'video2'],
          'selectedVideoId': 'video1'
        }
      ]
    }
  };

  setUp(() {
    mockStorage = MockJsonStorage();
    when(mockStorage.readJsonFile(JsonStorage.statsFileName))
        .thenAnswer((_) async => testStats);

    statisticsRepository = StatisticsRepository.withStorage(mockStorage);
  });

  group('StatisticsRepository Tests - Initialization', () {
    test('should load statistics on initialization', () async {
      await statisticsRepository.initialize();
      verify(mockStorage.readJsonFile(JsonStorage.statsFileName)).called(1);
    });

    test('should initialize only once', () async {
      await statisticsRepository.initialize();
      await statisticsRepository.initialize();
      verify(mockStorage.readJsonFile(JsonStorage.statsFileName)).called(1);
    });

    test('should handle empty statistics', () async {
      when(mockStorage.readJsonFile(JsonStorage.statsFileName))
          .thenAnswer((_) async => {});

      await statisticsRepository.initialize();
      final stats = await statisticsRepository.getStatistics('newuser');
      expect(stats.totalAttempts, 0);
      expect(stats.correctGuesses, 0);
      expect(stats.recentAttempts, isEmpty);
    });
  });

  group('StatisticsRepository Tests - getStatistics', () {
    test('should initialize repository if not initialized', () async {
      await statisticsRepository.getStatistics('user1');
      verify(mockStorage.readJsonFile(JsonStorage.statsFileName)).called(1);
    });

    test('should return existing statistics', () async {
      await statisticsRepository.initialize();
      final stats = await statisticsRepository.getStatistics('user1');

      expect(stats.username, 'user1');
      expect(stats.totalAttempts, 10);
      expect(stats.correctGuesses, 7);
      expect(stats.recentAttempts.length, 1);
    });

    test('should return initial statistics for new user', () async {
      await statisticsRepository.initialize();
      final stats = await statisticsRepository.getStatistics('newuser');

      expect(stats.username, 'newuser');
      expect(stats.totalAttempts, 0);
      expect(stats.correctGuesses, 0);
      expect(stats.recentAttempts, isEmpty);
    });
  });

  group('StatisticsRepository Tests - addAttempt', () {
    final newAttempt = GameAttempt(
        timestamp: DateTime.parse('2024-01-02T10:00:00.000Z'),
        wasCorrect: true,
        videoIds: ['video3', 'video4'],
        selectedVideoId: 'video3');

    test('should initialize repository if not initialized', () async {
      when(mockStorage.writeJsonFile(any, any)).thenAnswer((_) async => {});

      await statisticsRepository.addAttempt('user1', newAttempt);
      verify(mockStorage.readJsonFile(JsonStorage.statsFileName)).called(1);
    });

    test('should update existing statistics', () async {
      when(mockStorage.writeJsonFile(any, any)).thenAnswer((_) async => {});

      await statisticsRepository.initialize();
      await statisticsRepository.addAttempt('user1', newAttempt);

      final stats = await statisticsRepository.getStatistics('user1');
      expect(stats.totalAttempts, 11);
      expect(stats.correctGuesses, 8);
      expect(stats.recentAttempts.length, 2);
    });

    test('should create new statistics for new user', () async {
      when(mockStorage.writeJsonFile(any, any)).thenAnswer((_) async => {});

      await statisticsRepository.initialize();
      await statisticsRepository.addAttempt('newuser', newAttempt);

      final stats = await statisticsRepository.getStatistics('newuser');
      expect(stats.totalAttempts, 1);
      expect(stats.correctGuesses, 1);
      expect(stats.recentAttempts.length, 1);
    });

    test('should limit recent attempts to 10', () async {
      when(mockStorage.writeJsonFile(any, any)).thenAnswer((_) async => {});

      await statisticsRepository.initialize();

      // Add 11 attempts
      for (var i = 0; i < 11; i++) {
        await statisticsRepository.addAttempt('user1', newAttempt);
      }

      final stats = await statisticsRepository.getStatistics('user1');
      expect(stats.recentAttempts.length, 10);
    });

    test('should handle storage error', () async {
      when(mockStorage.writeJsonFile(any, any))
          .thenThrow(StorageException('Test error'));

      await statisticsRepository.initialize();

      expect(
        () => statisticsRepository.addAttempt('user1', newAttempt),
        throwsA(isA<StatisticsException>()),
      );
    });

    test('should validate that selectedVideoId is in videoIds', () async {
      expect(
        () => GameAttempt(
            timestamp: DateTime.parse('2024-01-02T10:00:00.000Z'),
            wasCorrect: true,
            videoIds: ['video1', 'video2'],
            selectedVideoId: 'video3' // video3 is not in videoIds
            ),
        throwsA(isA<StatisticsException>()),
      );
    });
  });

  group('StatisticsRepository Tests - resetStatistics', () {
    test('should initialize repository if not initialized', () async {
      when(mockStorage.writeJsonFile(any, any)).thenAnswer((_) async => {});

      await statisticsRepository.resetStatistics('user1');
      verify(mockStorage.readJsonFile(JsonStorage.statsFileName)).called(1);
    });

    test('should reset existing statistics', () async {
      when(mockStorage.writeJsonFile(any, any)).thenAnswer((_) async => {});

      await statisticsRepository.initialize();
      await statisticsRepository.resetStatistics('user1');

      final stats = await statisticsRepository.getStatistics('user1');
      expect(stats.totalAttempts, 0);
      expect(stats.correctGuesses, 0);
      expect(stats.recentAttempts, isEmpty);
    });

    test('should handle storage error', () async {
      when(mockStorage.writeJsonFile(any, any))
          .thenThrow(StorageException('Test error'));

      await statisticsRepository.initialize();

      expect(
        () => statisticsRepository.resetStatistics('user1'),
        throwsA(isA<StatisticsException>()),
      );
    });
  });
}
