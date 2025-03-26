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
      'Facial hair lacks details',
      'Light reflections on the skin',
      'Mouth movement appears artificial'
    ],
    'id02': [
      'Cheeks look too smooth',
      'Eye area doesn\'t match the rest',
      'Teeth look too smooth'
    ],
    'id03': [
      'Eye area looks unnatural',
      'Facial hair appears blurry',
      'Details and lighting of the nose look unnatural'
    ],
    'id04': [
      'Facial expressions look emotionless',
      'Eyes and mouth area look unnatural',
      'Transition from nose to eyebrows',
      'Light reflections on the skin are blurry'
    ],
    'id05': [
      'Facial expressions appear emotionless',
      'Facial hair lacks details',
      'Unnatural blinking'
    ],
    'id06': [
      'Mole not consistently the same',
      'Mustache and transition to lower beard don\'t match',
      'Skin color of cheeks and eye areas don\'t match the forehead',
      'Lower teeth not visible'
    ],
    'id07': [
      'When the head turns to the side: transition to background becomes blurry',
      'Cheeks and forehead look too smooth',
      'Eye area doesn\'t match the rest in color',
      'Eye bags look unnatural'
    ],
    'id08': ['Cheek area color changes'],
    'id09': ['Teeth without details', 'Eye area looks unnatural'],
    'id10': [
      'Eye area looks fake, especially when looking to the side',
      'Entire face looks too smooth',
      'Partially different cheek colors',
      'Forehead significantly darker than eye and cheek areas'
    ],
    'id11': [
      'Video appears jumpy',
      'Mustache sometimes doesn\'t match the rest of the beard and sometimes even disappears',
      'Eye expression doesn\'t match the forehead',
      'Unnatural blinking',
      'Eyebrows change color throughout the video'
    ],
  };
}
