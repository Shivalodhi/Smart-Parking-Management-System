import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ViewUrl extends StatefulWidget {
  const ViewUrl({super.key});

  @override
  State<ViewUrl> createState() => _ViewUrlState();
}

class _ViewUrlState extends State<ViewUrl> {
  WebViewController? _controller; // Nullable WebViewController

  @override
  void initState() {
    super.initState();
    // Check if it's running on Android or iOS (exclude web)
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadFlutterAsset('assets/map.html');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle WebView on mobile platforms (Android/iOS)
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      if (_controller != null) {
        // Render WebView only if controller is initialize
        return WebViewWidget(controller: _controller!); // Map will be displayed here
      } else {
        // Show a loading indicator while the controller is initializing
        return const Center(child: CircularProgressIndicator());
      }
    } else {
      // For web (or unsupported platforms), display an error message
      return Center(
        child: Text("WebView is not supported on this platform."),
      );
    }
  }
}
