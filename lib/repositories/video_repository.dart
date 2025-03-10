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
      _videos = (data['videos'] as List?)
              ?.map((json) => Video.fromJson(json as Map<String, dynamic>))
              .toList() ??
          [];
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

  Future<List<Video>> getRandomVideoPair(Set<String> seenVideoIds) async {
    await _ensureInitialized();
    try {
      // Alle eindeutigen pairIds sammeln
      final Set<String> pairIds = _videos.map((v) => v.pairId).toSet();

      // Ungesehene Paare zuerst priorisieren
      final List<String> unseenPairIds = pairIds.where((pairId) {
        final pairVideos = _videos.where((v) => v.pairId == pairId).toList();
        return pairVideos.any((v) => !seenVideoIds.contains(v.id));
      }).toList();

      // Wenn keine ungesehenen Paare verfügbar sind, alle verwenden
      final targetPairIds =
          unseenPairIds.isNotEmpty ? unseenPairIds : pairIds.toList();
      targetPairIds.shuffle();
      final selectedPairId = targetPairIds.first;

      // Ein echtes und ein Deepfake-Video mit der gleichen pairId finden
      final pairVideos =
          _videos.where((v) => v.pairId == selectedPairId).toList();

      // Bei unserem Datenmodell sollte es genau ein echtes und ein Deepfake-Video pro pairId geben
      final realVideo = pairVideos.firstWhere(
        (v) => !v.isDeepfake,
        orElse: () => throw VideoException(
            'No real video found for pair: $selectedPairId'),
      );

      final fakeVideo = pairVideos.firstWhere(
        (v) => v.isDeepfake,
        orElse: () => throw VideoException(
            'No deepfake video found for pair: $selectedPairId'),
      );

      // Die Reihenfolge der Videos randomisieren
      final result = [realVideo, fakeVideo];
      result.shuffle();

      return result;
    } catch (e) {
      throw VideoException('Failed to load video pair: $e');
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
