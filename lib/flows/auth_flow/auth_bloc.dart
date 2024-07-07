import 'package:riverbloc/riverbloc.dart';
import 'package:commons/commons.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(super.initialState) {
    on<SinedOut>(
      (ev, emit) {
        switch (state) {
          case UnkownAuth():
            emit(const Unauthenticaded());
          case Authenticaded():
            emit(const Unauthenticaded());
          case Unauthenticaded():
            break;
        }
      },
    );
    on<SignedIn>(
      (ev, emit) {
        switch (state) {
          case UnkownAuth():
            emit(Authenticaded(ev.email));
          case Unauthenticaded():
            emit(Authenticaded(ev.email));
          case Authenticaded():
            throw UnsupportedError('Can not be double authentication');
        }
      },
    );
  }
}

sealed class AuthEvent {
  const AuthEvent._();
}

class SignedIn extends AuthEvent {
  const SignedIn(this.email) : super._();

  final Email email;
}

class SinedOut extends AuthEvent {
  const SinedOut() : super._();
}

sealed class AuthState with Castable<AuthState> {
  const AuthState._();
}

class UnkownAuth extends AuthState {
  const UnkownAuth() : super._();
}

class Authenticaded extends AuthState {
  const Authenticaded(this.email) : super._();

  final Email email;
}

class Unauthenticaded extends AuthState {
  const Unauthenticaded() : super._();
}
