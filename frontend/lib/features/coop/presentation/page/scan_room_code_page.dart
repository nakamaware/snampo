import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';

/// ルームコードの QR を読む。
class ScanRoomCodePage extends StatefulWidget {
  /// [ScanRoomCodePage] を作成する。
  const ScanRoomCodePage({super.key});

  @override
  State<ScanRoomCodePage> createState() => _ScanRoomCodePageState();
}

class _ScanRoomCodePageState extends State<ScanRoomCodePage> {
  var _done = false;

  void _onDetect(BarcodeCapture capture) {
    if (_done) {
      return;
    }
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null || !RoomCode.canCreate(raw)) {
        continue;
      }
      _done = true;
      context.pop(RoomCode(raw).value);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: MobileScanner(onDetect: _onDetect),
    );
  }
}
