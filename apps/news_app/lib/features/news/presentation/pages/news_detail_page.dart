import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart' as windows_webview;

import '../../../../core/models/news_item.dart';

class NewsDetailPage extends StatefulWidget {
  const NewsDetailPage({required this.item, super.key});

  final NewsItemModel item;

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  windows_webview.WebviewController? _windowsController;
  Object? _windowsError;

  late final WebViewController _mobileController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse(widget.item.url));

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      _initWindowsWebview();
    }
  }

  Future<void> _initWindowsWebview() async {
    try {
      final windows_webview.WebviewController controller =
          windows_webview.WebviewController();
      await controller.initialize();
      await controller.loadUrl(widget.item.url);
      if (!mounted) {
        return;
      }
      setState(() {
        _windowsController = controller;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _windowsError = error;
      });
    }
  }

  @override
  void dispose() {
    _windowsController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.title, maxLines: 1)),
      body: Platform.isWindows
          ? _buildWindowsWebview()
          : WebViewWidget(controller: _mobileController),
    );
  }

  Widget _buildWindowsWebview() {
    if (_windowsError != null) {
      return Center(child: Text('Windows WebView 初始化失败: $_windowsError'));
    }
    if (_windowsController == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return windows_webview.Webview(_windowsController!);
  }
}
