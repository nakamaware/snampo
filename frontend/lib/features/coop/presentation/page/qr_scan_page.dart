import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:snampo/core/domain/room_code.dart';

/// ルームの QR を読み取り、[RoomCode] を返す画面
///
/// QR にはアプリ内のスキャナ専用の文字列 (`snampo:room:{roomCode}`) が入っている。
class QrScanPage extends HookWidget {
  /// [QrScanPage] を作成する
  const QrScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(MobileScannerController.new);
    useEffect(() => controller.dispose, [controller]);
    final done = useRef(false);
    final invalid = useState(false);

    return Scaffold(
      appBar: AppBar(title: const Text('QR を読み取る')),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (done.value) return;
              for (final barcode in capture.barcodes) {
                final raw = barcode.rawValue;
                final code = raw == null ? null : RoomCode.fromQrPayload(raw);
                if (code != null) {
                  done.value = true;
                  Navigator.of(context).pop(code);
                  return;
                }
              }
              invalid.value = true;
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  invalid.value
                      ? 'スナんぽのルームの QR ではありません'
                      : 'ホストの画面に表示された QR を読み取ってください',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
