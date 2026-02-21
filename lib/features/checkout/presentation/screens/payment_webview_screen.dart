import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String initialUrl;
  final int? orderNumber;
  final String?
  successPathPrefix; // e.g. "/en/account/order" or any path under raines.africa

  const PaymentWebViewScreen({
    super.key,
    required this.initialUrl,
    this.orderNumber,
    this.successPathPrefix,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
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
              onPageStarted: (url) {
                setState(() {
                  _isLoading = true;
                });
              },
              onPageFinished: (url) {
                setState(() {
                  _isLoading = false;
                });
              },
              onNavigationRequest: (request) {
                final uri = Uri.parse(request.url);
                final host = uri.host.toLowerCase();
                if (host == 'raines.africa') {
                  final path = uri.path;
                  final prefix = widget.successPathPrefix;
                  // If specific success path is required, ensure it matches; otherwise accept any path on raines.africa
                  final matchesPrefix =
                      prefix == null || path.startsWith(prefix);
                  if (matchesPrefix) {
                    _handleSuccessRedirect(uri);
                    return NavigationDecision.prevent;
                  }
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.initialUrl));
  }

  void _handleSuccessRedirect(Uri uri) {
    // Prefer going to order details if we have orderNumber, otherwise orders list
    if (!mounted) return;
    if (widget.orderNumber != null) {
      // Navigate to native order details route
      context.go('/orders/${widget.orderNumber}');
    } else {
      context.go('/orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
