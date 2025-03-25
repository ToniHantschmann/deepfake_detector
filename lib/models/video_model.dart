// lib/models/video_model.dart
class Video {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final bool isDeepfake;
  final String pairId;

  Video({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.isDeepfake,
    required this.pairId,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      isDeepfake: json['isDeepfake'] as bool,
      pairId: json['pairId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'isDeepfake': isDeepfake,
      'pairId': pairId,
    };
  }
}
