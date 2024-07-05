import 'package:books_sdk/src/book_service.dart';
import 'package:chopper/chopper.dart';

const _urlBase = 'https://run.mocky.io/v3/82f1dcd9-3642-4bb6-81ba-098def155aaa';

/// {@template books_sdk_BooksSdk}
/// SDK for book service
/// {@endtemplate}
class BooksSdk {
  /// {@macro books_sdk_BooksSdk}
  BooksSdk([Uri? baseUrl])
      : _chopper = ChopperClient(
          baseUrl: baseUrl ?? Uri.parse(_urlBase),
          converter: const JsonConverter(),
        );

  final ChopperClient _chopper;
  late final _bookService = BookService.create(_chopper);

  /// Returns the list of [Book]s
  Future<List<Book>> listBooks(String userEmail) async {
    final response = await _bookService.listBooks(userEmail);
    if (response.isSuccessful) {
      return BooksResponse.fromJson(response.body!).books;
    } else {
      throw Exception('Can not list books');
    }
  }
}
