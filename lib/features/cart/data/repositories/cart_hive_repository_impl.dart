import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/data/datasources/cart_hive_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/data/models/cart_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/domain/entities/cart_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/product_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/repositories/product_repository.dart';

class CartHiveRepositoryImpl implements CartRepository {
  final CartHiveDataSource hiveDataSource;
  final ProductRepository productRepository;

  CartHiveRepositoryImpl({
    required this.hiveDataSource,
    required this.productRepository,
  });

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      print('CartHiveRepository: Getting cart items...');
      // Get cart items from Hive
      final cartItems = await hiveDataSource.getCartItems();
      print('CartHiveRepository: Found ${cartItems.length} cart items');

      if (cartItems.isEmpty) {
        // Return empty cart
        return Right(
          CartEntity(
            id: 'empty',
            items: [],
            subtotal: 0.0,
            tax: 0.0,
            shipping: 0.0,
            discount: 0.0,
            total: 0.0,
            currency: 'ZAR',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }

      // Build cart from items
      final cartItemsWithProducts = <CartItemModel>[];
      for (final item in cartItems) {
        print(
          'CartHiveRepository: Processing cart item ${item.id}, product: ${item.product?.name ?? 'null'}, productId: ${item.productId}',
        );

        // Populate product data if missing
        if (item.product == null && item.productId != null) {
          print(
            'CartHiveRepository: Product data missing, fetching from Hive...',
          );
          final product = await hiveDataSource.getProduct(item.productId!);
          if (product != null) {
            print('CartHiveRepository: Found product in Hive: ${product.name}');
            cartItemsWithProducts.add(
              CartItemModel(
                id: item.id,
                cartId: item.cartId,
                productId: item.productId,
                product: product,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                totalPrice: item.totalPrice,
                selectedVariation: item.selectedVariation,
                selectedAttributes: item.selectedAttributes,
                itemShippingMethod: item.itemShippingMethod,
                addedAt: item.addedAt,
                updatedAt: item.updatedAt,
              ),
            );
          } else {
            print(
              'CartHiveRepository: Product not found in Hive, keeping original item',
            );
            cartItemsWithProducts.add(item);
          }
        } else {
          print(
            'CartHiveRepository: Product data already present: ${item.product?.name ?? 'null'}',
          );
          cartItemsWithProducts.add(item);
        }
      }

      // Calculate totals
      double subtotal = 0.0;
      for (final item in cartItemsWithProducts) {
        subtotal += item.totalPrice ?? 0;
      }

      const tax = 0.15; // 15% VAT
      const shipping = 0.0; // Free shipping for now
      const discount = 0.0;
      final total = subtotal + (subtotal * tax) + shipping - discount;

      // Create cart entity
      final cartEntity = CartEntity(
        id: 'cart_1', // Default cart ID
        items: cartItemsWithProducts.map((item) => item.toEntity()).toList(),
        subtotal: subtotal,
        tax: subtotal * tax,
        shipping: shipping,
        discount: discount,
        total: total,
        currency: 'ZAR',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print(
        'CartHiveRepository: Built cart with ${cartEntity.items.length} items',
      );
      return Right(cartEntity);
    } catch (e) {
      print('CartHiveRepository: Error getting cart: $e');
      return Left(CacheFailure(message: 'Failed to get cart from Hive: $e'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> createCart() async {
    try {
      final emptyCart = CartModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        items: [],
        subtotal: 0.0,
        tax: 0.0,
        shipping: 0.0,
        discount: 0.0,
        total: 0.0,
        currency: 'ZAR',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await hiveDataSource.saveCart(emptyCart);
      return Right(emptyCart.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to create cart in Hive: $e'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateCart(CartEntity cart) async {
    try {
      final cartModel = CartModel(
        id: cart.id,
        items:
            cart.items
                .map(
                  (item) => CartItemModel(
                    id: item.id,
                    cartId: item.cartId,
                    productId: item.productId,
                    product:
                        item.product != null
                            ? ProductModel.fromEntity(item.product!)
                            : null,
                    quantity: item.quantity,
                    unitPrice: item.unitPrice,
                    totalPrice: item.totalPrice,
                    selectedVariation: item.selectedVariation,
                    selectedAttributes: item.selectedAttributes,
                    itemShippingMethod: item.itemShippingMethod,
                    addedAt: item.addedAt,
                    updatedAt: item.updatedAt,
                  ),
                )
                .toList(),
        subtotal: cart.subtotal,
        tax: cart.tax,
        shipping: cart.shipping,
        discount: cart.discount,
        total: cart.total,
        currency: cart.currency,
        createdAt: cart.createdAt,
        updatedAt: cart.updatedAt,
      );

      await hiveDataSource.saveCart(cartModel);
      return Right(cart);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update cart in Hive: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await hiveDataSource.clearCart();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to clear cart in Hive: $e'));
    }
  }

  @override
  Future<Either<Failure, CartItemEntity>> addToCart({
    required int productId,
    required int quantity,
    int? selectedVariationId,
    String? selectedVariation,
    Map<String, String>? selectedAttributes,
    List<int>? selectedAttributeIds,
    String? variationDisplayName,
  }) async {
    try {
      print('CartHiveRepository: Adding product $productId to cart...');

      // First try to get product from Hive
      ProductModel? product = await hiveDataSource.getProduct(productId);

      // If product doesn't exist in Hive, fetch from API
      if (product == null) {
        print('CartHiveRepository: Product not in Hive, fetching from API...');

        // Fetch product from API
        final productResult = await productRepository.getProductById(productId);

        if (productResult.isRight()) {
          final productEntity = productResult.getOrElse(
            () => throw Exception('Failed to get product'),
          );
          product = ProductModel.fromEntity(productEntity);

          // Save the product to Hive for future use
          await hiveDataSource.saveProduct(product);
          print(
            'CartHiveRepository: Fetched and saved product from API: ${product.name}',
          );
        } else {
          print('CartHiveRepository: Failed to fetch product from API');
          return Left(ServerFailure(message: 'Product not found'));
        }
      } else {
        print('CartHiveRepository: Found product in Hive: ${product.name}');
      }

      // Product should never be null at this point since we create it if it doesn't exist

      // Calculate effective price — prefer variation price when a variation is selected
      double effectivePrice;
      if (selectedVariationId != null && product.variations != null) {
        // Find the matching variation by ID
        final matchingVariations = product.variations!.where(
          (v) => v.id == selectedVariationId,
        );
        if (matchingVariations.isNotEmpty) {
          final variation = matchingVariations.first;
          // Use the variation's sale price if available, otherwise its regular price
          if (variation.salePrice != null && variation.salePrice! > 0) {
            effectivePrice = variation.salePrice!;
          } else {
            effectivePrice = variation.price ?? product.price ?? 0.0;
          }
          print(
            'CartHiveRepository: Using VARIATION price for variation $selectedVariationId: $effectivePrice',
          );
        } else {
          // Variation ID provided but not found in product — fall back to base price
          effectivePrice =
              (product.isSaleEnable == 1 &&
                      product.salePrice != null &&
                      product.salePrice! > 0)
                  ? product.salePrice!
                  : (product.price ?? 0.0);
          print(
            'CartHiveRepository: Variation $selectedVariationId not found, using BASE price: $effectivePrice',
          );
        }
      } else {
        // No variation — use base product price
        effectivePrice =
            (product.isSaleEnable == 1 &&
                    product.salePrice != null &&
                    product.salePrice! > 0)
                ? product.salePrice!
                : (product.price ?? 0.0);
        print('CartHiveRepository: Using BASE product price: $effectivePrice');
      }

      // Create cart item
      final cartItem = CartItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cartId: 'cart_1', // Default cart ID
        productId: productId,
        product: product,
        quantity: quantity,
        unitPrice: effectivePrice,
        totalPrice: effectivePrice * quantity,
        selectedVariationId: selectedVariationId,
        selectedVariation: selectedVariation,
        selectedAttributes: selectedAttributes,
        selectedAttributeIds: selectedAttributeIds,
        variationDisplayName: variationDisplayName,
        itemShippingMethod: null, // Default to standard shipping
        addedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save cart item
      await hiveDataSource.saveCartItem(cartItem);
      print('CartHiveRepository: Successfully added product to cart');

      return Right(cartItem.toEntity());
    } catch (e) {
      print('CartHiveRepository: Error adding to cart: $e');
      return Left(CacheFailure(message: 'Failed to add to cart in Hive: $e'));
    }
  }

  @override
  Future<Either<Failure, CartItemEntity>> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    try {
      final items = await hiveDataSource.getCartItems();
      final itemIndex = items.indexWhere((item) => item.id == itemId);

      if (itemIndex == -1) {
        return Left(CacheFailure(message: 'Cart item not found'));
      }

      final item = items[itemIndex];
      final updatedItem = CartItemModel(
        id: item.id,
        cartId: item.cartId,
        productId: item.productId,
        product: item.product,
        quantity: quantity,
        unitPrice: item.unitPrice,
        totalPrice: (item.unitPrice ?? 0) * quantity,
        selectedVariation: item.selectedVariation,
        selectedAttributes: item.selectedAttributes,
        itemShippingMethod: item.itemShippingMethod,
        addedAt: item.addedAt,
        updatedAt: DateTime.now(),
      );

      items[itemIndex] = updatedItem;

      // Save updated items
      for (final cartItem in items) {
        await hiveDataSource.saveCartItem(cartItem);
      }

      return Right(updatedItem.toEntity());
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to update cart item in Hive: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, CartItemEntity>> updateCartItemShipping({
    required String itemId,
    required String? shippingMethod,
  }) async {
    try {
      final items = await hiveDataSource.getCartItems();
      final itemIndex = items.indexWhere((item) => item.id == itemId);

      if (itemIndex == -1) {
        return Left(CacheFailure(message: 'Cart item not found'));
      }

      final item = items[itemIndex];
      final updatedItem = CartItemModel(
        id: item.id,
        cartId: item.cartId,
        productId: item.productId,
        product: item.product,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        totalPrice: item.totalPrice,
        selectedVariation: item.selectedVariation,
        selectedAttributes: item.selectedAttributes,
        itemShippingMethod: shippingMethod,
        addedAt: item.addedAt,
        updatedAt: DateTime.now(),
      );

      items[itemIndex] = updatedItem;

      // Save updated items
      for (final cartItem in items) {
        await hiveDataSource.saveCartItem(cartItem);
      }

      return Right(updatedItem.toEntity());
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Failed to update cart item shipping in Hive: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String itemId) async {
    try {
      await hiveDataSource.removeCartItem(itemId);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to remove from cart in Hive: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeAllFromCart(int productId) async {
    try {
      final items = await hiveDataSource.getCartItems();
      final filteredItems =
          items.where((item) => item.productId != productId).toList();

      // Clear and re-save filtered items
      await hiveDataSource.clearCart();
      for (final item in filteredItems) {
        await hiveDataSource.saveCartItem(item);
      }

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to remove all from cart in Hive: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, CartSummaryEntity>> getCartSummary() async {
    try {
      final items = await hiveDataSource.getCartItems();

      double subtotal = 0.0;
      for (final item in items) {
        subtotal += item.totalPrice ?? 0;
      }

      const tax = 0.00;
      const shipping = 0.0;
      const discount = 0.0;

      // Calculate expedited shipping fee
      double expeditedShippingFee = 0.0;
      for (final item in items) {
        if (item.itemShippingMethod == 'expedited' && item.product != null) {
          final expeditedPrice =
              item.product!.shippingOptions?.expeditedShippingPrice ?? 0.0;
          expeditedShippingFee +=
              expeditedPrice * (item.quantity?.toDouble() ?? 0.0);
        }
      }

      final total =
          subtotal +
          (subtotal * tax) +
          shipping +
          expeditedShippingFee -
          discount;

      final summary = CartSummaryEntity(
        totalItems: items.length,
        subtotal: subtotal,
        tax: subtotal * tax,
        shipping: shipping,
        discount: discount,
        expeditedShippingFee: expeditedShippingFee,
        total: total,
        currency: 'ZAR',
      );

      return Right(summary);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to get cart summary from Hive: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, double>> calculateShipping({
    required String address,
    required String city,
    required String postalCode,
  }) async {
    // Simple shipping calculation
    return const Right(50.0);
  }

  @override
  Future<Either<Failure, bool>> validateCart() async {
    try {
      final items = await hiveDataSource.getCartItems();
      return Right(items.isNotEmpty);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to validate cart in Hive: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCartValidationErrors() async {
    try {
      final items = await hiveDataSource.getCartItems();
      final errors = <String>[];

      for (final item in items) {
        if ((item.quantity ?? 0) <= 0) {
          errors.add('Invalid quantity for item ${item.id}');
        }
        if (item.unitPrice == null || item.unitPrice! <= 0) {
          errors.add('Invalid price for item ${item.id}');
        }
      }

      return Right(errors);
    } catch (e) {
      return Left(
        CacheFailure(
          message: 'Failed to get cart validation errors from Hive: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> checkItemStock({
    required int productId,
    required int quantity,
  }) async {
    try {
      final product = await hiveDataSource.getProduct(productId);
      if (product == null) {
        return Right(false);
      }

      return Right((product.quantity ?? 0) >= quantity);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to check item stock in Hive: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteCart() async {
    try {
      await hiveDataSource.clearCart();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete cart in Hive: $e'));
    }
  }

  Future<Either<Failure, CartEntity?>> getLocalCart() async {
    return getCart();
  }

  @override
  Future<Either<Failure, void>> clearLocalCart() async {
    return clearCart();
  }

  @override
  Future<Either<Failure, void>> saveCartToLocal(CartEntity cart) async {
    return updateCart(cart);
  }

  @override
  Future<Either<Failure, CartEntity?>> getCartFromLocal() async {
    return getCart();
  }
}
