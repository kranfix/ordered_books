import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ordered_books/flows/auth_flow/auth_bloc.dart';
import 'package:ordered_books/flows/auth_flow/sign_in_screen.dart';
import 'package:riverbloc/riverbloc.dart';

export './sign_in_screen.dart';

final authRepoProvider = Provider<AuthRepo>(
    (_) => throw UnimplementedError('authRepoProvider must be overriden'),
    name: 'authRepoProvider');

final authBlocProvider = BlocProvider<AuthBloc, AuthState>(
  (ref) => AuthBloc(authRepo: ref.read(authRepoProvider)),
);

typedef OnAuthenticated = void Function(BuildContext, AuthenticatedUser);

class AuthFlow extends ConsumerWidget {
  const AuthFlow({
    super.key,
    required this.onAuthenticated,
  });

  final OnAuthenticated onAuthenticated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authBlocProvider, (prev, state) {
      final authenticatedUser = state.authenticatedUSer;

      if (authenticatedUser != null) {
        onAuthenticated(context, authenticatedUser);
      }
    });
    return Navigator(
      onPopPage: (_, __) {
        return false;
      },
      pages: const [
        MaterialPage(
          name: 'signIn',
          child: SignInScreen(),
        ),
      ],
    );
  }
}
