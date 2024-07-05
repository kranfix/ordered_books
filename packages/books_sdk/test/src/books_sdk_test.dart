// ignore_for_file: prefer_const_constructors
import 'dart:convert';

import 'package:books_sdk/books_sdk.dart';
import 'package:books_sdk/src/book_service.dart';
import 'package:test/test.dart';

final urlBase =
    Uri.parse('https://run.mocky.io/v3/82f1dcd9-3642-4bb6-81ba-098def155aaa');

void main() {
  group('BooksSdk can list books', () {
    test('SDK is well initialized', () async {
      final client = BooksSdk(urlBase);
      final books = await client.listBooks('email@gmail.com');
      expect(books.isNotEmpty, isTrue);
    });
  });

  group('serialization', () {
    test('Books is well parsed', () {
      const text = '''
{
  "author": "Oscar Wilde",
  "title": "The Picture of Dorian Gray",
  "image_url": "https://images.unsplash.com/photo-1513001900722-370f803f498d?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
}
''';
      final json = jsonDecode(text);
      expect(json, isA<Map<String, dynamic>>());
      final book = Book.fromJson(json as Map<String, dynamic>);
      expect(book.author, equals('Oscar Wilde'));
      expect(book.title, equals('The Picture of Dorian Gray'));
      expect(
        book.imageUrl,
        equals(
          Uri.parse(
            'https://images.unsplash.com/photo-1513001900722-370f803f498d?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          ),
        ),
      );
    });
  });

  test('BooksReponse is well parser', () {
    const text = '''
{
  "books": [
    {
      "author": "Oscar Wilde",
      "title": "The Picture of Dorian Gray",
      "image_url": "https://images.unsplash.com/photo-1513001900722-370f803f498d?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
    },
    {
      "author": "Bram Stoker",
      "title": "Dracula",
      "image_url": "https://images.unsplash.com/photo-1513001900722-370f803f498d?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
    }
  ]
}
''';

    final json = jsonDecode(text);
    expect(json, isA<Map<String, dynamic>>());
    final booksResponse = BooksResponse.fromJson(json as Map<String, dynamic>);
    expect(booksResponse.books.length, 2);
    expect(booksResponse.books[0].author, 'Oscar Wilde');
    expect(booksResponse.books[1].author, 'Bram Stoker');
  });
}
