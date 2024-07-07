import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ordered_books/flows/auth_flow/auth_bloc.dart';
import 'package:ordered_books/flows/auth_flow/sign_in_screen.dart';
import 'package:riverbloc/riverbloc.dart';

export './sign_in_screen.dart';

final authBlocProvider = BlocProvider<AuthBloc, AuthState>(
  (ref) => AuthBloc(const UnkownAuth()),
);

typedef OnAuthenticated = void Function(BuildContext, Authenticaded);

class AuthFlow extends ConsumerWidget {
  const AuthFlow({
    super.key,
    required this.onAuthenticated,
  });

  final OnAuthenticated onAuthenticated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authBlocProvider, (prev, state) {
      {
        final authenticated = state.maybeAs<Authenticaded>();
        if (authenticated != null) {
          if (prev != null && prev.isA<Authenticaded>()) {
            return;
          }
          onAuthenticated(context, authenticated);
        }
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
