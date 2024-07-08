import 'package:books_sdk_adapters/books_sdk_apadaters.dart';
import 'package:firebase_adapters/firebase_adapters.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:ordered_books/app_root.dart';
import 'package:ordered_books/firebase_options.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    (() async {
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorage.webStorageDirectory
            : await getApplicationDocumentsDirectory(),
      );
    })(),
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
  ]);

  runApp(AppRoot(
    createAuthRepo: () => FirebaseAuthAdapter(web: kIsWeb),
    createBooksRepo: () => BooksSdkApadater(),
  ));
}
