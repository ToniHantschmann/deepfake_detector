import 'package:deepfake_detector/storage/json_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:deepfake_detector/repositories/video_repository.dart';
import 'package:deepfake_detector/exceptions/app_exceptions.dart';

import 'video_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<JsonStorage>()])
void main() {
  late VideoRepository videoRepository;
  late MockJsonStorage mockStorage;

  final testVideos = {
    'videos': [
      {
        'id': '1',
        'title': 'Real Video',
        'description': 'A real video',
        'videoUrl': 'real.mp4',
        'thumbnailUrl': 'real.jpg',
        'isDeepfake': false,
        'deepfakeIndicators': []
      },
      {
        'id': '2',
        'title': 'real Video',
        'description': 'A real video',
        'videoUrl': 'fake.mp4',
        'thumbnailUrl': 'fake.jpg',
        'isDeepfake': true,
        'deepfakeIndicators': ['Unnatural lip movements']
      },
      {
        'id': '3',
        'title': 'Fake Video',
        'description': 'A deepfake video',
        'videoUrl': 'fake.mp4',
        'thumbnailUrl': 'fake.jpg',
        'isDeepfake': false,
        'deepfakeIndicators': ['Unnatural lip movements']
      },
      {
        'id': '4',
        'title': 'real Video',
        'description': 'A real video',
        'videoUrl': 'fake.mp4',
        'thumbnailUrl': 'fake.jpg',
        'isDeepfake': true,
        'deepfakeIndicators': ['Unnatural lip movements']
      }
    ]
  };

  /// setup mockStorage and videoRepository
  setUp(() async {
    mockStorage = MockJsonStorage();
    // Standard-Mock-Verhalten für Storage
    when(mockStorage.readJsonFile(JsonStorage.videosFileName))
        .thenAnswer((_) async => testVideos);

    videoRepository = VideoRepository.withStorage(mockStorage);
  });

  group('VideoRepository Tests - Initialization', () {
    test('should load videos on initialization', () async {
      await videoRepository.initialize();
      verify(mockStorage.readJsonFile(JsonStorage.videosFileName)).called(1);
    });

    test('should throw VideoException when no videos are available', () async {
      when(mockStorage.readJsonFile(JsonStorage.videosFileName))
          .thenAnswer((_) async => {'videos': []});

      expect(
        () => videoRepository.initialize(),
        throwsA(isA<VideoException>()),
      );
    });

    test('should initialize only once', () async {
      await videoRepository.initialize();
      await videoRepository.initialize();
      verify(mockStorage.readJsonFile(JsonStorage.videosFileName)).called(1);
    });
  });

  group('VideoRepository Tests - getRandomVideoPair', () {
    test('should initialize repository if not initialized', () async {
      await videoRepository.getRandomVideoPair();
      verify(mockStorage.readJsonFile(JsonStorage.videosFileName)).called(1);
    });

    test('should return one real and one fake video', () async {
      await videoRepository.initialize();
      final videoPair = await videoRepository.getRandomVideoPair();

      expect(videoPair.length, 2);
      expect(videoPair.where((v) => v.isDeepfake).length, 1);
      expect(videoPair.where((v) => !v.isDeepfake).length, 1);
    });

    /*
    test('should return different pairs on multiple calls', () async {
      await videoRepository.initialize();
      final firstPair = await videoRepository.getRandomVideoPair();
      final secondPair = await videoRepository.getRandomVideoPair();

      // Da wir nur 3 Test-Videos haben und immer ein echtes und ein gefälschtes
      // zurückgegeben werden müssen, können wir auf Unterschiede prüfen
      expect(
        firstPair
            .map((v) => v.id)
            .toSet()
            .intersection(
              secondPair.map((v) => v.id).toSet(),
            )
            .length,
        lessThan(2),
      );
    });
    */

    test('should throw when no fake videos are available', () async {
      when(mockStorage.readJsonFile(JsonStorage.videosFileName))
          .thenAnswer((_) async => {
                'videos': testVideos['videos']!
                    .where((v) => !(v['isDeepfake'] as bool))
                    .toList()
              });

      expect(
        () => videoRepository.getRandomVideoPair(),
        throwsA(isA<VideoException>()),
      );
    });

    test('should throw when no real videos are available', () async {
      when(mockStorage.readJsonFile(JsonStorage.videosFileName)).thenAnswer(
          (_) async => {
                'videos': testVideos['videos']!
                    .where((v) => v['isDeepfake'] as bool)
                    .toList()
              });

      expect(
        () => videoRepository.getRandomVideoPair(),
        throwsA(isA<VideoException>()),
      );
    });
  });

  group('VideoRepository Tests - getVideoById', () {
    test('should initialize repository if not initialized', () async {
      await videoRepository.getVideoById('1');
      verify(mockStorage.readJsonFile(JsonStorage.videosFileName)).called(1);
    });

    test('should return correct video for existing id', () async {
      await videoRepository.initialize();
      final video = await videoRepository.getVideoById('1');

      expect(video.id, '1');
      expect(video.isDeepfake, false);
      expect(video.title, 'Real Video');
    });

    test('should throw exception for non-existing id', () async {
      await videoRepository.initialize();
      expect(
        () => videoRepository.getVideoById('non_existing_id'),
        throwsA(isA<VideoException>()),
      );
    });
  });
}
