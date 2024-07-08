import 'package:domain/domain.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:riverbloc/riverbloc.dart';

final booksRepoProvider = Provider<BooksOnlineRepo>(
  (_) => throw UnimplementedError('booksRepoProvider must be implemented'),
  name: 'booksRepoProvider',
);

typedef Reader = T Function<T>(ProviderListenable<T> provider);

class BooksBloc extends Bloc<BooksEvent, BooksState> with HydratedMixin {
  static final BlocProviderFamily<BooksBloc, BooksState, Email> provider =
      BlocProvider.family((ref, Email email) => BooksBloc(email, ref.read));

  BooksBloc(
    this.email,
    Reader reader, [
    super.initialState = const UnloadedBooks(false),
  ]) : read = reader {
    hydrate();

    on<LoadedMoreBooks>((ev, emit) async {
      if (state.isLoading) return;

      final booksRepo = read(booksRepoProvider);

      switch (state) {
        case UnloadedBooks():
          emit(const UnloadedBooks(true));
          switch (await booksRepo.fetchBooksPerUser(email)) {
            case Ok(value: final list):
              emit(BooksLoaded.filterReapeted(false, list));
            case Err(:final err):
              emit(BooksLoaded(false, [], BooksLoadedFetchError(err)));
          }
        case BooksLoaded(isLoading: _, :final books):
          emit(BooksLoaded(true, books));
          switch (await booksRepo.fetchBooksPerUser(email)) {
            case Ok(value: final incommingBooks):
              emit(BooksLoaded(false, books.mergeWith(incommingBooks)));
            case Err(:final err):
              emit(BooksLoaded(false, books, BooksLoadedFetchError(err)));
          }
      }
    });

    on<ReorderdPosition>((ev, emit) {
      final loadedState = state.maybeCastedAs<BooksLoaded>();
      if (loadedState == null) return;
      final list = loadedState.books;

      final N = list.length;
      if (ev.oldIndex >= N || ev.newIndex >= N) return;
      if (ev.oldIndex == ev.newIndex) return;

      final newList = <BookItem>[];

      final o = ev.oldIndex;
      final n = ev.newIndex;
      if (o < n) {
        newList.addAll(list.sublist(0, o));
        newList.addAll(list.sublist(o + 1, n));
        newList.add(list[o]);
        newList.addAll(list.sublist(n));
      } else {
        //     o=N-2
        //       n=N-1
        // [ A | |  ]
        newList.addAll(list.sublist(0, n));
        newList.add(list[o]);
        newList.addAll(list.sublist(n, o));
        newList.addAll(list.sublist(o + 1));
      }

      emit(BooksLoaded(state.isLoading, newList));
    });
  }

  final Email email;
  @override
  String get id => email;

  final Reader read;

  @override
  BooksState? fromJson(Map<String, dynamic> json) {
    final books = json['books'];
    const empty = BooksLoaded(false, []);
    if (books == null) return empty;
    if (books is! List<dynamic>) return empty;

    final books1 = <List<Object?>>[];
    for (final b in books) {
      if (b is! List<dynamic>) return empty;
      final objects = b.map((it) => it as Object?).toList();
      books1.add(objects);
    }

    return switch (BookItemListSerde.instance.deserialize(books1)) {
      Ok(value: final books) => BooksLoaded.filterReapeted(false, books),
      Err(:final err) => BooksLoaded(false, [], BooksLoadedSerDeError(err)),
    };
  }

  @override
  Map<String, dynamic>? toJson(BooksState state) {
    return switch (state) {
      UnloadedBooks() => {}, // empty map
      BooksLoaded(isLoading: _, :final books) => {
          'books': BookItemListSerde.instance.serialize(books)
        },
    };
  }
}

sealed class BooksEvent {}

/// Will read book items in local DB
class LoadedInitialBooks extends BooksEvent {
  LoadedInitialBooks();
}

/// Will load more book items from server
class LoadedMoreBooks extends BooksEvent {
  LoadedMoreBooks();
}

class ReorderdPosition extends BooksEvent {
  ReorderdPosition(this.oldIndex, this.newIndex);

  final int oldIndex;
  final int newIndex;
}

sealed class BooksState with Castable<BooksState> {
  const BooksState._(bool loading) : isLoading = loading;

  final bool isLoading;
}

class UnloadedBooks extends BooksState {
  const UnloadedBooks(super.loading) : super._();
}

class BooksLoaded extends BooksState {
  const BooksLoaded(super.loading, this.books, [this.error]) : super._();

  factory BooksLoaded.filterReapeted(bool loading, List<BookItem> books) {
    final list = <BookItem>[];
    final set = <String>{};
    for (final b in books) {
      if (!set.contains(b.$id)) {
        list.add(b);
        set.add(b.$id);
      }
    }
    return BooksLoaded(loading, list);
  }

  final List<BookItem> books;
  final BooksLoadedError? error;
}

sealed class BooksLoadedError implements Exception {
  const BooksLoadedError._();
}

class BooksLoadedFetchError extends BooksLoadedError {
  const BooksLoadedFetchError(this.err) : super._();

  final FetchBooksPerUserError err;
}

class BooksLoadedSerDeError extends BooksLoadedError {
  const BooksLoadedSerDeError(this.err) : super._();

  final DeseriablizeBookItemListError err;
}

extension MergeBooks on List<BookItem> {
  /// Merge with another book list
  /// - If the incomming book item exists, it is updated
  /// - If the incomming book item doesn't exists, it is added at the end
  List<BookItem> mergeWith(List<BookItem> incommingBooks) {
    final list = [...this];
    for (final ib in incommingBooks) {
      final index = indexWhere((book) => ib.$id == book.$id);
      if (index == -1) {
        list.add(ib);
      } else {
        // Necessary only when server data comes updated
        list[index] = ib;
      }
    }
    return list;
  }
}
