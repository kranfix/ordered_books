import 'dart:async';

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

/// {@template log_in_with_google_failure}
/// Thrown during the sign in with google process if a failure occurs.
/// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithCredential.html
/// {@endtemplate}
enum LogInWithGoogleFailure implements Exception {
  /// Account exists with different credentials
  accountExistWithDifferentCredentials,

  /// The credential received is malformed or has expired
  invalidCredential,

  /// Operation is not allowed.  Please contact support
  operationNotAllowed,

  /// This user has been disabled. Please contact support for help
  userDisabled,

  /// Email is not found, please create an account
  userNotFound,

  /// Incorrect password, please try again
  wrongPassord,

  /// The credential verification code received is invalid
  invalidVerificationCode,

  /// The credential verification ID received is invalid
  invalidVerificationId,

  /// An unknown exception occurred
  unknown,
}

/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {}

/// {@template authentication_repository}
/// Repository which manages user authentication.
/// {@endtemplate}
mixin AuthRepo {
  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> user();

  /// Returns the current cached user.
  /// Defaults to [User.empty] if there is no cached user.
  User getCurrentUser();

  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
  FutResult<(), LogInWithGoogleFailure> logInWithGoogle();

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  FutResult<(), LogOutFailure> logOut();
}

/// {@template user}
/// User model
///
/// [User.empty] represents an unauthenticated user.
/// {@endtemplate}
class User extends Equatable {
  /// {@macro user}
  const User({
    required this.id,
    this.email,
    this.name,
    this.photo,
  });

  /// The current user's email address.
  final Email? email;

  /// The current user's id.
  final String id;

  /// The current user's name (display name).
  final String? name;

  /// Url for the current user's photo.
  final String? photo;

  /// Empty user which represents an unauthenticated user.
  static const empty = User(id: '');

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == User.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != User.empty;

  @override
  List<Object?> get props => [email, id, name, photo];
}
