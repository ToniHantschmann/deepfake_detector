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
      'Fehlende Details in der Gesichtsbehaarung',
      'Unnatürliche Lichtreflexionen auf der Haut',
      'Künstlich wirkende Mundbewegungen beim Sprechen'
    ],
    'id02': [
      'Übermäßig glatte Wangenpartie ohne natürliche Textur',
      'Farbliche Abweichungen der Augenpartie vom Rest des Gesichts',
      'Zähne erscheinen zu gleichmäßig ohne natürliche Unregelmäßigkeiten'
    ],
    'id03': [
      'Künstlich wirkende Augenpartie',
      'Fehlende Details in der Gesichtsbehaarung',
      'Unrealistische Beleuchtung im Nasenbereich??'
    ],
    'id04': [
      'Emotionslos wirkende Mimik',
      'Künstlich wirkende Augen- und Mundpartie',
      'Unnatürlicher Übergang von Nase zu Augenbrauen',
      'Unscharfe Lichtreflexionen auf der Hautoberfläche'
    ],
    'id05': [
      'Emotionslos wirkende Mimik',
      'Fehlende Details in der Gesichtsbehaarung',
      'Untypisches Blinzelmuster mit unregelmäßiger Häufigkeit'
    ],
    'id06': [
      'Leberfleck verändert Erscheinung und teilweise Position',
      'Inkonsistente Darstellung zwischen Oberlippenbart und restlichem Bart',
      'Farbliche Unstimmigkeiten zwischen Wangen, Augenpartie und Stirn',
      'Untere Zahnreihe bleibt beim Sprechen unsichtbar'
    ],
    'id07': [
      'Unscharfe Übergänge zum Hintergrund bei seitlichen Kopfdrehungen',
      'Übermäßig glatte Wangen- und Stirnpartie ohne natürliche Textur',
      'Farbliche Abweichungen der Augenpartie vom Rest des Gesichts',
      'Unnatürliche Darstellung von Augenringen und Schattierungen'
    ],
    'id08': [
      'Wechselnde Farbgebung im Wangenbereich während der Gesichtsbewegung'
    ],
    'id09': [
      'Zähne erscheinen zu gleichmäßig ohne natürliche Unregelmäßigkeiten',
      'Künstlich wirkende Augenpartie'
    ],
    'id10': [
      'Künstlich wirkende Augenpartie, besonders bei seitlichen Blickrichtungen',
      'Insgesamt zu gleichmäßige Gesichtstextur ohne natürliche Variationen',
      'Stellenweise Farbunterschiede im Wangenbereich',
      'Deutlich dunklere Stirn im Vergleich zu Augen- und Wangenbereich'
    ],
    'id11': [
      'Inkonsistente Darstellung des Oberlippenbarts mit teilweisem Verschwinden',
      'Mimik der Augen passt nicht zur Stirnbewegung',
      'Untypisches Blinzelmuster mit unregelmäßiger Häufigkeit',
      'Farbliche Veränderungen der Augenbrauen im Verlauf des Videos'
    ],
  };
}
