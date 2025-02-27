import 'dart:async';

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:riverbloc/riverbloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepo authRepo})
      : _autRepo = authRepo,
        super(
          authRepo.getCurrentUser().isNotEmpty
              ? AuthState.authenticated(authRepo.getCurrentUser())
              : const AuthState.unauthenticated(),
        ) {
    on<_UserChanged>(_onUserChanged);
    on<SignOutRequested>(_onLogoutRequested);
    _userSubscription = _autRepo.user().listen(
          (user) => add(_UserChanged(user)),
        );

    on<FakedUser>(_onFakedUser);
  }

  final AuthRepo _autRepo;
  late final StreamSubscription<User> _userSubscription;

  void _onUserChanged(_UserChanged event, Emitter<AuthState> emit) {
    emit(
      event.user.isNotEmpty
          ? AuthState.authenticated(event.user)
          : const AuthState.unauthenticated(),
    );
  }

  void _onLogoutRequested(SignOutRequested event, Emitter<AuthState> emit) {
    final email = state.user.email;
    if (email == null) return;
    if (email == 'email@gmail.com') {
      emit(const AuthState.unauthenticated());
    } else {
      unawaited(_autRepo.logOut());
    }
  }

  void _onFakedUser(FakedUser event, Emitter<AuthState> emit) {
    final user = User(
      id: 'fakedId',
      email: Email.parse('email@gmail.com'),
    );
    emit(AuthState.authenticated(user));
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}

sealed class AuthEvent {
  const AuthEvent();
}

final class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

final class _UserChanged extends AuthEvent {
  const _UserChanged(this.user);

  final User user;
}

final class FakedUser extends AuthEvent {
  const FakedUser();
}

enum AppStatus {
  authenticated,
  unauthenticated,
}

final class AuthState extends Equatable {
  const AuthState._({
    required this.status,
    this.user = User.empty,
  });

  const AuthState.authenticated(User user)
      : this._(status: AppStatus.authenticated, user: user);

  const AuthState.unauthenticated() : this._(status: AppStatus.unauthenticated);

  final AppStatus status;
  final User user;

  AuthenticatedUser? get authenticatedUSer {
    return switch (status) {
      AppStatus.authenticated => AuthenticatedUser._(user),
      AppStatus.unauthenticated => null,
    };
  }

  @override
  List<Object> get props => [status, user];
}

/// Authenticated [User]
extension type AuthenticatedUser._(User _user) implements User {
  @redeclare
  Email get email => _user.email!;
}
