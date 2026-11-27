import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_posts_app/auth/auth_cubit.dart';
import 'package:firebase_posts_app/auth/auth_service.dart';
import 'package:firebase_posts_app/auth/auth_state.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService service;

  setUp(() {
    service = MockAuthService();
  });

  group('вхід', () {
    blocTest<AuthCubit, AuthState>(
      'успіх: Loading, потім Success',
      build: () {
        when(() => service.signIn(any(), any())).thenAnswer((_) async {});
        return AuthCubit(service);
      },
      act: (c) => c.submit('user@test.com', 'Test123!', register: false),
      expect: () => [const AuthLoading(), const AuthSuccess('user@test.com')],
      verify: (_) {
        verify(() => service.signIn('user@test.com', 'Test123!')).called(1);
        verifyNever(() => service.signUp(any(), any()));
      },
    );

    blocTest<AuthCubit, AuthState>(
      'пробіли навколо пошти обрізаються',
      build: () {
        when(() => service.signIn(any(), any())).thenAnswer((_) async {});
        return AuthCubit(service);
      },
      act: (c) => c.submit('  user@test.com  ', 'Test123!', register: false),
      expect: () => [const AuthLoading(), const AuthSuccess('user@test.com')],
      verify: (_) =>
          verify(() => service.signIn('user@test.com', 'Test123!')).called(1),
    );

    blocTest<AuthCubit, AuthState>(
      'помилка сервісу: Loading, потім Failure з текстом',
      build: () {
        when(() => service.signIn(any(), any()))
            .thenThrow(AuthException('Неправильна пошта або пароль.'));
        return AuthCubit(service);
      },
      act: (c) => c.submit('user@test.com', 'wrong-pass', register: false),
      expect: () => [
        const AuthLoading(),
        const AuthFailure('Неправильна пошта або пароль.'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'невідомий виняток перетворюється на загальне повідомлення',
      build: () {
        when(() => service.signIn(any(), any())).thenThrow(Exception('boom'));
        return AuthCubit(service);
      },
      act: (c) => c.submit('user@test.com', 'Test123!', register: false),
      expect: () => [
        const AuthLoading(),
        const AuthFailure('Невідома помилка. Спробуйте ще раз.'),
      ],
    );
  });

  group('реєстрація', () {
    blocTest<AuthCubit, AuthState>(
      'успіх викликає signUp, а не signIn',
      build: () {
        when(() => service.signUp(any(), any())).thenAnswer((_) async {});
        return AuthCubit(service);
      },
      act: (c) => c.submit('new@test.com', 'Pass1234', register: true),
      expect: () => [const AuthLoading(), const AuthSuccess('new@test.com')],
      verify: (_) {
        verify(() => service.signUp('new@test.com', 'Pass1234')).called(1);
        verifyNever(() => service.signIn(any(), any()));
      },
    );

    blocTest<AuthCubit, AuthState>(
      'пошта вже зайнята: Failure',
      build: () {
        when(() => service.signUp(any(), any()))
            .thenThrow(AuthException('Така пошта вже зареєстрована.'));
        return AuthCubit(service);
      },
      act: (c) => c.submit('user@test.com', 'Test123!', register: true),
      expect: () => [
        const AuthLoading(),
        const AuthFailure('Така пошта вже зареєстрована.'),
      ],
    );
  });

  group('валідація полів (сервіс не викликається)', () {
    blocTest<AuthCubit, AuthState>(
      'порожня пошта',
      build: () => AuthCubit(service),
      act: (c) => c.submit('', 'Test123!', register: false),
      expect: () => [const AuthFailure('Введіть пошту.')],
      verify: (_) {
        verifyNever(() => service.signIn(any(), any()));
        verifyNever(() => service.signUp(any(), any()));
      },
    );

    blocTest<AuthCubit, AuthState>(
      'некоректна пошта без @',
      build: () => AuthCubit(service),
      act: (c) => c.submit('user.test.com', 'Test123!', register: false),
      expect: () => [const AuthFailure('Некоректна адреса пошти.')],
      verify: (_) => verifyNever(() => service.signIn(any(), any())),
    );

    blocTest<AuthCubit, AuthState>(
      'граничне значення: пароль 5 символів відхиляється',
      build: () => AuthCubit(service),
      act: (c) => c.submit('user@test.com', '12345', register: false),
      expect: () => [
        const AuthFailure('Пароль має містити щонайменше 6 символів.')
      ],
      verify: (_) => verifyNever(() => service.signIn(any(), any())),
    );

    blocTest<AuthCubit, AuthState>(
      'граничне значення: пароль 6 символів приймається',
      build: () {
        when(() => service.signIn(any(), any())).thenAnswer((_) async {});
        return AuthCubit(service);
      },
      act: (c) => c.submit('user@test.com', '123456', register: false),
      expect: () => [const AuthLoading(), const AuthSuccess('user@test.com')],
    );
  });

  blocTest<AuthCubit, AuthState>(
    'seed: після попередньої помилки новий вхід знову дає Loading і Success',
    build: () {
      when(() => service.signIn(any(), any())).thenAnswer((_) async {});
      return AuthCubit(service);
    },
    seed: () => const AuthFailure('Неправильна пошта або пароль.'),
    act: (c) => c.submit('user@test.com', 'Test123!', register: false),
    expect: () => [const AuthLoading(), const AuthSuccess('user@test.com')],
  );

  test('початковий стан AuthInitial', () {
    expect(AuthCubit(service).state, const AuthInitial());
  });
}
