import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/features/mission/application/interface/location_service.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/presentation/component/map_floating_surface.dart';

/// 地図に浮かべる、現在地へ戻るボタン
///
/// 押すたびに現在地を取り直し (取得中はくるくる)、取れたら [onLocated] で地図を寄せる。
/// 取得中に [cancel] が通知されたら (地図に触れたとき)、取れても寄せない。
/// 現在地を取れなければ、理由と設定を開くボタンをスナックバーで出す。
class MyLocationButton extends HookConsumerWidget {
  /// [MyLocationButton] を作成する
  const MyLocationButton({required this.onLocated, this.cancel, super.key});

  /// 現在地が取れたとき (地図を寄せる)
  final ValueChanged<Coordinate> onLocated;

  /// 通知されると、取得中の寄せをやめる
  final Listenable? cancel;

  /// ボタンの直径
  static const size = 48.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocating = useState(false);
    // 押すたびに進める。取れたときに変わっていれば、その取得は捨てる
    final request = useRef(0);

    useEffect(() {
      final cancel = this.cancel;
      if (cancel == null) return null;
      void onCancel() {
        if (!isLocating.value) return;
        request.value++;
        isLocating.value = false;
      }

      cancel.addListener(onCancel);
      return () => cancel.removeListener(onCancel);
    }, [cancel]);

    Future<void> locate() async {
      final id = ++request.value;
      isLocating.value = true;
      final messenger = ScaffoldMessenger.of(context);
      try {
        final position = await ref.read(getCurrentPositionUseCaseProvider)();
        if (!context.mounted || id != request.value) return;
        onLocated(position);
      } on LocationUnavailableException catch (e) {
        if (!context.mounted || id != request.value) return;
        final openSettings = ref.read(openLocationSettingsUseCaseProvider);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(_unavailableMessage(e.reason)),
              action: SnackBarAction(
                label: '設定を開く',
                onPressed: () => openSettings(e.reason),
              ),
            ),
          );
      } on Exception {
        if (!context.mounted || id != request.value) return;
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('現在地を取得できませんでした')));
      } finally {
        if (context.mounted && id == request.value) {
          isLocating.value = false;
        }
      }
    }

    return MapFloatingSurface(
      shape: const CircleBorder(),
      child: SizedBox.square(
        dimension: size,
        child:
            isLocating.value
                ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
                : IconButton(
                  tooltip: '現在地',
                  icon: const Icon(Icons.my_location),
                  onPressed: locate,
                ),
      ),
    );
  }
}

String _unavailableMessage(LocationUnavailableReason reason) =>
    switch (reason) {
      LocationUnavailableReason.serviceDisabled => '位置情報をオンにしてください',
      LocationUnavailableReason.permissionDenied => '位置情報の利用を許可してください',
    };
