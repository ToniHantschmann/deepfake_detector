import '../../config/localization/app_locale.dart';

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
  final int videoIndex;
  const SelectDeepfake(this.videoIndex);
}

class RestartGame extends GameEvent {
  const RestartGame();
}

class QuickStartGame extends GameEvent {
  const QuickStartGame();
}

class GeneratePin extends GameEvent {
  const GeneratePin();
}

class CheckPin extends GameEvent {
  final int pin;
  const CheckPin(this.pin);
}

class InitializeGame extends GameEvent {
  const InitializeGame();
}

class UpdateSelectedVideo extends GameEvent {
  final int videoIndex;
  const UpdateSelectedVideo(this.videoIndex);
}

class StrategyIndexChanged extends GameEvent {
  final int newIndex;
  final String strategyId;

  const StrategyIndexChanged({
    required this.newIndex,
    required this.strategyId,
  });
}

class ChangeLanguage extends GameEvent {
  final AppLocale locale;
  const ChangeLanguage(this.locale);
}
