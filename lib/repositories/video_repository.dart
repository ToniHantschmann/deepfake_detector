import 'package:deepfake_detector/exceptions/app_exceptions.dart';
import 'package:deepfake_detector/models/video_model.dart';
import 'package:deepfake_detector/storage/json_storage.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

/// repository class to manage the videos
class VideoRepository {
  late final JsonStorage _storage;
  late final List<Video> _videos;
  static final VideoRepository _instance = VideoRepository._internal();

  factory VideoRepository() => _instance;

  VideoRepository._internal() {
    //load videos to _videos
    _initStorage();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    _videos = await _getAllVideos();
  }

  Future<void> _initStorage() async {
    _storage = await JsonStorage.getInstance();
  }

  Future<List<Video>> _getAllVideos() async {
    try {
      final data = await _storage.readJsonFile(JsonStorage.videosFileName);
      final videosList = (data['videos'] as List?)
              ?.map((json) => Video.fromJson(json as Map<String, dynamic>))
              .toList() ??
          [];

      if (videosList.isEmpty) {
        throw VideoException('No videos in database');
      }

      return videosList;
    } catch (e) {
      if (e is VideoException) rethrow;
      throw VideoException('Error when loading videos: $e');
    }
  }

  /// get a random pair of real/deepfake video
  /// returns a [list] of two [video] objects
  /// throws exeption when loading the videos failed
  Future<List<Video>> getRandomVideoPair() async {
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
    try {
      return _videos.firstWhere((video) => video.id == id,
          orElse: () => throw VideoException('Video id $id not found'));
    } catch (e) {
      throw Exception("Video not found $e");
    }
  }
}
