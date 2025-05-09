// Mocks generated by Mockito 5.4.5 from annotations
// in deepfake_detector/test/bloc/game_bloc_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;

import 'package:deepfake_detector/models/statistics_model.dart' as _i3;
import 'package:deepfake_detector/models/user_model.dart' as _i8;
import 'package:deepfake_detector/models/video_model.dart' as _i2;
import 'package:deepfake_detector/repositories/statistics_repository.dart'
    as _i6;
import 'package:deepfake_detector/repositories/user_repository.dart' as _i7;
import 'package:deepfake_detector/repositories/video_repository.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i9;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeVideo_0 extends _i1.SmartFake implements _i2.Video {
  _FakeVideo_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeUserStatistics_1 extends _i1.SmartFake
    implements _i3.UserStatistics {
  _FakeUserStatistics_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [VideoRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockVideoRepository extends _i1.Mock implements _i4.VideoRepository {
  @override
  _i5.Future<void> initialize() =>
      (super.noSuchMethod(
            Invocation.method(#initialize, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<List<_i2.Video>> getRandomVideoPair() =>
      (super.noSuchMethod(
            Invocation.method(#getRandomVideoPair, []),
            returnValue: _i5.Future<List<_i2.Video>>.value(<_i2.Video>[]),
            returnValueForMissingStub: _i5.Future<List<_i2.Video>>.value(
              <_i2.Video>[],
            ),
          )
          as _i5.Future<List<_i2.Video>>);

  @override
  _i5.Future<_i2.Video> getVideoById(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#getVideoById, [id]),
            returnValue: _i5.Future<_i2.Video>.value(
              _FakeVideo_0(this, Invocation.method(#getVideoById, [id])),
            ),
            returnValueForMissingStub: _i5.Future<_i2.Video>.value(
              _FakeVideo_0(this, Invocation.method(#getVideoById, [id])),
            ),
          )
          as _i5.Future<_i2.Video>);
}

/// A class which mocks [StatisticsRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockStatisticsRepository extends _i1.Mock
    implements _i6.StatisticsRepository {
  @override
  _i5.Future<void> initialize() =>
      (super.noSuchMethod(
            Invocation.method(#initialize, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<_i3.UserStatistics> getStatistics(String? pin) =>
      (super.noSuchMethod(
            Invocation.method(#getStatistics, [pin]),
            returnValue: _i5.Future<_i3.UserStatistics>.value(
              _FakeUserStatistics_1(
                this,
                Invocation.method(#getStatistics, [pin]),
              ),
            ),
            returnValueForMissingStub: _i5.Future<_i3.UserStatistics>.value(
              _FakeUserStatistics_1(
                this,
                Invocation.method(#getStatistics, [pin]),
              ),
            ),
          )
          as _i5.Future<_i3.UserStatistics>);

  @override
  _i5.Future<_i3.UserStatistics> addAttempt(
    _i3.GameAttempt? attempt, {
    String? pin,
    _i3.UserStatistics? stats,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #addAttempt,
              [attempt],
              {#pin: pin, #stats: stats},
            ),
            returnValue: _i5.Future<_i3.UserStatistics>.value(
              _FakeUserStatistics_1(
                this,
                Invocation.method(
                  #addAttempt,
                  [attempt],
                  {#pin: pin, #stats: stats},
                ),
              ),
            ),
            returnValueForMissingStub: _i5.Future<_i3.UserStatistics>.value(
              _FakeUserStatistics_1(
                this,
                Invocation.method(
                  #addAttempt,
                  [attempt],
                  {#pin: pin, #stats: stats},
                ),
              ),
            ),
          )
          as _i5.Future<_i3.UserStatistics>);

  @override
  _i5.Future<_i3.UserStatistics> convertTemporaryStats(
    _i3.UserStatistics? temporaryStats,
    String? newPin,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#convertTemporaryStats, [temporaryStats, newPin]),
            returnValue: _i5.Future<_i3.UserStatistics>.value(
              _FakeUserStatistics_1(
                this,
                Invocation.method(#convertTemporaryStats, [
                  temporaryStats,
                  newPin,
                ]),
              ),
            ),
            returnValueForMissingStub: _i5.Future<_i3.UserStatistics>.value(
              _FakeUserStatistics_1(
                this,
                Invocation.method(#convertTemporaryStats, [
                  temporaryStats,
                  newPin,
                ]),
              ),
            ),
          )
          as _i5.Future<_i3.UserStatistics>);

  @override
  _i5.Future<void> resetStatistics(String? pin) =>
      (super.noSuchMethod(
            Invocation.method(#resetStatistics, [pin]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<void> copyStatistics(String? fromPin, String? toPin) =>
      (super.noSuchMethod(
            Invocation.method(#copyStatistics, [fromPin, toPin]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);
}

/// A class which mocks [UserRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserRepository extends _i1.Mock implements _i7.UserRepository {
  @override
  _i5.Future<void> initialize() =>
      (super.noSuchMethod(
            Invocation.method(#initialize, []),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  _i5.Future<bool> pinExists(String? pin) =>
      (super.noSuchMethod(
            Invocation.method(#pinExists, [pin]),
            returnValue: _i5.Future<bool>.value(false),
            returnValueForMissingStub: _i5.Future<bool>.value(false),
          )
          as _i5.Future<bool>);

  @override
  _i5.Future<_i8.User?> getUserByPin(String? pin) =>
      (super.noSuchMethod(
            Invocation.method(#getUserByPin, [pin]),
            returnValue: _i5.Future<_i8.User?>.value(),
            returnValueForMissingStub: _i5.Future<_i8.User?>.value(),
          )
          as _i5.Future<_i8.User?>);

  @override
  _i5.Future<String> createNewUser() =>
      (super.noSuchMethod(
            Invocation.method(#createNewUser, []),
            returnValue: _i5.Future<String>.value(
              _i9.dummyValue<String>(
                this,
                Invocation.method(#createNewUser, []),
              ),
            ),
            returnValueForMissingStub: _i5.Future<String>.value(
              _i9.dummyValue<String>(
                this,
                Invocation.method(#createNewUser, []),
              ),
            ),
          )
          as _i5.Future<String>);

  @override
  _i5.Future<void> removeUser(String? pin) =>
      (super.noSuchMethod(
            Invocation.method(#removeUser, [pin]),
            returnValue: _i5.Future<void>.value(),
            returnValueForMissingStub: _i5.Future<void>.value(),
          )
          as _i5.Future<void>);

  @override
  bool isValidPin(String? pin) =>
      (super.noSuchMethod(
            Invocation.method(#isValidPin, [pin]),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);
}
