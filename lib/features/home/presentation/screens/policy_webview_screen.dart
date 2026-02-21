import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PolicyWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const PolicyWebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<PolicyWebViewScreen> createState() => _PolicyWebViewScreenState();
}

class _PolicyWebViewScreenState extends State<PolicyWebViewScreen> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                setState(() {
                  _progress = progress;
                  _isLoading = progress < 100;
                });
              },
              onPageStarted: (_) {
                setState(() => _isLoading = true);
              },
              onPageFinished: (_) {
                setState(() => _isLoading = false);
              },
              onWebResourceError: (_) {
                setState(() => _isLoading = false);
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
  }

  Future<bool> _handleWillPop() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          backgroundColor: colors.surface,
          elevation: 0,
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: AnimatedOpacity(
              opacity: _isLoading ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: LinearProgressIndicator(
                value: _isLoading ? (_progress.clamp(0, 100) / 100) : 0,
                minHeight: 2,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
