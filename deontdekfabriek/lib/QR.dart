import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:deontdekfabriek/ToiletGame.dart';

class QR extends StatefulWidget {
  const QR({super.key});

  @override
  State<QR> createState() => _QRState();
}

class _QRState extends State<QR> {
  MobileScannerController cameraController = MobileScannerController();
  String? qrText;
  String? _lastLaunched; // voorkom herhaald openen

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Scanner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.camera_rear),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final value = barcode.rawValue;
                if (value == null) continue;
                setState(() {
                  qrText = value;
                });

                // Als de QR verwijst naar de interne ToiletGame-pagina, navigeer intern
                if (value.contains('toilet.game')) {
                  if (_lastLaunched == value) return; // al geopend
                  _lastLaunched = value;
                  if (!mounted) return;
                  try {
                    // Navigeer naar het minigame scherm (ToiletGamePage)
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ToiletGamePage()),
                    );
                  } catch (_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kon pagina niet openen')),
                      );
                    }
                  }
                } else if (value.startsWith('http://') ||
                    value.startsWith('https://')) {
                  if (_lastLaunched == value) return;
                  _lastLaunched = value;
                  final uri = Uri.tryParse(value);
                  if (uri != null) {
                    try {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    } catch (_) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kon URL niet openen')),
                        );
                      }
                    }
                  }
                }
              }
            },
          ),
          if (qrText != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Gescande QR-code: $qrText',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
