import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ordered_books/flows/auth_flow/auth_bloc.dart';
import 'package:ordered_books/flows/books_flow/books_bloc.dart';
import 'package:ordered_books/flows/flows.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BooksScreen extends ConsumerStatefulWidget {
  const BooksScreen({super.key, required this.email});

  final Email email;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BooksScreenState();
}

class _BooksScreenState extends ConsumerState<BooksScreen> {
  late final blocProv = BooksBloc.provider(widget.email);

  final refresehController = RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMoreBooks();
    });
  }

  @override
  void dispose() {
    super.dispose();
    refresehController.dispose();
  }

  void _loadMoreBooks() {
    ref.read(blocProv.bloc).add(LoadedMoreBooks());
  }

  @override
  Widget build(BuildContext context) {
    final booksState = ref.watch(blocProv);
    ref.listen<BooksState>(blocProv, (prev, curr) {
      if (!curr.isLoading) {
        //if (prev != null && prev.isLoading) {
        refresehController.loadComplete();
        //}
      } else {
        final state = curr.maybeCastedAs<BooksLoaded>();
        final err = state?.error;
        if (err != null) {
          refresehController.loadFailed();
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 20),
          child: Text('User: ${widget.email}'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authBlocProvider.bloc).add(const SignOutRequested()),
          ),
        ],
      ),
      body: SmartRefresher(
        enablePullDown: false,
        enablePullUp: true,
        controller: refresehController,
        onLoading: _loadMoreBooks,
        footer: CustomFooter(
          builder: (context, LoadStatus? status) {
            switch (status) {
              case null:
                return const Offstage();
              case LoadStatus.idle:
                return const Offstage();
              case LoadStatus.canLoading:
                return const Offstage();
              case LoadStatus.loading:
                return const LoadingFooter();
              case LoadStatus.noMore:
                return const Offstage();
              case LoadStatus.failed:
                return const ErrorFooter();
            }
          },
        ),
        child: BookItemScrollabeView(
          onReorder: (oldIndex, newIndex) {
            final event = ReorderdPosition(oldIndex, newIndex);
            ref.read(blocProv.bloc).add(event);
          },
          books: booksState.maybeCastedAs<BooksLoaded>()?.books,
        ),
      ),
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
      itemCount: list.length,
      onReorder: onReorder,
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

class RefresherFooter extends StatelessWidget {
  const RefresherFooter({
    super.key,
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: child,
    );
  }
}

class LoadingFooter extends StatelessWidget {
  const LoadingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return RefresherFooter(
      color: Colors.grey.shade300,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Loading',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(width: 20),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorFooter extends StatelessWidget {
  const ErrorFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return RefresherFooter(
      color: Colors.red.shade100,
      child: const Center(
        child: Text(
          'Error at loading more books',
          style: TextStyle(
            color: Colors.red,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
