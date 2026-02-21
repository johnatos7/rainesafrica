import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';

/// WebView screen for layby payment via PayFast
class LaybyPaymentWebViewScreen extends StatefulWidget {
  final String initialUrl;
  final int applicationId;

  const LaybyPaymentWebViewScreen({
    super.key,
    required this.initialUrl,
    required this.applicationId,
  });

  @override
  State<LaybyPaymentWebViewScreen> createState() =>
      _LaybyPaymentWebViewScreenState();
}

class _LaybyPaymentWebViewScreenState extends State<LaybyPaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (_) => setState(() => _isLoading = true),
              onPageFinished: (_) => setState(() => _isLoading = false),
              onNavigationRequest: (request) {
                final uri = Uri.parse(request.url);
                final host = uri.host.toLowerCase();
                // When redirected back to raines.africa, payment is done
                if (host == 'raines.africa' || host == 'www.raines.africa') {
                  _handlePaymentComplete();
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.initialUrl));
  }

  void _handlePaymentComplete() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment completed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    context.go('/layby/${widget.applicationId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
