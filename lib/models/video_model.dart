import 'package:deepfake_detector/models/deepfake_indicator_model.dart';

/// model class to define data structure of a video
class Video {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final bool isDeepfake;

  /// Contains indicators only if this is a deepfake video
  /// Will be empty for authentic videos
  final List<DeepfakeIndicator> deepfakeIndicators;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.isDeepfake,
    List<DeepfakeIndicator>? deepfakeIndicators,
  }) : deepfakeIndicators = isDeepfake
            ? (deepfakeIndicators ?? [])
            : []; // Always empty list for authentic videos

  factory Video.fromJson(Map<String, dynamic> json) {
    final isDeepfake = json['isDeepfake'] as bool;

    // For authentic videos, we don't process the indicators
    if (!isDeepfake) {
      return Video(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        videoUrl: json['videoUrl'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String,
        isDeepfake: false,
      );
    }

    // For deepfakes, parse the indicators
    List<DeepfakeIndicator> indicators = [];
    if (json.containsKey('deepfakeIndicators') &&
        json['deepfakeIndicators'] != null) {
      indicators = (json['deepfakeIndicators'] as List)
          .map((indicator) =>
              DeepfakeIndicator.fromJson(indicator as Map<String, dynamic>))
          .toList();
    }

    return Video(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      isDeepfake: true,
      deepfakeIndicators: indicators,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'isDeepfake': isDeepfake,
    };

    // Only include deepfakeIndicators for deepfake videos
    if (isDeepfake) {
      json['deepfakeIndicators'] =
          deepfakeIndicators.map((i) => i.toJson()).toList();
    }

    return json;
  }
}
