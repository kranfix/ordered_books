import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:ordered_books/flows/books_flow/books_screen.dart';

class BooksFlow extends StatelessWidget {
  const BooksFlow({super.key, required this.email});

  final Email email;

  static Future<void> navigate(BuildContext context, {required email}) {
    final navigator = Navigator.of(context);
    return navigator.push(MaterialPageRoute(
      builder: (context) => BooksFlow(email: email),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onPopPage: (_, __) {
        return false;
      },
      pages: [
        MaterialPage(
          name: 'books',
          child: BooksScreen(email: email),
        ),
      ],
    );
  }
}
