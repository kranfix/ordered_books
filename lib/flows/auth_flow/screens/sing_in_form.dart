import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:formz/formz.dart';
import 'package:ordered_books/flows/auth_flow/screens/sing_in_cubit.dart';

class SingInForm extends ConsumerWidget {
  const SingInForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      SingInCubit.provider,
      (prev, curr) {
        if (curr.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(curr.errorMessage ?? 'Authentication Failure'),
              ),
            );
        }
      },
    );

    return Align(
      alignment: const Alignment(0, -1 / 3),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Use your Google account:'),
            const SizedBox(height: 8),
            _GoogleLoginButton(),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _GoogleLoginButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      key: const Key('loginForm_googleLogin_raisedButton'),
      label: const Text(
        'SIGN IN WITH GOOGLE',
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: theme.colorScheme.secondary,
      ),
      icon: const Icon(FontAwesomeIcons.google, color: Colors.white),
      onPressed: () => ref.read(SingInCubit.provider.bloc).logInWithGoogle(),
    );
  }
}
