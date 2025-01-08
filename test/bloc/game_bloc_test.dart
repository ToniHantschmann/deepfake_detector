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

import 'game_bloc_test.mocks.dart';

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

    group('QuickStartGame', () {
      blocTest<GameBloc, GameState>(
        'starts game with temporary user',
        setUp: () {
          when(mockUserRepository.addUser(any)).thenAnswer((_) async => {});
          when(mockStatisticsRepository.getStatistics(any))
              .thenAnswer((_) async => testStats);
          when(mockVideoRepository.getRandomVideoPair())
              .thenAnswer((_) async => testVideos);
        },
        build: () => gameBloc,
        act: (bloc) => bloc.add(const QuickStartGame()),
        expect: () => [
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.playing &&
                state.currentScreen == GameScreen.firstVideo &&
                state.isTemporaryUser == true &&
                state.videos.length == 2,
          ),
        ],
        verify: (_) {
          verify(mockUserRepository.addUser(any)).called(1);
          verify(mockVideoRepository.getRandomVideoPair()).called(1);
        },
      );

      blocTest<GameBloc, GameState>(
        'handles error during quick start',
        setUp: () {
          when(mockUserRepository.addUser(any))
              .thenThrow(UserException('Failed to create temp user'));
        },
        build: () => gameBloc,
        act: (bloc) => bloc.add(const QuickStartGame()),
        expect: () => [
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.error &&
                state.errorMessage!.contains('Failed to create temp user'),
          ),
        ],
      );
    });

    group('LoginExistingUser', () {
      blocTest<GameBloc, GameState>(
        'logs in existing user successfully',
        setUp: () {
          when(mockUserRepository.userExists('testUser'))
              .thenAnswer((_) async => true);
          when(mockStatisticsRepository.getStatistics('testUser'))
              .thenAnswer((_) async => testStats);
          when(mockVideoRepository.getRandomVideoPair())
              .thenAnswer((_) async => testVideos);
        },
        build: () => gameBloc,
        act: (bloc) => bloc.add(const LoginExistingUser('testUser')),
        expect: () => [
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.playing &&
                state.currentScreen == GameScreen.firstVideo &&
                state.currentUser == 'testUser' &&
                state.isTemporaryUser == false,
          ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'handles non-existent user login',
        setUp: () {
          when(mockUserRepository.userExists('nonexistent'))
              .thenAnswer((_) async => false);
        },
        build: () => gameBloc,
        act: (bloc) => bloc.add(const LoginExistingUser('nonexistent')),
        expect: () => [
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.error &&
                state.errorMessage!.contains('User does not exist'),
          ),
        ],
      );
    });

    group('RegisterNewUser', () {
      blocTest<GameBloc, GameState>(
        'registers new user successfully',
        setUp: () {
          when(mockUserRepository.addUser('newUser'))
              .thenAnswer((_) async => {});
          when(mockStatisticsRepository.getStatistics('newUser'))
              .thenAnswer((_) async => testStats);
          when(mockVideoRepository.getRandomVideoPair())
              .thenAnswer((_) async => testVideos);
        },
        build: () => gameBloc,
        act: (bloc) => bloc.add(const RegisterNewUser('newUser')),
        expect: () => [
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.playing &&
                state.currentScreen == GameScreen.firstVideo &&
                state.currentUser == 'newUser' &&
                state.isTemporaryUser == false,
          ),
        ],
      );
    });

    group('SaveTempUser', () {
      blocTest<GameBloc, GameState>(
        'converts temporary user to permanent user',
        setUp: () {
          // Add missing mock for getStatistics
          when(mockStatisticsRepository.getStatistics('temp'))
              .thenAnswer((_) async => testStats);

          when(mockUserRepository.addUser('permanent'))
              .thenAnswer((_) async => Future<void>.value());

          // Fix the return type for copyStatistics
          when(mockStatisticsRepository.copyStatistics('temp', 'permanent'))
              .thenAnswer((_) async => Future<void>.value());

          when(mockUserRepository.removeUser('temp'))
              .thenAnswer((_) async => Future<void>.value());
        },
        seed: () => const GameState(
          status: GameStatus.playing,
          currentScreen: GameScreen.firstVideo,
          videos: [],
          availableUsers: [],
          currentUser: 'temp',
          isTemporaryUser: true,
        ),
        build: () => gameBloc,
        act: (bloc) => bloc.add(const SaveTempUser('permanent')),
        expect: () => [
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.currentUser == 'permanent' &&
                state.isTemporaryUser == false &&
                state.userStatistics == testStats,
          ),
        ],
        verify: (_) {
          verify(mockStatisticsRepository.getStatistics('temp')).called(1);
          verify(mockUserRepository.addUser('permanent')).called(1);
          verify(mockStatisticsRepository.copyStatistics('temp', 'permanent'))
              .called(1);
          verify(mockUserRepository.removeUser('temp')).called(1);
        },
      );
    });

    group('SelectDeepfake', () {
      blocTest<GameBloc, GameState>(
        'records user selection and updates state',
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
          predicate<GameState>(
            (state) =>
                state.selectedVideoIndex == 1 && state.isCorrectGuess == true,
          ),
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
        build: () => gameBloc,
        seed: () => GameState(
          status: GameStatus.playing,
          currentScreen: GameScreen.firstVideo,
          videos: testVideos,
          availableUsers: const [],
          currentUser: 'testUser',
        ),
        act: (bloc) => bloc.add(const NextScreen()),
        expect: () => [
          predicate<GameState>(
              (state) => state.currentScreen == GameScreen.secondVideo),
        ],
      );
    });

    group('RestartGame', () {
      blocTest<GameBloc, GameState>(
        'resets game state while preserving user',
        setUp: () async {
          // Definiere alle möglichen Aufrufe vorab
          when(mockUserRepository.userExists('testUser'))
              .thenAnswer((_) async => true);
          when(mockStatisticsRepository.getStatistics('testUser'))
              .thenAnswer((_) async => testStats);
          when(mockVideoRepository.getRandomVideoPair())
              .thenAnswer((_) async => testVideos);

          // Pre-initialize repositories if needed
          await mockUserRepository.userExists('testUser');
          await mockStatisticsRepository.getStatistics('testUser');
          await mockVideoRepository.getRandomVideoPair();
        },
        seed: () => GameState(
          status: GameStatus.playing,
          currentScreen: GameScreen.statistics,
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
          isA<GameState>().having(
            (state) => state.status,
            'status',
            GameStatus.loading,
          ),
          isA<GameState>()
              .having((state) => state.status, 'status', GameStatus.playing)
              .having((state) => state.currentScreen, 'screen',
                  GameScreen.firstVideo)
              .having((state) => state.currentUser, 'user', 'testUser')
              .having((state) => state.selectedVideoIndex, 'selectedVideoIndex',
                  null)
              .having((state) => state.isCorrectGuess, 'isCorrectGuess', null)
              .having((state) => state.videos.length, 'videos length', 2),
        ],
      );
    });
  });
}
