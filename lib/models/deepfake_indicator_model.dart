/// Model class for deepfake indicators with associated screenshot evidence
class DeepfakeIndicator {
  final String description;
  final List<String> screenshotUrls;
  final List<String>? screenshotCaptions;

  DeepfakeIndicator({
    required this.description,
    required this.screenshotUrls,
    this.screenshotCaptions,
  });

  factory DeepfakeIndicator.fromJson(Map<String, dynamic> json) {
    return DeepfakeIndicator(
      description: json['description'] as String,
      screenshotUrls: List<String>.from(json['screenshotUrls'] ?? []),
      screenshotCaptions: json['screenshotCaptions'] != null
          ? List<String>.from(json['screenshotCaptions'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'screenshotUrls': screenshotUrls,
        'screenshotCaptions': screenshotCaptions,
      };
}
