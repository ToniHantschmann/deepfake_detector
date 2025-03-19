import '../../config/localization/app_locale.dart';
import '../../constants/tutorial_types.dart';

abstract class GameEvent {
  const GameEvent();
}

class LoginWithPin extends GameEvent {
  final int pin;
  const LoginWithPin(this.pin);
}

class ShowLogin extends GameEvent {
  const ShowLogin();
}

class CancelLogin extends GameEvent {
  const CancelLogin();
}

class NextScreen extends GameEvent {
  const NextScreen();
}

class PreviousScreen extends GameEvent {
  const PreviousScreen();
}

class SelectDeepfake extends GameEvent {
  final bool isDeepfake;
  const SelectDeepfake(this.isDeepfake);
}

class MakeDeepfakeDecision extends GameEvent {
  final bool isDeepfake;
  const MakeDeepfakeDecision(this.isDeepfake);
}

class RestartGame extends GameEvent {
  const RestartGame();
}

class QuickStartGame extends GameEvent {
  const QuickStartGame();
}

class GeneratePin extends GameEvent {
  // callback method when pin is generated
  final void Function(String pin)? onPinGenerated;
  const GeneratePin({this.onPinGenerated});
}

class CheckPin extends GameEvent {
  final int pin;
  const CheckPin(this.pin);
}

class InitializeGame extends GameEvent {
  const InitializeGame();
}

class UpdateSelectedVideo extends GameEvent {
  final bool isDeepfake;
  const UpdateSelectedVideo(this.isDeepfake);
}

class StrategyIndexChanged extends GameEvent {
  final int newIndex;
  final String strategyId;
  final String? previousStrategyId;

  const StrategyIndexChanged({
    required this.newIndex,
    required this.strategyId,
    this.previousStrategyId,
  });
}

class ChangeLanguage extends GameEvent {
  final AppLocale locale;
  const ChangeLanguage(this.locale);
}

class TutorialCompleted extends GameEvent {
  final TutorialTypes tutorialType;
  const TutorialCompleted(this.tutorialType);
}
