import 'package:flutter/material.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';

/// Custom barcode scanner widget that properly handles camera resources
class CustomBarcodeScanner extends StatefulWidget {
  final Function(String)? onBarcodeDetected;
  final VoidCallback? onDispose;

  const CustomBarcodeScanner({
    super.key,
    this.onBarcodeDetected,
    this.onDispose,
  });

  @override
  State<CustomBarcodeScanner> createState() => _CustomBarcodeScannerState();
}

class _CustomBarcodeScannerState extends State<CustomBarcodeScanner> {
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    print('CustomBarcodeScanner: Disposing camera resources');
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Barcode Scanner
          AiBarcodeScanner(
            onDetect: (BarcodeCapture capture) {
              if (!_isDisposed && capture.barcodes.isNotEmpty) {
                final barcode = capture.barcodes.first.rawValue;
                if (barcode != null && mounted) {
                  print('CustomBarcodeScanner: Barcode detected: $barcode');
                  widget.onBarcodeDetected?.call(barcode);
                  Navigator.of(context).pop(barcode);
                }
              }
            },
            onDispose: () {
              print('CustomBarcodeScanner: AiBarcodeScanner disposed');
              _isDisposed = true;
            },
          ),
          // Overlay with instructions
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Point your camera at a barcode to scan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
