import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/legal/domain/entities/legal_document_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/legal/presentation/providers/legal_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/legal/presentation/screens/legal_document_detail_screen.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/l10n.dart';

/// Screen displaying a list of legal documents
class LegalDocumentsScreen extends ConsumerStatefulWidget {
  const LegalDocumentsScreen({super.key});

  @override
  ConsumerState<LegalDocumentsScreen> createState() =>
      _LegalDocumentsScreenState();
}

class _LegalDocumentsScreenState extends ConsumerState<LegalDocumentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('about_raines_africa')),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: FutureBuilder(
          future: _loadLegalDocuments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('error_loading_documents'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: Text(context.tr('try_again')),
                    ),
                  ],
                ),
              );
            }

            final documents = snapshot.data ?? <LegalDocumentEntity>[];

            if (documents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('no_documents_available'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document = documents[index];
                return _LegalDocumentCard(
                  document: document,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                LegalDocumentDetailScreen(document: document),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<LegalDocumentEntity>> _loadLegalDocuments() async {
    final repository = ref.read(legalRepositoryProvider);
    final result = await repository.getLegalDocuments();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (response) => response.data,
    );
  }
}

/// Card widget for displaying a legal document
class _LegalDocumentCard extends StatelessWidget {
  final LegalDocumentEntity document;
  final VoidCallback onTap;

  const _LegalDocumentCard({required this.document, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 0.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDocumentDescription(document.slug),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(document.updatedAt),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
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

  String _getDocumentDescription(String slug) {
    switch (slug) {
      case 'terms-and-conditions':
        return 'Read our terms and conditions for using our services';
      case 'return-policy':
        return 'Learn about our return and refund policy';
      case 'shipping-policy':
        return 'Information about shipping and delivery';
      case 'privacy-policy':
        return 'How we protect and use your personal information';
      default:
        return 'Important legal information';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
