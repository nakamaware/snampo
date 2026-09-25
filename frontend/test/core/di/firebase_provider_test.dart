import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/di/firebase_provider.dart';
import 'package:snampo/core/firebase/firebase_initializer.dart';

void main() {
  group('firebaseSetupReaderProvider', () {
    late int calls;
    late ProviderContainer container;

    setUp(() {
      calls = 0;
      container = ProviderContainer.test(
        overrides: [
          // 1 回目は失敗し、2 回目からは成功する
          firebaseSetupProvider.overrideWith((ref) async {
            calls++;
            if (calls == 1) {
              throw const FirebaseUnavailableException('失敗');
            }
            return const FirebaseSetup(appCheckDebugToken: null);
          }),
        ],
      );
    });

    Future<FirebaseSetup> read({required bool retryIfFailed}) => container.read(
      firebaseSetupReaderProvider,
    )(retryIfFailed: retryIfFailed);

    test('初期化に失敗したあと、再試行では初期化し直す', () async {
      await expectLater(
        read(retryIfFailed: true),
        throwsA(isA<FirebaseUnavailableException>()),
      );

      await expectLater(read(retryIfFailed: true), completes);
      expect(calls, 2);
    });

    test('再試行しないときは、失敗を返すだけで初期化し直さない', () async {
      await expectLater(
        read(retryIfFailed: true),
        throwsA(isA<FirebaseUnavailableException>()),
      );

      await expectLater(
        read(retryIfFailed: false),
        throwsA(isA<FirebaseUnavailableException>()),
      );
      expect(calls, 1);
    });

    test('失敗しても自動では再試行しない (再試行は決まったイベントのときだけ)', () async {
      await expectLater(
        read(retryIfFailed: false),
        throwsA(isA<FirebaseUnavailableException>()),
      );

      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(calls, 1);
    });

    test('初期化できていれば、初期化し直さない', () async {
      calls = 1;
      await read(retryIfFailed: true);
      await read(retryIfFailed: true);

      expect(calls, 2);
    });
  });
}
