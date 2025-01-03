import 'package:deepfake_detector/exceptions/app_exceptions.dart';
import 'package:deepfake_detector/models/video_model.dart';
import 'package:deepfake_detector/storage/json_storage.dart';
import 'package:flutter/foundation.dart';

/// repository class to manage the videos
class VideoRepository {
  JsonStorage? _storage;
  List<Video> _videos = [];
  bool _isInitialized = false;

  // Singleton instance
  static final VideoRepository _instance = VideoRepository._internal();
  static VideoRepository get instance => _instance;

  // Factory constructor
  factory VideoRepository() => _instance;

  // Test constructor
  @visibleForTesting
  VideoRepository.withStorage(JsonStorage storage) {
    _storage = storage;
  }

  // Private constructor
  VideoRepository._internal();

  // Initialization method
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize storage if not injected
      _storage ??= await JsonStorage.getInstance();
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
      final data = await _storage!.readJsonFile(JsonStorage.videosFileName);
      final videosList = (data['videos'] as List?)
              ?.map((json) => Video.fromJson(json as Map<String, dynamic>))
              .toList() ??
          [];

      if (videosList.isEmpty) {
        throw VideoException('No videos in database');
      }

      _videos = videosList;
    } catch (e) {
      if (e is VideoException) rethrow;
      throw VideoException('Error when loading videos: $e');
    }
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
