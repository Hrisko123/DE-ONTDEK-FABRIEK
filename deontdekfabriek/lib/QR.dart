import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'HangOutGame.dart';
import 'stage_page.dart';
import 'ToiletGame.dart';
import 'FoodGame.dart';
import 'FestivalCleanerApp.dart';

class QRScannerPage extends StatefulWidget {
  final String festivalName;

  const QRScannerPage({super.key, required this.festivalName});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  late MobileScannerController controller;
  bool _alreadyScanned = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _navigate(Widget page) async {
    _alreadyScanned = true;
    await controller.stop();
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    // terug van minigame: scanner opnieuw klaarzetten
    _alreadyScanned = false;
    await controller.start();
  }

  Future<void> _handleQRCode(String qrValue) async {
    if (_alreadyScanned) return;

    final v = qrValue.trim().toLowerCase();

    // Hangout
    if (v.contains('hangout')) {
      await _navigate(const HangoutQuizPage());
      return;
    }

    // Stage / Podium
    if (v.contains('stage') || v.contains('podium')) {
      await _navigate(
        StagePage(
          festivalName: widget.festivalName,
          onMinigameCompleted: () {},
        ),
      );
      return;
    }

    // Toilet
    if (v.contains('toilet') || v.contains('wc')) {
      await _navigate(const ToiletGamePage());
      return;
    }

    // Food
    if (v.contains('food') || v.contains('eten')) {
      await _navigate(const FoodTruckPage());
      return;
    }

    // Waste / Cleaner
    if (v.contains('waste') || v.contains('cleaner') || v.contains('schoon')) {
      await _navigate(const FestivalCleanerApp());
      return;
    }

    // Onbekende QR
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Onbekende QR: $qrValue')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 139, 210, 142),
      appBar: AppBar(
        title: Text('${widget.festivalName} - Scan QR Codes'),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                final raw = barcode.rawValue;
                if (raw != null) {
                  _handleQRCode(raw);
                  break;
                }
              }
            },
          ),
          // Semi-transparent overlay met frame
          Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: QRFramePainter())),
          ),
          // Info text
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Scan een QR code om een minigame te spelen',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QRFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    const frameSize = 250.0;
    final frameLeft = (width - frameSize) / 2;
    final frameTop = (height - frameSize) / 2;

    final paint = Paint()..color = Colors.black.withOpacity(0.4);

    canvas.drawRect(Rect.fromLTWH(0, 0, width, frameTop), paint);
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        frameTop + frameSize,
        width,
        height - frameTop - frameSize,
      ),
      paint,
    );
    canvas.drawRect(Rect.fromLTWH(0, frameTop, frameLeft, frameSize), paint);
    canvas.drawRect(
      Rect.fromLTWH(
        frameLeft + frameSize,
        frameTop,
        width - frameLeft - frameSize,
        frameSize,
      ),
      paint,
    );

    final framePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTWH(frameLeft, frameTop, frameSize, frameSize),
      framePaint,
    );
  }

  @override
  bool shouldRepaint(QRFramePainter oldDelegate) => false;
}
