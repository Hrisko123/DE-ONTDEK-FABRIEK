### Stap 1: Voeg de afhankelijkheid toe

Voeg de QR-code scanner package toe aan je `pubspec.yaml` bestand:

```yaml
dependencies:
  flutter:
    sdk: flutter
  qr_code_scanner: ^0.9.0 # Controleer op de laatste versie
```

Voer daarna `flutter pub get` uit om de afhankelijkheden te installeren.

### Stap 2: Maak een QR-code scanner pagina

Maak een nieuwe Dart-bestand aan, bijvoorbeeld `QRCodeScannerPage.dart`, en voeg de volgende code toe:

```dart
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'ToiletGame.dart'; // Importeer hier je minigame

class QRCodeScannerPage extends StatefulWidget {
  @override
  _QRCodeScannerPageState createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void initState() {
    super.initState();
    controller = QRViewController(qrKey, onQRViewCreated);
  }

  void onQRViewCreated(QRViewController controller) {
    controller.scannedDataStream.listen((scanData) {
      // Hier kun je de logica toevoegen om de gescande data te verwerken
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ToiletGamePage(), // Navigeer naar je minigame
        ),
      );
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreated,
      ),
    );
  }
}
```

### Stap 3: Navigeer naar de QR-code scanner

Voeg een knop toe in je `main.dart` of waar je de QR-code scanner wilt openen. Bijvoorbeeld:

```dart
void _navigateToQRCodeScanner() {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => QRCodeScannerPage()),
  );
}
```

### Stap 4: Voeg de navigatie toe aan je UI

Voeg een knop toe in je UI om de QR-code scanner te openen:

```dart
ElevatedButton(
  onPressed: _navigateToQRCodeScanner,
  child: Text('Scan QR Code'),
),
```

### Stap 5: Test de applicatie

Zorg ervoor dat je de juiste permissies hebt ingesteld in je `AndroidManifest.xml` voor Android:

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

### Stap 6: (Optioneel) Verwerk de gescande data

Als je specifieke data wilt verwerken die uit de QR-code komt, kun je dat doen in de `onQRViewCreated` functie, waar je de gescande data kunt controleren en daarop kunt reageren.

### Conclusie

Met deze stappen heb je een QR-code scanner toegevoegd aan je Flutter-app. Wanneer een QR-code wordt gescand, wordt de gebruiker doorgestuurd naar de `ToiletGamePage`. Je kunt de logica verder uitbreiden op basis van de gescande data.
