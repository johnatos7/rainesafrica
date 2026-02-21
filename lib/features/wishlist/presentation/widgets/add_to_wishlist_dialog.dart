import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/providers/wishlist_providers.dart';

class AddToWishlistDialog extends ConsumerStatefulWidget {
  final dynamic product;

  const AddToWishlistDialog({super.key, required this.product});

  @override
  ConsumerState<AddToWishlistDialog> createState() =>
      _AddToWishlistDialogState();
}

class _AddToWishlistDialogState extends ConsumerState<AddToWishlistDialog> {
  String? _selectedWishlistId;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wishlistsAsync = ref.watch(wishlistsProvider);

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        // Add padding for bottom keyboard
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          const Text(
            'Add to Wishlist',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          // Content
          wishlistsAsync.when(
            data: (wishlists) {
              if (wishlists.isEmpty) {
                return const Text(
                  'No wishlists available. Please create a wishlist first.',
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Wishlist selection
                  DropdownButtonFormField<String>(
                    value: _selectedWishlistId,
                    decoration: const InputDecoration(
                      labelText: 'Select Wishlist',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        wishlists
                            .map(
                              (wishlist) => DropdownMenuItem(
                                value: wishlist.id,
                                child: Container(
                                  width:
                                      200, // Fixed width for the dropdown item
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          wishlist.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (wishlist.isDefault) ...[
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.star,
                                          size: 16,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWishlistId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a wishlist';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Notes field
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'Add a note about this item',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              );
            },
            loading:
                () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                ),
            error:
                (error, stackTrace) => Text('Error loading wishlists: $error'),
          ),
          const SizedBox(height: 24),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addToWishlist,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text('Add'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addToWishlist() async {
    if (_selectedWishlistId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a wishlist'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(
        addToWishlistProvider((
          wishlistId: _selectedWishlistId!,
          product: widget.product,
          notes:
              _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
        )).future,
      );

      ref.invalidate(isProductInWishlistProvider(widget.product.id.toString()));
      ref.invalidate(wishlistsProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to wishlist successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to wishlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
