// lib/config/localization/german_reason_strings.dart

import 'string_types.dart';

class GermanDeepfakeReasonStrings implements DeepfakeReasonStrings {
  const GermanDeepfakeReasonStrings();

  @override
  List<String> getReasonsForVideo(String videoId) {
    // Versuche exakte Übereinstimmung zu finden
    if (_videoReasons.containsKey(videoId)) {
      return _videoReasons[videoId]!;
    }

    // Fallback auf generische Gründe
    return genericReasons;
  }

  @override
  List<String> get genericReasons => const [
        'Unnatürliche Lippenbewegungen während des Sprechens',
        'Inkonsistente Gesichtsausdrücke und Mimik',
        'Fehlerhafte Beleuchtung und Schatten im Gesichtsbereich',
        'Unregelmäßiges oder fehlendes Blinzeln',
        'Verzerrte Übergänge bei Kopfbewegungen'
      ];

  static const Map<String, List<String>> _videoReasons = {
    // Politische Videos
    'v1': [
      'Unnatürliche Lippenbewegungen, besonders bei komplexen Lauten',
      'Inkonsistente Gesichtsausdrücke während emotionaler Aussagen',
      'Audio-visuelle Desynchronisation bei schnellen Sprechpassagen'
    ],
    'v2': [
      'Statische, unnatürliche Augenbrauen während des gesamten Gesprächs',
      'Fehlende oder unregelmäßige Blinzelmuster',
      'Verschwommene oder verzerrte Übergänge bei Kopfbewegungen'
    ],
  };
}
