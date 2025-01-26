import 'package:deepfake_detector/storage/storage.dart';
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
    'statistics': {
      '1234': {
        'pin': '1234',
        'totalAttempts': 10,
        'correctGuesses': 7,
        'recentAttempts': [
          {
            'timestamp': '2024-01-01T10:00:00.000Z',
            'wasCorrect': true,
            'videoIds': ['video1', 'video2'],
            'selectedVideoId': 'video1'
          }
        ],
        'isTemporary': false
      }
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
  });

  group('StatisticsRepository Tests - getStatistics', () {
    test('should return existing statistics for PIN', () async {
      await statisticsRepository.initialize();
      final stats = await statisticsRepository.getStatistics('1234');

      expect(stats.pin, '1234');
      expect(stats.totalAttempts, 10);
      expect(stats.correctGuesses, 7);
      expect(stats.recentAttempts.length, 1);
      expect(stats.isTemporary, false);
    });

    test('should return new statistics for new PIN', () async {
      await statisticsRepository.initialize();
      final stats = await statisticsRepository.getStatistics('9999');

      expect(stats.pin, '9999');
      expect(stats.totalAttempts, 0);
      expect(stats.correctGuesses, 0);
      expect(stats.recentAttempts, isEmpty);
      expect(stats.isTemporary, false);
    });
  });

  group('StatisticsRepository Tests - addAttempt', () {
    final newAttempt = GameAttempt(
        timestamp: DateTime.parse('2024-01-02T10:00:00.000Z'),
        wasCorrect: true,
        videoIds: ['video3', 'video4'],
        selectedVideoId: 'video3');

    test('should update existing statistics with PIN', () async {
      when(mockStorage.writeJsonFile(any, any)).thenAnswer((_) async => {});

      await statisticsRepository.initialize();
      final updatedStats =
          await statisticsRepository.addAttempt(newAttempt, pin: '1234');

      expect(updatedStats.totalAttempts, 11);
      expect(updatedStats.correctGuesses, 8);
      expect(updatedStats.recentAttempts.length, 2);
      expect(updatedStats.isTemporary, false);
    });

    test('should handle temporary statistics', () async {
      final tempStats = UserStatistics.temporary();
      final updatedStats =
          await statisticsRepository.addAttempt(newAttempt, stats: tempStats);

      expect(updatedStats.totalAttempts, 1);
      expect(updatedStats.correctGuesses, 1);
      expect(updatedStats.recentAttempts.length, 1);
      expect(updatedStats.isTemporary, true);
    });

    test('should convert temporary to permanent statistics', () async {
      when(mockStorage.writeJsonFile(any, any)).thenAnswer((_) async => {});

      final tempStats = UserStatistics.temporary();
      final tempWithAttempt =
          await statisticsRepository.addAttempt(newAttempt, stats: tempStats);

      final permanentStats = await statisticsRepository.convertTemporaryStats(
          tempWithAttempt, '9999');

      expect(permanentStats.pin, '9999');
      expect(permanentStats.totalAttempts, 1);
      expect(permanentStats.correctGuesses, 1);
      expect(permanentStats.recentAttempts.length, 1);
      expect(permanentStats.isTemporary, false);
    });

    test('should throw when converting non-temporary stats', () async {
      final permanentStats = UserStatistics.withPin('1234');

      expect(
        () =>
            statisticsRepository.convertTemporaryStats(permanentStats, '9999'),
        throwsA(isA<StatisticsException>()),
      );
    });
  });
}
