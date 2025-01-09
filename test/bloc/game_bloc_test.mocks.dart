// Mocks generated by Mockito 5.4.5 from annotations
// in deepfake_detector/test/bloc/game_bloc_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;

import 'package:deepfake_detector/models/statistics_model.dart' as _i3;
import 'package:deepfake_detector/models/video_model.dart' as _i2;
import 'package:deepfake_detector/repositories/statistics_repository.dart'
    as _i6;
import 'package:deepfake_detector/repositories/user_repository.dart' as _i7;
import 'package:deepfake_detector/repositories/video_repository.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;

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
  _i5.Future<void> initialize() => (super.noSuchMethod(
        Invocation.method(#initialize, []),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<List<_i2.Video>> getRandomVideoPair() => (super.noSuchMethod(
        Invocation.method(#getRandomVideoPair, []),
        returnValue: _i5.Future<List<_i2.Video>>.value(<_i2.Video>[]),
        returnValueForMissingStub: _i5.Future<List<_i2.Video>>.value(
          <_i2.Video>[],
        ),
      ) as _i5.Future<List<_i2.Video>>);

  @override
  _i5.Future<_i2.Video> getVideoById(String? id) => (super.noSuchMethod(
        Invocation.method(#getVideoById, [id]),
        returnValue: _i5.Future<_i2.Video>.value(
          _FakeVideo_0(this, Invocation.method(#getVideoById, [id])),
        ),
        returnValueForMissingStub: _i5.Future<_i2.Video>.value(
          _FakeVideo_0(this, Invocation.method(#getVideoById, [id])),
        ),
      ) as _i5.Future<_i2.Video>);
}

/// A class which mocks [StatisticsRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockStatisticsRepository extends _i1.Mock
    implements _i6.StatisticsRepository {
  @override
  _i5.Future<void> initialize() => (super.noSuchMethod(
        Invocation.method(#initialize, []),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<_i3.UserStatistics> getStatistics(String? username) =>
      (super.noSuchMethod(
        Invocation.method(#getStatistics, [username]),
        returnValue: _i5.Future<_i3.UserStatistics>.value(
          _FakeUserStatistics_1(
            this,
            Invocation.method(#getStatistics, [username]),
          ),
        ),
        returnValueForMissingStub: _i5.Future<_i3.UserStatistics>.value(
          _FakeUserStatistics_1(
            this,
            Invocation.method(#getStatistics, [username]),
          ),
        ),
      ) as _i5.Future<_i3.UserStatistics>);

  @override
  _i5.Future<void> addAttempt(String? username, _i3.GameAttempt? attempt) =>
      (super.noSuchMethod(
        Invocation.method(#addAttempt, [username, attempt]),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> resetStatistics(String? username) => (super.noSuchMethod(
        Invocation.method(#resetStatistics, [username]),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> copyStatistics(String? fromUsername, String? toUsername) =>
      (super.noSuchMethod(
        Invocation.method(#copyStatistics, [fromUsername, toUsername]),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [UserRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserRepository extends _i1.Mock implements _i7.UserRepository {
  @override
  _i5.Future<void> initialize() => (super.noSuchMethod(
        Invocation.method(#initialize, []),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<List<String>> getUsers() => (super.noSuchMethod(
        Invocation.method(#getUsers, []),
        returnValue: _i5.Future<List<String>>.value(<String>[]),
        returnValueForMissingStub: _i5.Future<List<String>>.value(
          <String>[],
        ),
      ) as _i5.Future<List<String>>);

  @override
  _i5.Future<void> addUser(String? username) => (super.noSuchMethod(
        Invocation.method(#addUser, [username]),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<bool> userExists(String? username) => (super.noSuchMethod(
        Invocation.method(#userExists, [username]),
        returnValue: _i5.Future<bool>.value(false),
        returnValueForMissingStub: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i5.Future<void> removeUser(String? username) => (super.noSuchMethod(
        Invocation.method(#removeUser, [username]),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}
