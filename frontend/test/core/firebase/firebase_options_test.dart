import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/firebase/firebase_options.dart';

void main() {
  const defines = FirebaseDefines(
    androidApiKey: 'android-key',
    androidAppId: 'android-app',
    iosApiKey: 'ios-key',
    iosAppId: 'ios-app',
    messagingSenderId: '123',
  );

  group('firebaseOptionsFor', () {
    test('dev の Android は dart-define の Android の値と dev のプロジェクトを使う', () {
      final options =
          firebaseOptionsFor(
            isProd: false,
            platform: TargetPlatform.android,
            defines: defines,
          )!;

      expect(options.apiKey, 'android-key');
      expect(options.appId, 'android-app');
      expect(options.messagingSenderId, '123');
      expect(options.projectId, 'snampo-480404');
      expect(options.storageBucket, 'snampo-dev-coop');
      expect(options.iosBundleId, isNull);
    });

    test('prod の iOS は dart-define の iOS の値と prod のプロジェクトを使う', () {
      final options =
          firebaseOptionsFor(
            isProd: true,
            platform: TargetPlatform.iOS,
            defines: defines,
          )!;

      expect(options.apiKey, 'ios-key');
      expect(options.appId, 'ios-app');
      expect(options.messagingSenderId, '123');
      expect(options.projectId, 'snampo-prod');
      expect(options.storageBucket, 'snampo-prod-coop');
      expect(options.iosBundleId, 'com.nakamaware.snampo');
    });

    test('そのプラットフォームの値が 1 つでも未設定なら null を返す', () {
      const missingIosAppId = FirebaseDefines(
        androidApiKey: 'android-key',
        androidAppId: 'android-app',
        iosApiKey: 'ios-key',
        iosAppId: '',
        messagingSenderId: '123',
      );
      const missingSenderId = FirebaseDefines(
        androidApiKey: 'android-key',
        androidAppId: 'android-app',
        iosApiKey: 'ios-key',
        iosAppId: 'ios-app',
        messagingSenderId: '',
      );

      expect(
        firebaseOptionsFor(
          isProd: false,
          platform: TargetPlatform.iOS,
          defines: missingIosAppId,
        ),
        isNull,
      );
      expect(
        firebaseOptionsFor(
          isProd: false,
          platform: TargetPlatform.android,
          defines: missingSenderId,
        ),
        isNull,
      );
    });

    test('ほかのプラットフォームの値が未設定でも、そのプラットフォームの値があれば使える', () {
      const androidOnly = FirebaseDefines(
        androidApiKey: 'android-key',
        androidAppId: 'android-app',
        iosApiKey: '',
        iosAppId: '',
        messagingSenderId: '123',
      );

      expect(
        firebaseOptionsFor(
          isProd: false,
          platform: TargetPlatform.android,
          defines: androidOnly,
        ),
        isNotNull,
      );
    });
  });
}
