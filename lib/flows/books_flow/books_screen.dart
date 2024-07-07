import 'package:commons/commons.dart';
import 'package:flutter/material.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key, required this.email});

  final Email email;

  static Future<void> navigate(BuildContext context, {required email}) {
    final navigator = Navigator.of(context);
    return navigator.push(MaterialPageRoute(
      builder: (context) => BooksScreen(email: email),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(email),
      ),
    );
  }
}
