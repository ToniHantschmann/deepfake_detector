// lib/config/localization/english_reason_strings.dart

import 'string_types.dart';

class EnglishDeepfakeReasonStrings implements DeepfakeReasonStrings {
  const EnglishDeepfakeReasonStrings();

  @override
  List<String> getReasonsForVideo(String pairId) {
    // Try to find exact match
    if (_videoReasons.containsKey(pairId)) {
      return _videoReasons[pairId]!;
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
    'id01': [
      'Lack of detail in facial hair',
      'Unnatural light reflections on the skin',
      'Artificially appearing mouth movements when speaking'
    ],
    'id02': [
      'Excessively smooth cheek area without natural texture',
      'Color deviations of the eye area from the rest of the face',
      'Teeth appear too uniform without natural irregularities'
    ],
    'id03': [
      'Artificially appearing eye area',
      'Lack of detail in facial hair',
      'Blurred facial contours'
    ],
    'id04': [
      'Emotionless appearing facial expressions',
      'Artificially appearing eye and mouth area',
      'Unnatural transition from nose to eyebrows',
      'Blurred light reflections on the skin surface'
    ],
    'id05': [
      'Emotionless appearing facial expressions',
      'Lack of detail in facial hair',
      'Atypical blinking pattern with irregular frequency'
    ],
    'id06': [
      'Mole changes appearance and partially position',
      'Inconsistent representation between mustache and rest of the beard',
      'Color inconsistencies between cheeks, eye area, and forehead',
      'Lower row of teeth remains invisible when speaking'
    ],
    'id07': [
      'Blurred transitions to the background during lateral head rotations',
      'Excessively smooth cheek and forehead areas without natural texture',
      'Color deviations of the eye area from the rest of the face',
      'Unnatural representation of eye circles and shadowing'
    ],
    'id08': ['Changing coloration in the cheek area during facial movement'],
    'id09': [
      'Teeth appear too uniform without natural irregularities',
      'Artificially appearing eye area'
    ],
    'id10': [
      'Artificially appearing eye area, especially during lateral gaze directions',
      'Overall too uniform facial texture without natural variations',
      'Localized color differences in the cheek area',
      'Significantly darker forehead compared to eye and cheek area'
    ],
    'id11': [
      'Inconsistent representation of the mustache, which partially disappears',
      'Eye expressions do not match forehead movement',
      'Atypical blinking pattern with irregular frequency',
      'Color changes of the eyebrows throughout the video'
    ],
  };
}
