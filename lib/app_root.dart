import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ordered_books/flows/auth_flow/auth_flow.dart';
import 'package:ordered_books/flows/books_flow/books_screen.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Books app',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: AuthFlow(
          onAuthenticated: (context, authenticaded) {
            BooksScreen.navigate(
              context,
              email: authenticaded.email,
            );
          },
        ),
      ),
    );
  }
}
