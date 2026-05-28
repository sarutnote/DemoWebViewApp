import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../data/api_service.dart';
import '../models/vrm_manifest.dart';
import 'webview_screen.dart';
import 'qr_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _idController = TextEditingController();
  final ApiService _apiService = ApiService();

  List<String> _vrmList = [];
  String? _selectedVrm;
  bool _isLoadingVrm = false;
  String? _vrmError;

  @override
  void initState() {
    super.initState();
    _fetchVrmList();
  }

  Future<void> _fetchVrmList() async {
    setState(() {
      _isLoadingVrm = true;
      _vrmError = null;
    });

    try {
      final VrmManifest manifest = await _apiService.fetchVrmManifest();
      setState(() {
        _vrmList = manifest.vrmList;
        if (_vrmList.isNotEmpty) {
          _selectedVrm = _vrmList.first;
        }
      });
    } catch (e) {
      setState(() {
        _vrmError = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingVrm = false;
      });
    }
  }

  void _navigateToWebView() {
    final idText = _idController.text.trim();
    if (idText.isNotEmpty && _selectedVrm != null) {
      final finalUrl = AppConstants.buildAvatarUrl(id: idText, avatar: _selectedVrm!);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewScreen(url: finalUrl),
        ),
      );
    } else if (idText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an ID')),
      );
    } else if (_selectedVrm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an Avatar')),
      );
    }
  }

  void _openQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    ).then((scannedResult) {
      if (scannedResult != null && scannedResult is String && scannedResult.isNotEmpty) {
        _showQRResultDialog(scannedResult);
      }
    });
  }

  void _showQRResultDialog(String scannedResult) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('QR Code Scanned'),
          content: Text('Scanned ID:\n$scannedResult'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                _idController.text = scannedResult;
              },
              child: const Text('Use ID'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Avatar App'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _idController,
                    autofocus: false, // Prevent keyboard from popping up immediately on launch
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _navigateToWebView(),
                    decoration: InputDecoration(
                      hintText: 'Enter ID...',
                      labelText: 'ID',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _idController.clear(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isLoadingVrm)
                    const Center(child: CircularProgressIndicator())
                  else if (_vrmError != null)
                    Text(
                      _vrmError!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    )
                  else
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Avatar',
                      ),
                      value: _selectedVrm,
                      items: _vrmList.map((String vrm) {
                        return DropdownMenuItem<String>(
                          value: vrm,
                          child: Text(vrm),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedVrm = newValue;
                        });
                      },
                    ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _navigateToWebView,
                    child: const Text('Go'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _openQRScanner,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan QR Code for ID'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
