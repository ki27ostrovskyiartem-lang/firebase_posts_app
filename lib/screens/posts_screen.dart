import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../repo/auth_repository.dart';
import '../repo/post_repository.dart';
import 'post_form_screen.dart';

/// Список записів у реальному часі (StreamBuilder).
class PostsScreen extends StatelessWidget {
  PostsScreen({super.key, required this.auth, required this.user});
  final AuthRepository auth;
  final User user;
  final _posts = PostRepository();

  void _error(BuildContext c, Object e) {
    final msg = e is FirebaseException && e.code == 'permission-denied'
        ? 'Відмовлено: змінювати можна лише свої записи.'
        : 'Помилка: $e';
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.email ?? 'Записи'),
        actions: [
          IconButton(
            tooltip: 'Вийти',
            icon: const Icon(Icons.logout),
            onPressed: auth.signOut,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => PostFormScreen(user: user))),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _posts.watchPosts(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Помилка: ${snap.error}'));
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Записів поки немає'));
          }
          return ListView.builder(
            itemCount: docs.length,
            // Контекст елемента не використовуємо: під час видалення елемент
            // зникає зі списку раніше, ніж сервер відповість відмовою.
            itemBuilder: (_, i) {
              final d = docs[i];
              final m = d.data();
              final mine = m['ownerId'] == user.uid;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: m['imageBase64'] == null
                      ? const Icon(Icons.article)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.memory(base64Decode(m['imageBase64']),
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              gaplessPlayback: true)),
                  title: Text(m['title'] ?? ''),
                  subtitle: Text('${m['text'] ?? ''}\n${m['ownerEmail'] ?? ''}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PostFormScreen(
                                    user: user, id: d.id, initial: m))),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete,
                            color: mine ? null : Colors.grey),
                        onPressed: () async {
                          try {
                            await _posts.delete(d.id);
                          } catch (e) {
                            if (context.mounted) _error(context, e);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
