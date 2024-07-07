import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ordered_books/flows/auth_flow/auth_bloc.dart';
import 'package:ordered_books/flows/auth_flow/auth_flow.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = Email.parse("email@gmail.com");

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Text('Do you want to sign in as email@gmail.com'),
            ElevatedButton(
              onPressed: () {
                ref.read(authBlocProvider.bloc).add(SignedIn(email));
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
