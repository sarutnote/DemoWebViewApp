import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../data/api_service.dart';
import '../models/vrm_manifest.dart';
import 'webview_screen.dart';

class BotSetupScreen extends StatefulWidget {
  final String? initialBotName;

  const BotSetupScreen({super.key, this.initialBotName});

  @override
  State<BotSetupScreen> createState() => _BotSetupScreenState();
}

class _BotSetupScreenState extends State<BotSetupScreen> {
  final TextEditingController _botController = TextEditingController();
  final ApiService _apiService = ApiService();

  List<String> _vrmList = [];
  String? _selectedVrm;
  bool _isLoadingVrm = false;
  String? _vrmError;

  @override
  void initState() {
    super.initState();
    if (widget.initialBotName != null) {
      _botController.text = widget.initialBotName!;
    }
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
    final botName = _botController.text.trim();
    if (botName.isNotEmpty && _selectedVrm != null) {
      final finalUrl = AppConstants.buildAvatarUrl(id: botName, avatar: _selectedVrm!);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewScreen(url: finalUrl),
        ),
      );
    } else if (botName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Bot Name')),
      );
    } else if (_selectedVrm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an Avatar')),
      );
    }
  }

  @override
  void dispose() {
    _botController.dispose();
    super.dispose();
  }

  void _showAvatarSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Text(
                    'Select Avatar',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75, // Portrait card
                      ),
                      itemCount: _vrmList.length,
                      itemBuilder: (context, index) {
                        final vrm = _vrmList[index];
                        final isSelected = vrm == _selectedVrm;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedVrm = vrm;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                                    ),
                                    child: const Icon(Icons.person, color: Colors.grey, size: 40),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    vrm,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvatarSelector() {
    return GestureDetector(
      onTap: _showAvatarSelectionSheet,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person, color: Colors.grey, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Avatar',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedVrm ?? 'Select an avatar',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bot Setup'),
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
                    controller: _botController,
                    autofocus: false, // Prevent keyboard from popping up immediately on launch
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _navigateToWebView(),
                    decoration: InputDecoration(
                      hintText: 'Enter Bot Name...',
                      labelText: 'Bot',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _botController.clear(),
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
                    _buildAvatarSelector(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _navigateToWebView,
                    child: const Text('Start Chat'),
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
