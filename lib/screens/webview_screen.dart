import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Use the appropriate system UI mode setting method if needed.
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _requestPermissionsAndLoad();
  }

  @override
  void dispose() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _requestPermissionsAndLoad() async {
    // Request microphone and camera permissions upfront
    await [
      Permission.microphone,
      Permission.camera,
    ].request();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            // Inject JavaScript to disable scrolling
            _controller.runJavaScript('''
              document.body.style.overflow = 'hidden';
              document.documentElement.style.overflow = 'hidden';
              
              // For mobile devices to prevent drag/scroll
              document.body.style.touchAction = 'none';
              document.documentElement.style.touchAction = 'none';
            ''');
            
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..setOnJavaScriptAlertDialog(
        (JavaScriptAlertDialogRequest request) async {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Alert'),
              content: Text(request.message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
      );

    if (Platform.isAndroid) {
      final androidController =
          _controller.platform as AndroidWebViewController;
      await androidController.setMediaPlaybackRequiresUserGesture(false);
      await androidController.setOnPlatformPermissionRequest(
        (PlatformWebViewPermissionRequest request) {
          request.grant();
        },
      );
    } else if (Platform.isIOS) {
      final webKitController =
          _controller.platform as WebKitWebViewController;
      await webKitController.setAllowsBackForwardNavigationGestures(true);
    }

    await _controller.loadRequest(Uri.parse(widget.url));
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isInitialized
          ? Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                // Floating back button
                Positioned(
                  top: 40,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
