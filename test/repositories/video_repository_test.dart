import 'package:deepfake_detector/storage/json_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:deepfake_detector/repositories/video_repository.dart';
import 'package:deepfake_detector/models/video_model.dart';
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
}
