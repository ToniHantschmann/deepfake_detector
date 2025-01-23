import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:deepfake_detector/blocs/game/game_bloc.dart';
import 'package:deepfake_detector/blocs/game/game_event.dart';
import 'package:deepfake_detector/blocs/game/game_state.dart';
import 'package:deepfake_detector/models/video_model.dart';
import 'package:deepfake_detector/models/statistics_model.dart';
import 'package:deepfake_detector/models/user_model.dart';
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
    pin: '1234',
    totalAttempts: 5,
    correctGuesses: 3,
    recentAttempts: [],
  );

  final testUser = User(
    pin: '1234',
    created: DateTime.parse('2024-01-01T10:00:00.000Z'),
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
        'starts game without PIN',
        setUp: () {
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
                state.currentPin == null &&
                state.videos.length == 2,
          ),
        ],
        verify: (_) {
          verify(mockVideoRepository.getRandomVideoPair()).called(1);
        },
      );

      blocTest<GameBloc, GameState>(
        'handles error during quick start',
        setUp: () {
          when(mockVideoRepository.getRandomVideoPair())
              .thenThrow(VideoException('Failed to load videos'));
        },
        build: () => gameBloc,
        act: (bloc) => bloc.add(const QuickStartGame()),
        expect: () => [
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.error &&
                state.errorMessage!.contains('Failed to load videos'),
          ),
        ],
      );
    });

    group('LoginWithPin', () {
      blocTest<GameBloc, GameState>(
        'logs in with valid PIN',
        setUp: () {
          when(mockUserRepository.getUserByPin('1234'))
              .thenAnswer((_) async => testUser);
          when(mockStatisticsRepository.getStatistics('1234'))
              .thenAnswer((_) async => testStats);
          when(mockVideoRepository.getRandomVideoPair())
              .thenAnswer((_) async => testVideos);
        },
        build: () => gameBloc,
        act: (bloc) => bloc.add(const LoginWithPin('1234')),
        expect: () => [
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.playing &&
                state.currentScreen == GameScreen.firstVideo &&
                state.currentPin == '1234' &&
                state.userStatistics == testStats &&
                state.videos.length == 2,
          ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'handles invalid PIN login',
        setUp: () {
          when(mockUserRepository.getUserByPin('9999'))
              .thenAnswer((_) async => null);
        },
        build: () => gameBloc,
        act: (bloc) => bloc.add(const LoginWithPin('9999')),
        expect: () => [
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.error &&
                state.errorMessage == 'Invalid PIN',
          ),
        ],
      );
    });

    group('GeneratePin', () {
      blocTest<GameBloc, GameState>(
        'generates new PIN and converts temporary stats',
        setUp: () {
          final tempStats = UserStatistics.temporary();
          when(mockUserRepository.createNewUser())
              .thenAnswer((_) async => '5678');
          when(mockStatisticsRepository.convertTemporaryStats(
                  tempStats, '5678'))
              .thenAnswer((_) async => testStats.copyWith(pin: '5678'));
        },
        seed: () => GameState(
          status: GameStatus.playing,
          currentScreen: GameScreen.statistics,
          videos: testVideos,
          userStatistics: UserStatistics.temporary(),
        ),
        build: () => gameBloc,
        act: (bloc) => bloc.add(const GeneratePin()),
        expect: () => [
          predicate<GameState>(
            (state) =>
                state.currentPin == '5678' &&
                state.generatedPin == '5678' &&
                state.userStatistics?.pin == '5678' &&
                !state.userStatistics!.isTemporary,
          ),
        ],
      );
    });

    group('SelectDeepfake', () {
      blocTest<GameBloc, GameState>(
        'records user selection and updates state',
        setUp: () {
          final updatedStats = UserStatistics(
            pin: "1234",
            totalAttempts: 5,
            correctGuesses: 3,
            recentAttempts: [],
          );
          when(mockStatisticsRepository.addAttempt(
            any,
            pin: anyNamed('pin'),
            stats: anyNamed('stats'),
          )).thenAnswer((_) async => updatedStats);
        },
        seed: () => GameState(
          status: GameStatus.playing,
          currentScreen: GameScreen.comparison,
          videos: testVideos,
          currentPin: '1234',
          userStatistics: testStats,
        ),
        build: () => gameBloc,
        act: (bloc) => bloc.add(const SelectDeepfake(1)),
        expect: () => [
          predicate<GameState>(
            (state) =>
                state.selectedVideoIndex == 1 &&
                state.isCorrectGuess == true &&
                state.userStatistics?.totalAttempts == 5 &&
                state.userStatistics?.correctGuesses == 3,
          ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'records temporary attempt without PIN',
        setUp: () {
          final tempStats = UserStatistics.temporary();
          when(mockStatisticsRepository.addAttempt(
            any,
            stats: tempStats,
          )).thenAnswer((_) async => tempStats.copyWith(
                totalAttempts: 1,
                correctGuesses: 1,
              ));
        },
        seed: () => GameState(
          status: GameStatus.playing,
          currentScreen: GameScreen.comparison,
          videos: testVideos,
          userStatistics: UserStatistics.temporary(),
        ),
        build: () => gameBloc,
        act: (bloc) => bloc.add(const SelectDeepfake(1)),
        expect: () => [
          predicate<GameState>(
            (state) =>
                state.selectedVideoIndex == 1 &&
                state.isCorrectGuess == true &&
                state.userStatistics!.isTemporary &&
                state.userStatistics!.totalAttempts == 1,
          ),
        ],
      );
    });

    group('RestartGame', () {
      blocTest<GameBloc, GameState>(
        'resets game while preserving PIN and stats',
        setUp: () {
          when(mockVideoRepository.getRandomVideoPair())
              .thenAnswer((_) async => testVideos);
          when(mockStatisticsRepository.getStatistics('1234'))
              .thenAnswer((_) async => testStats);
        },
        seed: () => GameState(
          status: GameStatus.playing,
          currentScreen: GameScreen.statistics,
          videos: testVideos,
          currentPin: '1234',
          userStatistics: testStats,
          selectedVideoIndex: 1,
          isCorrectGuess: true,
        ),
        build: () => gameBloc,
        act: (bloc) => bloc.add(const RestartGame()),
        expect: () => [
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.playing &&
                state.currentScreen == GameScreen.firstVideo &&
                state.currentPin == '1234' &&
                state.userStatistics == testStats &&
                state.selectedVideoIndex == null &&
                state.isCorrectGuess == null,
          ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'resets game with temporary stats',
        setUp: () {
          when(mockVideoRepository.getRandomVideoPair())
              .thenAnswer((_) async => testVideos);
        },
        seed: () => GameState(
          status: GameStatus.playing,
          currentScreen: GameScreen.statistics,
          videos: testVideos,
          userStatistics: UserStatistics.temporary(),
          selectedVideoIndex: 1,
          isCorrectGuess: true,
        ),
        build: () => gameBloc,
        act: (bloc) => bloc.add(const RestartGame()),
        expect: () => [
          predicate<GameState>((state) => state.status == GameStatus.loading),
          predicate<GameState>(
            (state) =>
                state.status == GameStatus.playing &&
                state.currentScreen == GameScreen.firstVideo &&
                state.currentPin == null &&
                state.userStatistics!.isTemporary &&
                state.userStatistics!.totalAttempts == 0,
          ),
        ],
      );
    });
  });
}
