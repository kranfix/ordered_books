import 'dart:async';

import 'package:commons/commons.dart';

/// {@template domain_BookItem}
/// BookItem
/// {@endtemplate}
class BookItem with Versionable<BookItem> {
  /// {@macro domain_BookItem}
  const BookItem({
    required this.author,
    required this.title,
    required this.imageUrl,
  });

  /// Version is not a field of data, but it's useful for
  /// versioning how it is stored in local DB
  @override
  Version get $version => Version('v1');

  @override
  VID<BookItem> get $id => VID.fromHash([author, title]);

  /// Author of the BookItem
  final String author;

  /// Title of the BookItem
  final String title;

  /// Image of the BookItem
  final Uri imageUrl;
}

/// Repository for consuming book services
// ignore: one_member_abstracts
mixin BooksOnlineRepo {
  /// Fetch books per user by the user email
  Future<List<BookItem>> fetchBooksPerUser(Email email);
}

// Not necessary when we use Hydrated bloc
// /// Repository for handling books in an offline context
// mixin BooksOfflineRepo {
//   /// Reads the list of stored books
//   FutureOr<List<BookItem>> readBooksPerUser(Email email);

//   /// For each new book, it will be appened in offline storage
//   /// it is wasn't stored previously.
//   /// NOTE:
//   ///   It is important to check the duplicity here to
//   ///   don't add twice a book item in offline storage
//   FutureOr<void> appendBooks(List<BookItem> newBooks);
// }
