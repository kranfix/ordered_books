import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ordered_books/flows/books_flow/books_bloc.dart';
import 'package:ordered_books/flows/flows.dart';
import 'package:domain/domain.dart';

typedef RepoCreate<T> = T Function();

class AppRoot extends StatelessWidget {
  const AppRoot({
    super.key,
    required this.createAuthRepo,
    required this.createBooksRepo,
  });

  final RepoCreate<AuthRepo> createAuthRepo;
  final RepoCreate<BooksOnlineRepo> createBooksRepo;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        booksRepoProvider.overrideWith((_) => createBooksRepo()),
      ],
      child: MaterialApp(
        title: 'Books app',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: AuthFlow(
          onAuthenticated: (context, authenticaded) {
            BooksFlow.navigate(
              context,
              email: authenticaded.email,
            );
          },
        ),
      ),
    );
  }
}
