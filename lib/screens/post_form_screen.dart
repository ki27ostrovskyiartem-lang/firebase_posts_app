import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../repo/post_repository.dart';

/// Форма створення або редагування запису з додаванням фото.
class PostFormScreen extends StatefulWidget {
  const PostFormScreen({super.key, required this.user, this.id, this.initial});
  final User user;
  final String? id;
  final Map<String, dynamic>? initial;

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _repo = PostRepository();
  late final _title = TextEditingController(text: widget.initial?['title']);
  late final _text = TextEditingController(text: widget.initial?['text']);
  Uint8List? _bytes;
  bool _busy = false;

  Future<void> _pick() async {
    // Зменшуємо фото, щоб воно вмістилося в документ Firestore.
    final x = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70);
    if (x == null) return;
    final b = await x.readAsBytes();
    setState(() => _bytes = b);
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      if (widget.id != null) {
        await _repo.update(widget.id!, _title.text.trim(), _text.text.trim());
      } else {
        final image = _bytes == null ? null : _repo.encodeImage(_bytes!);
        await _repo.create(widget.user, _title.text.trim(), _text.text.trim(),
            imageBase64: image);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Помилка: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.id != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Редагування' : 'Новий запис')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Заголовок')),
          TextField(
              controller: _text,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Текст')),
          const SizedBox(height: 12),
          if (!editing) ...[
            OutlinedButton.icon(
                onPressed: _busy ? null : _pick,
                icon: const Icon(Icons.image),
                label: const Text('Обрати зображення')),
            if (_bytes != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Image.memory(_bytes!, height: 160),
              ),
            if (_busy) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(),
              const Text('Збереження…'),
            ],
          ],
          const SizedBox(height: 16),
          FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(editing ? 'Зберегти' : 'Додати')),
        ],
      ),
    );
  }
}
