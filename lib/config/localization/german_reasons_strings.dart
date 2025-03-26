// lib/config/localization/german_reason_strings.dart

import 'string_types.dart';

class GermanDeepfakeReasonStrings implements DeepfakeReasonStrings {
  const GermanDeepfakeReasonStrings();

  @override
  List<String> getReasonsForVideo(String pairId) {
    if (_videoReasons.containsKey(pairId)) {
      return _videoReasons[pairId]!;
    }

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
    'id01': [
      'Gesichtsbehaarung fehlt Details',
      'Lichtreflexionen auf der Haut',
      'Mundbewegung wirkt künstlich'
    ],
    'id02': [
      'Wangen wirken zu glatt',
      'Augenpartie passt nicht zum Rest',
      'Zähne wirken zu glatt'
    ],
    'id03': [
      'Augenpartie wirkt unnatürlich',
      'Gesichtsbehaarung verwaschen',
      'Details und Beleuchtung der Nase wirkt unnatürlich'
    ],
    'id04': [
      'Mimik wirkt ausdruckslos',
      'Augen und Mundpartie wirken unnatürlich',
      'Übergang von der Nase zu den Augenbrauen',
      'Lichtreflexionen auf der Haut sind unscharf'
    ],
    'id05': [
      'Mimik wirkt emotionslos',
      'Gesichtsbehaarung fehlt Details',
      'Blinzeln unnatürlich'
    ],
    'id06': [
      'Leberfleck nicht konstant gleich',
      'Oberlippenbart und Übergang zum unteren Bart passen nicht zusammen',
      'Hautfarbe der Wangen und Augenpartien passen nicht zur Stirn',
      'untere Zähne nicht sichtbar'
    ],
    'id07': [
      'Wenn der Kopf zur Seite zeigt: Übergang zum Hintergrund verschwimmt',
      'Wangen und Stirn wirken zu glatt',
      'Augenpartie passt farblich nicht zum Rest',
      'Augenringe wirken unnatürlich'
    ],
    'id08': ['Farbe der Wangenpartie ändert sich'],
    'id09': ['Zähne ohne Details', 'Augenpartie wirkt unnatürlich'],
    'id10': [
      'Augenpartie wirkt unecht, vor allem bei dem Blick zur Seite',
      'ganzes Gesicht wirkt zu glatt',
      'teilweise unterschiedliche Wangenfarbe',
      'Stirn deutlich dunkler als Augen- und Wangenpartie'
    ],
    'id11': [
      'Video wirkt sprunghaft',
      'Oberlippenbart passt teilweise nicht zum restlichen Bart und verschwindet teilweise sogar',
      'Mimik der Augen passt nicht zur Stirn',
      'unnatürliches Blinzeln',
      'Augenbrauen wechseln über den Videoverlauf ihre Farbe'
    ],
  };
}
