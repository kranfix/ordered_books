import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:json_annotation/json_annotation.dart';

// This is necessary for the generator to work.
part 'book_service.chopper.dart';
part 'book_service.g.dart';

// typedef JConverter = chopper.JsonConverter;

/// [BookService] allows to get the books
@ChopperApi(baseUrl: '/')
abstract class BookService extends ChopperService {
  /// Creates a [BookService]
  static BookService create([ChopperClient? client]) => _$BookService(client);

  /// Reads a list of books by `userEmail`
  // @FactoryConverter(
  //   request: _convertRequest,
  //   response: _convertMapResponseToBooksResponse,
  // )
  @Post(
    headers: {contentTypeKey: jsonHeaders},
  )
  Future<Response<Map<String, dynamic>>> listBooks(
    @Field('user_email') String userEmail,
  );

  /// Similar to `listBooks` but with GET method
  @Get()
  Future<Response<String>> fetchBooks();
}

/// {@template books_sdk_book_response}
/// Response with the list of [Book]s
/// {@endtemplate}
@JsonSerializable(createToJson: false)
class BooksResponse {
  /// {@macro books_sdk_book_response}
  const BooksResponse(this.books);

  /// Build a [Book] `fromJson`
  factory BooksResponse.fromJson(Map<String, dynamic> json) =>
      _$BooksResponseFromJson(json);

  /// List of [Book]s
  final List<Book> books;
}

/// {@template book_sdk_book}
/// # Book
///
/// The [Book] of the list of requested books
/// {@endtemplate}
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class Book {
  /// {@macro book_sdk_book}
  const Book(this.author, this.title, this.imageUrl);

  /// Build a [Book] `fromJson`
  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  /// `author` of the book
  final String author;

  /// `title` of the book
  final String title;

  /// `imageUrl` of the book
  final Uri imageUrl;
}
