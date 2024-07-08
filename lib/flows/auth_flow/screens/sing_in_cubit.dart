import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:ordered_books/flows/flows.dart';
import 'package:riverbloc/riverbloc.dart';

class SingInCubit extends Cubit<SingInState> {
  SingInCubit(this._authRepo) : super(const SingInState());

  final AuthRepo _authRepo;

  static final provider = BlocProvider<SingInCubit, SingInState>(
    (ref) => SingInCubit(ref.read(authRepoProvider)),
  );

  Future<void> logInWithGoogle() async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _authRepo.logInWithGoogle();
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on LogInWithGoogleFailure catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toMessage(),
          status: FormzSubmissionStatus.failure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}

final class SingInState extends Equatable {
  const SingInState({
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, isValid, errorMessage];

  SingInState copyWith({
    Email? email,
    FormzSubmissionStatus? status,
    bool? isValid,
    String? errorMessage,
  }) {
    return SingInState(
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

extension on LogInWithGoogleFailure {
  String toMessage() {
    return switch (this) {
      LogInWithGoogleFailure.accountExistWithDifferentCredentials =>
        'Account exists with different credentials.',
      LogInWithGoogleFailure.invalidCredential =>
        'The credential received is malformed or has expired.',
      LogInWithGoogleFailure.operationNotAllowed =>
        'Operation is not allowed.  Please contact support.',
      LogInWithGoogleFailure.userDisabled =>
        'This user has been disabled. Please contact support for help',
      LogInWithGoogleFailure.userNotFound =>
        'Email is not found, please create an account.',
      LogInWithGoogleFailure.wrongPassord =>
        'Incorrect password, please try again.',
      LogInWithGoogleFailure.invalidVerificationCode =>
        'The credential verification code received is invalid.',
      LogInWithGoogleFailure.invalidVerificationId =>
        'The credential verification ID received is invalid.',
      LogInWithGoogleFailure.unknown => 'An unknown exception occurred.',
    };
  }
}
