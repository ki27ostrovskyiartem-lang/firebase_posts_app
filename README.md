# Firebase Posts

Лабораторна робота 11, Сучасні технології проєктування.

## Що робить застосунок

- реєстрація й вхід (Email/Password, Firebase Authentication);
- записи в Cloud Firestore, список оновлюється в реальному часі;
- правила безпеки ([firestore.rules](firestore.rules)): читати можуть лише автентифіковані користувачі, змінювати й видаляти запис може лише його автор.

## Як запустити

Потрібні Flutter, Firebase CLI та FlutterFire CLI, а також власний Firebase-проєкт з увімкненим входом Email/Password і створеною базою Firestore, у якій опубліковано правила з `firestore.rules`.

```bash
flutter pub get
flutterfire configure
flutter run -d edge
```

`flutterfire configure` створює файл `lib/firebase_options.dart`. У репозиторії його немає.

## Примітка

Фото зберігається в Firestore як base64, бо Firebase Storage потребує тариф Blaze. Файл `storage.rules` лишився з початкового варіанта роботи й не використовується.
