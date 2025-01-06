import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:deepfake_detector/blocs/game/game_bloc.dart';
import 'package:deepfake_detector/blocs/game/game_event.dart';
import 'package:deepfake_detector/blocs/game/game_state.dart';
import 'package:deepfake_detector/models/video_model.dart';
import 'package:deepfake_detector/models/statistics_model.dart';
import 'package:deepfake_detector/repositories/video_repository.dart';
import 'package:deepfake_detector/repositories/statistics_repository.dart';
import 'package:deepfake_detector/repositories/user_repository.dart';
import 'package:deepfake_detector/exceptions/app_exceptions.dart';

import '../mocks/game_bloc_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<VideoRepository>(),
  MockSpec<StatisticsRepository>(),
  MockSpec<UserRepository>()
])
void main() {
  late GameBloc gameBloc;
  late MockVideoRepository mockVideoRepository;
  late MockStatisticsRepository mockStatisticsRepository;
  late MockUserRepository mockUserRepository;

  // Test data
  final testVideos = [
    Video(
      id: '1',
      title: 'Real Video',
      description: 'A real video',
      videoUrl: 'real.mp4',
      thumbnailUrl: 'real.jpg',
      isDeepfake: false,
      deepfakeIndicators: [],
    ),
    Video(
      id: '2',
      title: 'Fake Video',
      description: 'A deepfake video',
      videoUrl: 'fake.mp4',
      thumbnailUrl: 'fake.jpg',
      isDeepfake: true,
      deepfakeIndicators: ['Unnatural lip movements'],
    ),
  ];

  final testStats = UserStatistics(
    username: 'testUser',
    totalAttempts: 5,
    correctGuesses: 3,
    recentAttempts: [],
  );

  setUp(() {
    mockVideoRepository = MockVideoRepository();
    mockStatisticsRepository = MockStatisticsRepository();
    mockUserRepository = MockUserRepository();

    gameBloc = GameBloc(
      videoRepository: mockVideoRepository,
      statisticsRepository: mockStatisticsRepository,
      userRepository: mockUserRepository,
    );
  });

  tearDown(() {
    gameBloc.close();
  });

  group('GameBloc', () {
    test('initial state is correct', () {
      expect(gameBloc.state, const GameState.initial());
    });

    group('InitializeGame', () {
      blocTest<GameBloc, GameState>(
        'emits loading then login state with available users',
        setUp: () {
          when(mockUserRepository.getUsers())
              .thenAnswer((_) async => ['user1', 'user2']);
        },
        build: () => gameBloc,
        act: (bloc) => bloc.add(const InitializeGame()),
        expect: () => [
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.login &&
                state.availableUsers.length == 2,
          ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'emits error state when loading users fails',
        setUp: () {
          when(mockUserRepository.getUsers())
              .thenThrow(UserException('Failed to load users'));
        },
        build: () => gameBloc,
        act: (bloc) => bloc.add(const InitializeGame()),
        expect: () => [
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.error &&
                state.errorMessage == 'Failed to load users',
          ),
        ],
      );
    });

    group('LoginUser', () {
      blocTest<GameBloc, GameState>(
        'creates new user and starts game when username is new',
        setUp: () {
          when(mockUserRepository.addUser('newUser'))
              .thenAnswer((_) async => {});
          when(mockStatisticsRepository.getStatistics('newUser'))
              .thenAnswer((_) async => UserStatistics.initial('newUser'));
          when(mockVideoRepository.getRandomVideoPair())
              .thenAnswer((_) async => testVideos);
        },
        build: () => gameBloc,
        act: (bloc) => bloc.add(const LoginUser('newUser')),
        expect: () => [
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.ready &&
                state.currentUser == 'newUser',
          ),
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.playing &&
                state.currentScreen == GameScreen.introduction &&
                state.videos == testVideos,
          ),
        ],
        verify: (_) {
          verify(mockUserRepository.addUser('newUser')).called(1);
        },
      );

      blocTest<GameBloc, GameState>(
        'handles existing user login correctly',
        setUp: () {
          when(mockStatisticsRepository.getStatistics('existingUser'))
              .thenAnswer((_) async => testStats);
          when(mockVideoRepository.getRandomVideoPair())
              .thenAnswer((_) async => testVideos);
        },
        seed: () => const GameState(
          status: GameStatus.login,
          currentScreen: GameScreen.introduction,
          videos: [],
          availableUsers: ['existingUser'], // Hier den Benutzer hinzufügen
          currentUser: null,
        ),
        build: () => gameBloc,
        act: (bloc) => bloc.add(const LoginUser('existingUser')),
        expect: () => [
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.ready &&
                state.currentUser == 'existingUser' &&
                state.userStatistics == testStats,
          ),
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.playing &&
                state.videos == testVideos,
          ),
        ],
        verify: (_) {
          verifyNever(mockUserRepository.addUser('existingUser'));
        },
      );
    });

    group('StartGame', () {
      blocTest<GameBloc, GameState>(
        'loads videos and transitions to introduction screen',
        setUp: () {
          when(mockVideoRepository.getRandomVideoPair())
              .thenAnswer((_) async => testVideos);
        },
        seed: () => const GameState(
          status: GameStatus.ready,
          currentScreen: GameScreen.introduction,
          videos: [],
          availableUsers: [],
          currentUser: 'testUser',
        ),
        build: () => gameBloc,
        act: (bloc) => bloc.add(const StartGame()),
        expect: () => [
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.playing &&
                state.currentScreen == GameScreen.introduction &&
                state.videos == testVideos,
          ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'emits error when loading videos fails',
        setUp: () {
          when(mockVideoRepository.getRandomVideoPair())
              .thenThrow(VideoException('Failed to load videos'));
        },
        seed: () => const GameState(
          status: GameStatus.ready,
          currentScreen: GameScreen.introduction,
          videos: [],
          availableUsers: [],
          currentUser: 'testUser',
        ),
        build: () => gameBloc,
        act: (bloc) => bloc.add(const StartGame()),
        expect: () => [
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.error &&
                state.errorMessage == 'Failed to load videos',
          ),
        ],
      );
    });

    group('SelectDeepfake', () {
      blocTest<GameBloc, GameState>(
        'records correct guess and updates state',
        setUp: () {
          when(mockStatisticsRepository.addAttempt(any, any))
              .thenAnswer((_) async => {});
        },
        seed: () => GameState(
          status: GameStatus.playing,
          currentScreen: GameScreen.comparison,
          videos: testVideos,
          availableUsers: const [],
          currentUser: 'testUser',
        ),
        build: () => gameBloc,
        act: (bloc) => bloc.add(const SelectDeepfake(1)),
        expect: () => [
          predicate<GameState>((state) =>
              state.status == GameStatus.playing &&
              state.selectedVideoIndex == 1 &&
              state.isCorrectGuess == true),
        ],
        verify: (_) {
          verify(mockStatisticsRepository.addAttempt('testUser', any))
              .called(1);
        },
      );

      blocTest<GameBloc, GameState>(
        'records incorrect guess and updates state',
        setUp: () {
          when(mockStatisticsRepository.addAttempt(any, any))
              .thenAnswer((_) async => {});
        },
        seed: () => GameState(
          status: GameStatus.playing,
          currentScreen: GameScreen.comparison,
          videos: testVideos,
          availableUsers: const [],
          currentUser: 'testUser',
        ),
        build: () => gameBloc,
        act: (bloc) => bloc.add(const SelectDeepfake(0)),
        expect: () => [
          predicate<GameState>((state) =>
              state.status == GameStatus.playing &&
              state.selectedVideoIndex == 0 &&
              state.isCorrectGuess == false),
        ],
        verify: (_) {
          verify(mockStatisticsRepository.addAttempt('testUser', any))
              .called(1);
        },
      );
    });

    group('NextScreen', () {
      blocTest<GameBloc, GameState>(
        'transitions through screens correctly',
        seed: () => GameState(
          status: GameStatus.playing,
          currentScreen: GameScreen.introduction,
          videos: testVideos,
          availableUsers: const [],
          currentUser: 'testUser',
        ),
        build: () => gameBloc,
        act: (bloc) => bloc
          ..add(const NextScreen())
          ..add(const NextScreen())
          ..add(const NextScreen()),
        expect: () => [
          predicate<GameState>(
              (state) => state.currentScreen == GameScreen.firstVideo),
          predicate<GameState>(
              (state) => state.currentScreen == GameScreen.secondVideo),
          predicate<GameState>(
              (state) => state.currentScreen == GameScreen.comparison),
        ],
      );

      blocTest<GameBloc, GameState>(
        'loads statistics before transitioning to statistics screen',
        setUp: () {
          when(mockStatisticsRepository.getStatistics('testUser'))
              .thenAnswer((_) async => testStats);
        },
        seed: () => GameState(
          status: GameStatus.playing,
          currentScreen: GameScreen.result,
          videos: testVideos,
          availableUsers: const [],
          currentUser: 'testUser',
          selectedVideoIndex: 1,
          isCorrectGuess: true,
        ),
        build: () => gameBloc,
        act: (bloc) => bloc.add(const NextScreen()),
        expect: () => [
          predicate<GameState>(
            (state) =>
                state.currentScreen == GameScreen.statistics &&
                state.userStatistics == testStats,
          ),
        ],
      );
    });

    group('RestartGame', () {
      blocTest<GameBloc, GameState>(
        'resets game from statistics screen while preserving user info',
        setUp: () {
          when(mockVideoRepository.getRandomVideoPair())
              .thenAnswer((_) async => testVideos);
          when(mockUserRepository.userExists('testUser'))
              .thenAnswer((_) async => true);
        },
        seed: () => GameState(
          status: GameStatus.playing,
          currentScreen:
              GameScreen.statistics, // Geändert von result zu statistics
          videos: testVideos,
          availableUsers: const [],
          currentUser: 'testUser',
          userStatistics: testStats,
          selectedVideoIndex: 1,
          isCorrectGuess: true,
        ),
        build: () => gameBloc,
        act: (bloc) => bloc.add(const RestartGame()),
        expect: () => [
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.ready &&
                state.currentUser == 'testUser' &&
                state.userStatistics == testStats,
          ),
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.playing &&
                state.currentScreen == GameScreen.introduction &&
                state.videos == testVideos,
          ),
        ],
      );
    });
  });
}
