/// model class to define data structure of a video
class Video {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final bool isDeepfake;
  final List<String> deepfakeIndicators;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.isDeepfake,
    required this.deepfakeIndicators,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      isDeepfake: json['isDeepfake'] as bool,
      deepfakeIndicators: List<String>.from(json['deepfakeIndicators']),
    );
  }
}
