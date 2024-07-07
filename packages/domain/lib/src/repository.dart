import 'package:commons/commons.dart';
import 'package:domain/domain.dart';

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
  Version get $version => Version('1.0');

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
  FutResult<List<BookItem>, FetchBooksPerUserError> fetchBooksPerUser(
    Email email,
  );
}

/// Error when [BooksOnlineRepo] tries to `fetchBooksPerUser`
enum FetchBooksPerUserError implements Exception {
  /// Unexpected error
  unexpected,
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

typedef _BookItemDeResult = Result<BookItem, DeseriablizeBookItemError>;
// ignore: avoid_private_typedef_functions
typedef _BookItemDe = _BookItemDeResult Function(List<Object?> fields);

/// Serializer and Desializer for [BookItem]
class BookItemSerDe
    with SerDe<BookItem, List<Object?>, DeseriablizeBookItemError> {
  BookItemSerDe._();

  @override
  List<Object?> serialize(BookItem value) {
    return [
      value.$version,
      value.author,
      value.title,
      value.imageUrl.toString(),
    ];
  }

  @override
  Result<BookItem, DeseriablizeBookItemError> deserialize(List<Object?> value) {
    if (value.isEmpty) return Err(DeseriablizeBookItemError.versionNotFound);
    final version = value[0];
    if (version is! String) {
      return Err(DeseriablizeBookItemError.fieldWithWrongType);
    }
    final deserializer = _deserializers[version];
    if (deserializer == null) {
      return Err(DeseriablizeBookItemError.unsupportedVersion);
    }
    return deserializer(value.sublist(1));
  }

  final _deserializers = <String, _BookItemDe>{
    '1.0': (List<Object?> fields) {
      if (fields.length != 3) {
        return Err(DeseriablizeBookItemError.invalidNumberOfFields);
      }
      final author = fields[0].maybeCastedAs<String>();
      if (author == null) {
        return Err(DeseriablizeBookItemError.fieldWithWrongType);
      }

      final title = fields[1].maybeCastedAs<String>();
      if (title == null) {
        return Err(DeseriablizeBookItemError.fieldWithWrongType);
      }

      final imageUrlString = fields[1].maybeCastedAs<String>();
      if (imageUrlString == null) {
        return Err(DeseriablizeBookItemError.fieldWithWrongType);
      }
      // We will trust in this becuase it comes from an Uri
      final imageUrl = Uri.parse(imageUrlString);

      final bookItem = BookItem(
        author: author,
        title: title,
        imageUrl: imageUrl,
      );
      return Ok(bookItem);
    },
  };

  /// Instance of the [BookItemSerDe]
  static final instance = BookItemSerDe._();
}

/// Errors that can happen on deserializing a BookItem
enum DeseriablizeBookItemError implements Exception {
  /// Version fo the book item not found
  versionNotFound,

  // In the future, fieldWithWrongType must have arguments
  /// Version to deserialize is not supported
  unsupportedVersion,

  /// Invalid number of fields on the [List] of [Object]s
  invalidNumberOfFields,

  // In the future, fieldWithWrongType must have arguments
  /// Some field has wrong type
  fieldWithWrongType,
}

/// SerDe for [List]<[BookItem]>
class BookItemListSerde
    with
        SerDe<List<BookItem>, List<List<Object?>>,
            DeseriablizeBookItemListError> {
  const BookItemListSerde._();

  /// Instance for [BookItemListSerde]
  static const instance = BookItemListSerde._();

  @override
  Result<List<BookItem>, DeseriablizeBookItemListError> deserialize(
    List<List<Object?>> value,
  ) {
    final de = BookItemSerDe.instance.deserialize;
    final list = <BookItem>[];

    for (final el in value) {
      switch (de(el)) {
        case Ok(value: final bookItem):
          list.add(bookItem);
        case Err(:final err):
          return Err(DeseriablizeBookItemListError.from(err));
      }
    }
    return Ok(list);
  }

  @override
  List<List<Object?>> serialize(List<BookItem> value) {
    final ser = BookItemSerDe.instance.serialize;
    return value.map(ser).toList();
  }
}

/// Error when a [List]<[BookItem]> is not deserializable
enum DeseriablizeBookItemListError implements Exception {
  /// Error when item can not be serialized
  //itemNotDeserializable(BookItemListSerde),
  itemNotDeserializable;

  /// A "constuctor" for future compatibility when
  /// [DeseriablizeBookItemListError] becomes a sealed class
  static DeseriablizeBookItemListError from(DeseriablizeBookItemError err) {
    return DeseriablizeBookItemListError.itemNotDeserializable;
  }
}
