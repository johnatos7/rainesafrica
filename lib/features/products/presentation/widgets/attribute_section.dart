import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';

class AttributeSection extends StatelessWidget {
  final ProductEntity product;
  final Function(int variationId)? onVariationSelected;
  final int? selectedVariationId;

  const AttributeSection({
    Key? key,
    required this.product,
    this.onVariationSelected,
    this.selectedVariationId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (product.attributes == null || product.attributes!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          product.attributes!.map((attribute) {
            // Get variations that have values for this attribute
            final relevantVariations =
                product.variations?.where((variation) {
                  return variation.attributeValues?.any(
                        (value) => value.attributeId == attribute.id,
                      ) ??
                      false;
                }).toList();

            if (relevantVariations == null || relevantVariations.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Attribute name header
                  Text(
                    attribute.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Variation options
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        relevantVariations.map((variation) {
                          final attributeValue = variation.attributeValues
                              ?.firstWhere(
                                (value) => value.attributeId == attribute.id,
                              );

                          if (attributeValue == null) {
                            return const SizedBox.shrink();
                          }

                          final isSelected =
                              selectedVariationId == variation.id;

                          // For color attributes
                          if (attribute.name.toLowerCase() == 'colour' ||
                              attribute.name.toLowerCase() == 'color') {
                            return GestureDetector(
                              onTap:
                                  () =>
                                      onVariationSelected?.call(variation.id!),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      attributeValue.hexColor != null
                                          ? Color(
                                            int.parse(
                                              '0xFF${attributeValue.hexColor!.replaceAll('#', '')}',
                                            ),
                                          )
                                          : Colors.grey,
                                  border: Border.all(
                                    color:
                                        isSelected ? Colors.blue : Colors.grey,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child:
                                    isSelected
                                        ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                        : null,
                              ),
                            );
                          }

                          // For other attributes (size, material, etc.)
                          return ChoiceChip(
                            label: Text(attributeValue.value ?? ''),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              if (selected) {
                                onVariationSelected?.call(variation.id!);
                              }
                            },
                          );
                        }).toList(),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
