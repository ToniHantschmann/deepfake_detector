import 'package:deepfake_detector/exceptions/app_exceptions.dart';
import 'package:deepfake_detector/models/video_model.dart';
import 'package:deepfake_detector/storage/storage.dart';
import 'package:flutter/foundation.dart';

/// repository class to manage the videos
class VideoRepository {
  Storage? _storage;
  List<Video> _videos = [];
  bool _isInitialized = false;

  // Singleton instance
  static final VideoRepository _instance = VideoRepository._internal();
  static VideoRepository get instance => _instance;

  // Factory constructor
  factory VideoRepository() => _instance;

  // Test constructor
  @visibleForTesting
  VideoRepository.withStorage(Storage storage) {
    _storage = storage;
  }

  // Private constructor
  VideoRepository._internal();

  // Initialization method
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize storage if not injected
      _storage ??= await Storage.getInstance();
      await _loadVideos();
      _isInitialized = true;
    } catch (e) {
      throw VideoException('Failed to initialize repository: $e');
    }
  }

  Future<void> _loadVideos() async {
    if (_storage == null) {
      throw VideoException('Storage not initialized');
    }

    try {
      final data = await _storage!.getVideos();
      final videosList = (data['videos'] as List?)
              ?.map((json) => Video.fromJson(json as Map<String, dynamic>))
              .toList() ??
          [];

      if (videosList.isEmpty) {
        // Initialize with default videos if none exist
        _videos = _getDefaultVideos();
      } else {
        _videos = videosList;
      }
    } catch (e) {
      if (e is VideoException) rethrow;
      throw VideoException('Error when loading videos: $e');
    }
  }

  List<Video> _getDefaultVideos() {
    return [
      Video(
        id: 'v1',
        title: 'Presidential Speech 2024',
        description: 'A presidential address about climate change',
        videoUrl: 'assets/videos/speech1.mp4',
        thumbnailUrl: 'assets/thumbnails/speech1.jpg',
        isDeepfake: true,
        deepfakeIndicators: [
          'Unnatural lip movements during specific phrases',
          'Inconsistent facial expressions when speaking',
          'Audio-visual desynchronization at 1:24'
        ],
      ),
      Video(
        id: 'v2',
        title: 'Tech CEO Interview',
        description: 'Interview about AI development',
        videoUrl: 'assets/videos/tech1.mp4',
        thumbnailUrl: 'assets/thumbnails/tech1.jpg',
        isDeepfake: false,
        deepfakeIndicators: [],
      ),
    ];
  }

  /// Ensures the repository is initialized before performing operations
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// get a random pair of real/deepfake video
  /// returns a [list] of two [video] objects
  /// throws exeption when loading the videos failed
  Future<List<Video>> getRandomVideoPair() async {
    await _ensureInitialized();
    try {
      // sort _videos for only real/deepfakes and add them to list
      final realVideos = _videos.where((e) => !e.isDeepfake).toList();
      final fakeVideos = _videos.where((e) => e.isDeepfake).toList();

      // shuffle lists to get random video
      realVideos.shuffle();
      fakeVideos.shuffle();

      if (realVideos.isEmpty || fakeVideos.isEmpty) {
        throw VideoException(
            'Not enough videos available (real: ${realVideos.length}, fake: ${fakeVideos.length})');
      }

      return [realVideos.first, fakeVideos.first];
    } catch (e) {
      if (e is VideoException) rethrow;
      throw VideoException("Failed to load video pair: $e");
    }
  }

  /// get specific video by [id]
  /// throws exception when video was not found
  Future<Video> getVideoById(String id) async {
    await _ensureInitialized();
    try {
      return _videos.firstWhere((video) => video.id == id,
          orElse: () => throw VideoException('Video id $id not found'));
    } catch (e) {
      if (e is VideoException) rethrow;
      throw VideoException("Video not found $e");
    }
  }
}
