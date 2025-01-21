abstract class GameEvent {
  const GameEvent();
}

class LoginWithPin extends GameEvent {
  final String pin;
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
  final String pin;
  const CheckPin(this.pin);
}
