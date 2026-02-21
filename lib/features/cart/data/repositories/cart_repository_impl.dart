import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/network_info.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/data/models/cart_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/domain/entities/cart_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/product_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final CartLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CartRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      if (await networkInfo.isConnected) {
        final cartModel = await remoteDataSource.getCart();

        // Populate cart items with product data from local storage
        final populatedCartModel = await _populateCartWithProducts(cartModel);

        // Save to local storage for offline access
        await localDataSource.saveCart(populatedCartModel);

        return Right(populatedCartModel.toEntity());
      } else {
        // Return local cart when offline
        final localCart = await localDataSource.getCart();
        if (localCart != null) {
          // Populate with local product data
          final populatedCartModel = await _populateCartWithProducts(localCart);
          return Right(populatedCartModel.toEntity());
        } else {
          return Left(CacheFailure(message: 'No cart found in local storage'));
        }
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get cart: $e'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> createCart() async {
    try {
      if (await networkInfo.isConnected) {
        final cartModel = await remoteDataSource.createCart();
        final cartEntity = cartModel.toEntity();

        // Save to local storage
        await localDataSource.saveCart(cartModel);

        return Right(cartEntity);
      } else {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create cart: $e'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateCart(CartEntity cart) async {
    try {
      if (await networkInfo.isConnected) {
        // Convert entity to model for API call
        final cartModel = CartModel(
          id: cart.id,
          items:
              cart.items
                  .map(
                    (item) => CartItemModel(
                      id: item.id,
                      cartId: item.cartId,
                      product: null, // Will be populated by API
                      quantity: item.quantity,
                      unitPrice: item.unitPrice,
                      totalPrice: item.totalPrice,
                      selectedVariation: item.selectedVariation,
                      selectedAttributes: item.selectedAttributes,
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

        final updatedCartModel = await remoteDataSource.updateCart(cartModel);
        final updatedCartEntity = updatedCartModel.toEntity();

        // Save to local storage
        await localDataSource.saveCart(updatedCartModel);

        return Right(updatedCartEntity);
      } else {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update cart: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.clearCart();
      }

      // Always clear local storage
      await localDataSource.clearCart();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to clear cart: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCart() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteCart();
      }

      // Always clear local storage
      await localDataSource.clearCart();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete cart: $e'));
    }
  }

  @override
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
      if (await networkInfo.isConnected) {
        final cartItemModel = await remoteDataSource.addToCart(
          productId: productId,
          quantity: quantity,
          selectedAttributes: selectedAttributes,
          selectedAttributeIds: selectedAttributeIds,
          variationDisplayName: variationDisplayName,
        );

        final cartItemEntity = cartItemModel.toEntity();

        // Save to local storage
        await localDataSource.saveCartItem(cartItemModel);

        return Right(cartItemEntity);
      } else {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add to cart: $e'));
    }
  }

  @override
  Future<Either<Failure, CartItemEntity>> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final cartItemModel = await remoteDataSource.updateCartItem(
          itemId: itemId,
          quantity: quantity,
        );

        final cartItemEntity = cartItemModel.toEntity();

        // Update local storage
        await localDataSource.saveCartItem(cartItemModel);

        return Right(cartItemEntity);
      } else {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update cart item: $e'));
    }
  }

  @override
  Future<Either<Failure, CartItemEntity>> updateCartItemShipping({
    required String itemId,
    required String? shippingMethod,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final cartItemModel = await remoteDataSource.updateCartItemShipping(
          itemId: itemId,
          shippingMethod: shippingMethod,
        );

        final cartItemEntity = cartItemModel.toEntity();

        // Update local storage
        await localDataSource.saveCartItem(cartItemModel);

        return Right(cartItemEntity);
      } else {
        // Update local storage when offline
        await localDataSource.updateCartItemShipping(
          itemId: itemId,
          shippingMethod: shippingMethod,
        );

        // Get the updated item from local storage
        final items = await localDataSource.getCartItems();
        final updatedItem = items.firstWhere(
          (item) => item.id == itemId,
          orElse: () => throw Exception('Cart item not found'),
        );

        return Right(updatedItem.toEntity());
      }
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to update cart item shipping: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String itemId) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.removeFromCart(itemId);
      }

      // Always remove from local storage
      await localDataSource.removeCartItem(itemId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to remove from cart: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeAllFromCart(int productId) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.removeAllFromCart(productId);
      }

      // Remove from local storage
      final items = await localDataSource.getCartItems();
      for (final item in items) {
        if (item.product?.id == productId) {
          await localDataSource.removeCartItem(item.id ?? '');
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to remove all from cart: $e'));
    }
  }

  @override
  Future<Either<Failure, CartSummaryEntity>> getCartSummary() async {
    try {
      if (await networkInfo.isConnected) {
        final cartSummaryModel = await remoteDataSource.getCartSummary();
        return Right(cartSummaryModel.toEntity());
      } else {
        // Calculate summary from local cart
        final localCart = await localDataSource.getCart();
        if (localCart != null) {
          final cartEntity = localCart.toEntity();
          final summary = CartSummaryEntity(
            totalItems: cartEntity.itemCount,
            subtotal: cartEntity.calculatedSubtotal,
            tax: cartEntity.tax,
            shipping: cartEntity.shipping,
            discount: cartEntity.discount,
            expeditedShippingFee: cartEntity.calculatedExpeditedShippingFee,
            total: cartEntity.calculatedTotal,
            currency: cartEntity.currency,
          );
          return Right(summary);
        } else {
          return Left(CacheFailure(message: 'No cart found in local storage'));
        }
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get cart summary: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> calculateShipping({
    required String address,
    required String city,
    required String postalCode,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final shippingCost = await remoteDataSource.calculateShipping(
          address: address,
          city: city,
          postalCode: postalCode,
        );
        return Right(shippingCost);
      } else {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to calculate shipping: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateCart() async {
    try {
      if (await networkInfo.isConnected) {
        final isValid = await remoteDataSource.validateCart();
        return Right(isValid);
      } else {
        // Basic local validation
        final localCart = await localDataSource.getCart();
        if (localCart != null && localCart.items?.isNotEmpty == true) {
          return const Right(true);
        } else {
          return const Right(false);
        }
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to validate cart: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCartValidationErrors() async {
    try {
      if (await networkInfo.isConnected) {
        final errors = await remoteDataSource.getCartValidationErrors();
        return Right(errors);
      } else {
        return const Right([]);
      }
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to get cart validation errors: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> checkItemStock({
    required int productId,
    required int quantity,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final isInStock = await remoteDataSource.checkItemStock(
          productId: productId,
          quantity: quantity,
        );
        return Right(isInStock);
      } else {
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to check item stock: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveCartToLocal(CartEntity cart) async {
    try {
      final cartModel = CartModel(
        id: cart.id,
        items:
            cart.items
                .map(
                  (item) => CartItemModel(
                    id: item.id,
                    cartId: item.cartId,
                    product: null, // Will be populated separately
                    quantity: item.quantity,
                    unitPrice: item.unitPrice,
                    totalPrice: item.totalPrice,
                    selectedVariation: item.selectedVariation,
                    selectedAttributes: item.selectedAttributes,
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

      await localDataSource.saveCart(cartModel);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to save cart to local storage: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, CartEntity?>> getCartFromLocal() async {
    try {
      final localCart = await localDataSource.getCart();
      if (localCart != null) {
        return Right(localCart.toEntity());
      } else {
        return const Right(null);
      }
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to get cart from local storage: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearLocalCart() async {
    try {
      await localDataSource.clearCart();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to clear local cart: $e'));
    }
  }

  /// Helper method to populate cart items with product data from local storage
  Future<CartModel> _populateCartWithProducts(CartModel cartModel) async {
    if (cartModel.items == null) return cartModel;

    final populatedItems = <CartItemModel>[];

    for (final item in cartModel.items!) {
      // If item already has product data, keep it
      if (item.product != null) {
        populatedItems.add(item);
        continue;
      }

      // Try to get product data from local storage
      // We need to determine the product ID from the item
      // This is a limitation - we need the product ID to be stored in the cart item
      // For now, we'll create a basic product model with available data
      final populatedItem = CartItemModel(
        id: item.id,
        cartId: item.cartId,
        product: await _getProductForCartItem(item),
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        totalPrice: item.totalPrice,
        selectedVariation: item.selectedVariation,
        selectedAttributes: item.selectedAttributes,
        addedAt: item.addedAt,
        updatedAt: item.updatedAt,
      );

      populatedItems.add(populatedItem);
    }

    return CartModel(
      id: cartModel.id,
      items: populatedItems,
      subtotal: cartModel.subtotal,
      tax: cartModel.tax,
      shipping: cartModel.shipping,
      discount: cartModel.discount,
      total: cartModel.total,
      currency: cartModel.currency,
      createdAt: cartModel.createdAt,
      updatedAt: cartModel.updatedAt,
    );
  }

  /// Helper method to get or create product data for a cart item
  Future<ProductModel?> _getProductForCartItem(CartItemModel item) async {
    // Try to get product from local storage using productId
    if (item.productId != null) {
      try {
        final product = await localDataSource.getProduct(item.productId!);
        if (product != null) {
          return product;
        }
      } catch (e) {
        // Log error but don't fail the cart operation
        // TODO: Use proper logging instead of print
        // print('Failed to get product ${item.productId} from local storage: $e');
      }
    }

    // If no product found in local storage, return null
    // The cart item widget will handle null products with a fallback UI
    return null;
  }
}
