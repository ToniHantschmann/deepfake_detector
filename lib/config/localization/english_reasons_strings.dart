// lib/config/localization/english_reason_strings.dart

import 'string_types.dart';

class EnglishDeepfakeReasonStrings implements DeepfakeReasonStrings {
  const EnglishDeepfakeReasonStrings();

  @override
  List<String> getReasonsForVideo(String videoId) {
    // Try to find exact match
    if (_videoReasons.containsKey(videoId)) {
      return _videoReasons[videoId]!;
    }

    // Fallback to generic reasons
    return genericReasons;
  }

  @override
  List<String> get genericReasons => const [
        'Unnatural lip movements during speech',
        'Inconsistent facial expressions and mimicry',
        'Faulty lighting and shadows in the facial area',
        'Irregular or missing blinking',
        'Distorted transitions during head movements'
      ];

  static const Map<String, List<String>> _videoReasons = {
    // Videos with specific IDs
    'v1': [
      'Unnatural lip movements, especially during complex sounds',
      'Inconsistent facial expressions during emotional statements',
      'Audio-visual desynchronization during fast-speaking passages'
    ],
    'v2': [
      'Static, unnatural eyebrows throughout the conversation',
      'Missing or irregular blinking patterns',
      'Blurry or distorted transitions during head movements'
    ],
  };
}
