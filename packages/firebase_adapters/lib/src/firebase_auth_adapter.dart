import 'package:domain/domain.dart';
import 'package:firebase_adapters/src/cache.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

/// Implementation of [AuthRepo] based on Firebase auth
class FirebaseAuthAdapter with AuthRepo {
  /// {@macro authentication_repository}
  FirebaseAuthAdapter({
    required bool web,
    CacheClient? cache,
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _cache = cache ?? CacheClient(),
        _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: [
                'email',
                'https://www.googleapis.com/auth/contacts.readonly',
              ],
            ),
        isWeb = web;

  final CacheClient _cache;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  /// Whether or not the current environment is web
  /// Should only be overridden for testing purposes. Otherwise,
  @visibleForTesting
  final bool isWeb;

  /// User cache key.
  /// Should only be used for testing purposes.
  @visibleForTesting
  static const userCacheKey = '__user_cache_key__';

  @override
  Stream<User> user() {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser == null ? User.empty : firebaseUser.toUser();
      _cache.write(key: userCacheKey, value: user);
      return user;
    });
  }

  @override
  User getCurrentUser() {
    return _cache.read<User>(key: userCacheKey) ?? User.empty;
  }

  @override
  FutResult<(), LogInWithGoogleFailure> logInWithGoogle() async {
    try {
      late final firebase_auth.AuthCredential credential;
      if (isWeb) {
        final googleProvider = firebase_auth.GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(
          googleProvider,
        );
        credential = userCredential.credential!;
      } else {
        final googleUser = await _googleSignIn.signIn();
        final googleAuth = await googleUser!.authentication;
        credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      }

      await _firebaseAuth.signInWithCredential(credential);
      return Ok(());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Err(e._toFailure());
    } catch (_) {
      return Err(LogInWithGoogleFailure.unknown);
    }
  }

  @override
  FutResult<(), LogOutFailure> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return Ok(());
    } catch (_) {
      return Err(LogOutFailure());
    }
  }
}

extension on firebase_auth.User {
  /// Maps a [firebase_auth.User] into a [User].
  User toUser() {
    return User(
      id: uid,
      email: email == null ? null : Email.maybeFrom(email!),
      name: displayName,
      photo: photoURL,
    );
  }
}

extension on firebase_auth.FirebaseAuthException {
  LogInWithGoogleFailure _toFailure() {
    switch (code) {
      case 'account-exists-with-different-credential':
        return LogInWithGoogleFailure.accountExistWithDifferentCredentials;
      case 'invalid-credential':
        return LogInWithGoogleFailure.invalidCredential;
      case 'operation-not-allowed':
        return LogInWithGoogleFailure.operationNotAllowed;
      case 'user-disabled':
        return LogInWithGoogleFailure.userDisabled;
      case 'user-not-found':
        return LogInWithGoogleFailure.userNotFound;
      case 'wrong-password':
        return LogInWithGoogleFailure.wrongPassord;
      case 'invalid-verification-code':
        return LogInWithGoogleFailure.invalidVerificationCode;
      case 'invalid-verification-id':
        return LogInWithGoogleFailure.invalidVerificationId;
      default:
        return LogInWithGoogleFailure.unknown;
    }
  }
}
