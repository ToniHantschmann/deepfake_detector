abstract class GameEvent {
  const GameEvent();
}

class LoginExistingUser extends GameEvent {
  final String username;
  const LoginExistingUser(this.username);
}

class RegisterNewUser extends GameEvent {
  final String username;
  const RegisterNewUser(this.username);
}

class ShowLogin extends GameEvent {
  const ShowLogin();
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

class QuickStartGame extends GameEvent {
  const QuickStartGame();
}

class SaveTempUser extends GameEvent {
  final String username;
  const SaveTempUser(this.username);
}
