import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/legal/domain/entities/legal_document_entity.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/l10n.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;

/// Screen displaying the detailed content of a legal document
class LegalDocumentDetailScreen extends ConsumerWidget {
  final LegalDocumentEntity document;

  const LegalDocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.title, style: const TextStyle(fontSize: 18)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareDocument(context),
            tooltip: context.tr('share'),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document header
              _DocumentHeader(document: document),

              const SizedBox(height: 24),

              // Document content
              _DocumentContent(content: document.content),

              const SizedBox(height: 32),

              // Document footer
              _DocumentFooter(document: document),
            ],
          ),
        ),
      ),
    );
  }

  void _shareDocument(BuildContext context) {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('share_functionality_coming_soon'))),
    );
  }
}

/// Header widget for the document
class _DocumentHeader extends StatelessWidget {
  final LegalDocumentEntity document;

  const _DocumentHeader({required this.document});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getDocumentIcon(document.slug),
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDocumentType(document.slug),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${context.tr('last_updated')}: ${_formatDate(document.updatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon(String slug) {
    switch (slug) {
      case 'terms-and-conditions':
        return Icons.description;
      case 'return-policy':
        return Icons.assignment_return;
      case 'shipping-policy':
        return Icons.local_shipping;
      case 'privacy-policy':
        return Icons.privacy_tip;
      default:
        return Icons.description;
    }
  }

  String _getDocumentType(String slug) {
    switch (slug) {
      case 'terms-and-conditions':
        return 'Terms and Conditions';
      case 'return-policy':
        return 'Return Policy';
      case 'shipping-policy':
        return 'Shipping Policy';
      case 'privacy-policy':
        return 'Privacy Policy';
      default:
        return 'Legal Document';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Content widget for the document
class _DocumentContent extends StatelessWidget {
  final String content;

  const _DocumentContent({required this.content});

  @override
  Widget build(BuildContext context) {
    final parsedContent = _parseHtmlContent(content);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('document_content'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...parsedContent.map(
            (widget) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: widget,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _parseHtmlContent(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    final List<Widget> widgets = [];

    void processNode(html_dom.Node node) {
      if (node is html_dom.Element) {
        switch (node.localName) {
          case 'p':
            widgets.add(
              Text(
                node.text,
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
            );
            break;
          case 'strong':
            widgets.add(
              Text(
                node.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                ),
              ),
            );
            break;
          case 'br':
            widgets.add(const SizedBox(height: 8));
            break;
          default:
            // Process child nodes
            for (final child in node.nodes) {
              processNode(child);
            }
            break;
        }
      } else if (node is html_dom.Text) {
        final text = node.text.trim();
        if (text.isNotEmpty) {
          widgets.add(
            Text(text, style: const TextStyle(fontSize: 16, height: 1.6)),
          );
        }
      }
    }

    // Process all nodes in the document body
    for (final node in document.body?.nodes ?? []) {
      processNode(node);
    }

    return widgets;
  }
}

/// Footer widget for the document
class _DocumentFooter extends StatelessWidget {
  final LegalDocumentEntity document;

  const _DocumentFooter({required this.document});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                context.tr('document_info'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: context.tr('document_id'),
            value: document.id.toString(),
          ),
          _InfoRow(
            label: context.tr('created_date'),
            value: _formatDate(document.createdAt),
          ),
          _InfoRow(
            label: context.tr('last_updated'),
            value: _formatDate(document.updatedAt),
          ),
          if (document.createdBy != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${context.tr('created_by')}: ${document.createdBy!.name}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Info row widget for displaying key-value pairs
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
