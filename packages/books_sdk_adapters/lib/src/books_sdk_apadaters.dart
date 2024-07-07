import 'package:books_sdk/books_sdk.dart';
import 'package:domain/domain.dart';

/// {@template books_sdk_apadater}
/// [BooksSdk] apapter for [BooksOnlineRepo]
/// {@endtemplate}
class BooksSdkApadater with BooksOnlineRepo {
  /// {@macro books_sdk_apadater}
  BooksSdkApadater([Uri? baseUrl]) : booksSdk = BooksSdk(baseUrl);

  /// Books sdk to consume books services
  final BooksSdk booksSdk;

  @override
  FutResult<List<BookItem>, FetchBooksPerUserError> fetchBooksPerUser(
    Email email,
  ) async {
    try {
      final books = await booksSdk.listBooks(email);
      return Ok(books.map((b) => b.toBookItem()).toList());
    } catch (_) {
      return Err(FetchBooksPerUserError.unexpected);
    }
  }
}

extension _ToBookItem on Book {
  /// Converts a [Book] (from books_sdk) to [BookItem] (on domain)
  BookItem toBookItem() => BookItem(
        author: author,
        title: title,
        imageUrl: imageUrl,
      );
}
