abstract class GameEvent {
  const GameEvent();
}

class InitializeGame extends GameEvent {
  const InitializeGame();
}

class LoginUser extends GameEvent {
  final String username;
  const LoginUser(this.username);
}

class StartGame extends GameEvent {
  const StartGame();
}

class NextScreen extends GameEvent {
  const NextScreen();
}

class SelectDeepfake extends GameEvent {
  final int videoIndex;
  const SelectDeepfake(this.videoIndex);
}

class RestartGame extends GameEvent {
  const RestartGame();
}
