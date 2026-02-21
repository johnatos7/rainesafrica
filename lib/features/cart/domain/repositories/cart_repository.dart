import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/domain/entities/cart_entity.dart';
import 'package:dartz/dartz.dart';

abstract class CartRepository {
  // Cart operations
  Future<Either<Failure, CartEntity>> getCart();
  Future<Either<Failure, CartEntity>> createCart();
  Future<Either<Failure, CartEntity>> updateCart(CartEntity cart);
  Future<Either<Failure, void>> clearCart();
  Future<Either<Failure, void>> deleteCart();

  // Cart item operations
  Future<Either<Failure, CartItemEntity>> addToCart({
    required int productId,
    required int quantity,
    int? selectedVariationId,
    String? selectedVariation,
    Map<String, String>? selectedAttributes,
    List<int>? selectedAttributeIds,
    String? variationDisplayName,
  });

  Future<Either<Failure, CartItemEntity>> updateCartItem({
    required String itemId,
    required int quantity,
  });

  Future<Either<Failure, CartItemEntity>> updateCartItemShipping({
    required String itemId,
    required String? shippingMethod,
  });

  Future<Either<Failure, void>> removeFromCart(String itemId);
  Future<Either<Failure, void>> removeAllFromCart(int productId);

  // Cart summary and calculations
  Future<Either<Failure, CartSummaryEntity>> getCartSummary();
  Future<Either<Failure, double>> calculateShipping({
    required String address,
    required String city,
    required String postalCode,
  });

  // Cart validation
  Future<Either<Failure, bool>> validateCart();
  Future<Either<Failure, List<String>>> getCartValidationErrors();

  // Stock checking
  Future<Either<Failure, bool>> checkItemStock({
    required int productId,
    required int quantity,
  });

  // Local storage operations
  Future<Either<Failure, void>> saveCartToLocal(CartEntity cart);
  Future<Either<Failure, CartEntity?>> getCartFromLocal();
  Future<Either<Failure, void>> clearLocalCart();
}
