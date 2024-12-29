import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_event.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  //String? _currentUser;
  GameBloc() : super(const GameState());
}
