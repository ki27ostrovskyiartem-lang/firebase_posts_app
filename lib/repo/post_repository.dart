import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// CRUD для колекції posts. Зображення зберігається в самому документі як base64.
/// Документ: {title, text, imageBase64, ownerId, ownerEmail, createdAt}.
class PostRepository {
  PostRepository({FirebaseFirestore? db})
      : _col = (db ?? FirebaseFirestore.instance).collection('posts');
  final CollectionReference<Map<String, dynamic>> _col;

  /// Обмеження довжини base64: документ Firestore не може бути більшим за 1 МіБ.
  static const maxImageChars = 900000;

  /// Читання у реальному часі (для StreamBuilder).
  Stream<QuerySnapshot<Map<String, dynamic>>> watchPosts() =>
      _col.orderBy('createdAt', descending: true).snapshots();

  /// Створення. ownerId береться з поточного користувача.
  Future<void> create(User user, String title, String text,
      {String? imageBase64}) {
    return _col.add({
      'title': title,
      'text': text,
      'imageBase64': imageBase64,
      'ownerId': user.uid,
      'ownerEmail': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update(String id, String title, String text) =>
      _col.doc(id).update({'title': title, 'text': text});

  Future<void> delete(String id) => _col.doc(id).delete();

  /// Кодує зображення в base64 для збереження в документі.
  String encodeImage(Uint8List bytes) {
    final data = base64Encode(bytes);
    if (data.length > maxImageChars) {
      throw Exception('Зображення завелике, оберіть менше.');
    }
    return data;
  }
}
