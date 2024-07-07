import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ordered_books/flows/books_flow/books_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BooksScreen extends ConsumerStatefulWidget {
  const BooksScreen({super.key, required this.email});

  final Email email;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BooksScreenState();
}

class _BooksScreenState extends ConsumerState<BooksScreen> {
  late final blocProv = BooksBloc.provider(widget.email);

  final refreseherController = RefreshController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blocProv.bloc).add(LoadedMoreBooks());
    });
  }

  @override
  Widget build(BuildContext context) {
    final booksState = ref.watch(blocProv);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
      ),
      body: BookItemScrollabeView(
        books: booksState.maybeCastedAs<BooksLoaded>()?.books,
        onReorder: (oldIndex, newIndex) {
          final event = ReorderdPosition(oldIndex, newIndex);
          ref.read(blocProv.bloc).add(event);
        },
      ),
      // body: SmartRefresher(
      //   enablePullDown: false,
      //   enablePullUp: true,
      //   controller: refreseherController,
      //   footer: Consumer(
      //     builder: (context, ref, child) {
      //       return Container(
      //         margin: const EdgeInsets.all(10),
      //         width: double.infinity,
      //         height: 30,
      //         child: child,
      //       );
      //     },
      //     child: const Row(
      //       children: [
      //         Text('Loading'),
      //         CircularProgressIndicator(),
      //       ],
      //     ),
      //   ),
      //   child: BookItemScrollabeView(
      //     books: booksState.maybeCastedAs<BooksLoaded>()?.books,
      //   ),
      // ),
    );
  }
}

class BookItemScrollabeView extends StatelessWidget {
  const BookItemScrollabeView({
    super.key,
    required this.books,
    required this.onReorder,
  });

  final List<BookItem>? books;
  final ReorderCallback onReorder;

  @override
  Widget build(BuildContext context) {
    final list = books;
    if (list == null) {
      return const Text('Loading books');
    }
    if (list.isEmpty) {
      return const SingleChildScrollView(
        child: Text("There aren't books"),
      );
    }
    return ReorderableListView.builder(
      shrinkWrap: true,
      itemCount: list.length,
      onReorder: (oldIndex, newIndex) {},
      itemBuilder: (context, index) => BookItemCard(
        key: Key(list[index].$id),
        book: list[index],
      ),
    );
  }
}

class BookItemCard extends StatelessWidget {
  const BookItemCard({super.key, required this.book});

  final BookItem book;

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: 267, // this fits the aspect ratio of the image
        height: 400,
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              book.imageUrl.toString(),
            ),
          ),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: UnconstrainedBox(
          child: Container(
            width: 240,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(150),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  book.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                  ),
                ),
                Text(
                  book.author,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
