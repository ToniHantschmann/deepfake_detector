import 'package:deepfake_detector/models/video_model.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

/// repository class to manage the videos
class VideoRepository {
  final List<Video> _videos = [];
  static final VideoRepository _instance = VideoRepository._internal();

  factory VideoRepository() {
    return _instance;
  }
  VideoRepository._internal() {
    //load videos to _videos
    _initializeVideos();
  }

  /// loads videos from database in _videos, a [list] with [video] objects
  /// throws execption when loading from database failed
  Future<void> _initializeVideos() async {
    try {
      //load json string
      final String jsonString =
          await rootBundle.loadString('assets/data/videos_db.json');

      //convert json string in map
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      //create video list
      final List<dynamic> videosJson = jsonMap['videos'] as List<dynamic>;

      //convert list of json objects to video objects
      //and add them to the video list
      _videos.addAll(videosJson
          .map((json) => Video.fromJson(json as Map<String, dynamic>))
          .toList());
    } catch (e) {
      throw Exception("Failed to load video database: $e");
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

        return [realVideos.first, fakeVideos.first];
      } catch (e) {
        throw Exception("Failed to load video pair: $e");
      }
    }

    /// get specific video by [id]
    /// throws exception when video was not found
    Future<Video> getVideoById(String id) async {
      try {
        return _videos.firstWhere((video) => video.id == id);
      } catch (e) {
        throw Exception("Video not found $e");
      }
    }
  }
}
