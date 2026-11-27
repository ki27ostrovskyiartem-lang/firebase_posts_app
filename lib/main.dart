import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'repo/auth_repository.dart';
import 'screens/auth_screen.dart';
import 'screens/posts_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Без initializeApp жоден сервіс Firebase не працює.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PostsApp());
}

class PostsApp extends StatelessWidget {
  const PostsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthRepository();
    return MaterialApp(
      title: 'Firebase Posts',
      theme: ThemeData(
          colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
      home: StreamBuilder<User?>(
        stream: auth.authStateChanges(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          return snap.data == null
              ? AuthScreen(auth: auth)
              : PostsScreen(auth: auth, user: snap.data!);
        },
      ),
    );
  }
}
