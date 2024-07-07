import 'package:commons/commons.dart';
import 'package:flutter/material.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key, required this.email});

  final Email email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
      ),
      body: Center(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
