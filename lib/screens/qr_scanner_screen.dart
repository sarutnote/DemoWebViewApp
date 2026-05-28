import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController? _scannerController;
  bool _isScanned = false;
  bool _hasPermission = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Request camera permission first
    final status = await Permission.camera.request();
    if (!mounted) return;

    if (status.isGranted) {
      _hasPermission = true;
      try {
        _scannerController = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
          autoStart: true,
        );
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to start camera: $e';
          });
        }
      }
    } else {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
        _errorMessage = 'Camera permission is required to scan QR codes.';
      });
    }
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initCamera,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasPermission) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.no_photography, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Camera permission is required.\nPlease allow camera access in Settings.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => openAppSettings(),
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      );
    }

    return MobileScanner(
      controller: _scannerController!,
      onDetect: (BarcodeCapture capture) {
        if (_isScanned) return;
        final List<Barcode> barcodes = capture.barcodes;
        for (final barcode in barcodes) {
          if (barcode.rawValue != null) {
            _isScanned = true;
            Navigator.pop(context, barcode.rawValue);
            break;
          }
        }
      },
    );
  }
}
