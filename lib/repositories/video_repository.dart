import 'dart:ffi';
import 'dart:ui_web';

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
    //
    _initializeVideos();
  }

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

    //TODO:
    //add more functions:
    //getRandomVideoPair()
    //getVideoById()
  }
}
