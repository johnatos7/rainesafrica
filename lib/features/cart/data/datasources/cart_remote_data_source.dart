import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/data/models/cart_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';


abstract class CartRemoteDataSource {
  Future<CartModel> getCart();
  Future<CartModel> createCart();
  Future<CartModel> updateCart(CartModel cart);
  Future<void> clearCart();
  Future<void> deleteCart();

  Future<CartItemModel> addToCart({
    required int productId,
    required int quantity,
    List<ProductVariationEntity>? selectedVariations,
    Map<String, String>? selectedAttributes,
    List<int>? selectedAttributeIds,
    String? variationDisplayName,
  });

  Future<CartItemModel> updateCartItem({
    required String itemId,
    required int quantity,
  });

  Future<CartItemModel> updateCartItemShipping({
    required String itemId,
    required String? shippingMethod,
  });

  Future<void> removeFromCart(String itemId);
  Future<void> removeAllFromCart(int productId);

  Future<CartSummaryModel> getCartSummary();
  Future<double> calculateShipping({
    required String address,
    required String city,
    required String postalCode,
  });

  Future<bool> validateCart();
  Future<List<String>> getCartValidationErrors();
  Future<bool> checkItemStock({required int productId, required int quantity});
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient apiClient;

  CartRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<CartModel> getCart() async {
    try {
      final response = await apiClient.get('/cart');
      return CartModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get cart: $e');
    }
  }

  @override
  Future<CartModel> createCart() async {
    try {
      final response = await apiClient.post('/cart');
      return CartModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create cart: $e');
    }
  }

  @override
  Future<CartModel> updateCart(CartModel cart) async {
    try {
      final response = await apiClient.put('/cart', data: cart.toJson());
      return CartModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update cart: $e');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await apiClient.delete('/cart/items');
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  @override
  Future<void> deleteCart() async {
    try {
      await apiClient.delete('/cart');
    } catch (e) {
      throw Exception('Failed to delete cart: $e');
    }
  }

  @override
  Future<CartItemModel> addToCart({
    required int productId,
    required int quantity,
    List<ProductVariationEntity>? selectedVariations,
    Map<String, String>? selectedAttributes,
    List<int>? selectedAttributeIds,
    String? variationDisplayName,
  }) async {
    try {
      final response = await apiClient.post(
        '/cart/items',
        data: {
          'product_id': productId,
          'quantity': quantity,
          'selected_variations': selectedVariations,
          'selected_attributes': selectedAttributes,
          'selected_attribute_ids': selectedAttributeIds,
          'variation_display_name': variationDisplayName,
        },
      );
      return CartItemModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  @override
  Future<CartItemModel> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    try {
      final response = await apiClient.put(
        '/cart/items/$itemId',
        data: {'quantity': quantity},
      );
      return CartItemModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  @override
  Future<CartItemModel> updateCartItemShipping({
    required String itemId,
    required String? shippingMethod,
  }) async {
    try {
      final response = await apiClient.put(
        '/cart/items/$itemId/shipping',
        data: {'shipping_method': shippingMethod},
      );
      return CartItemModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update cart item shipping: $e');
    }
  }

  @override
  Future<void> removeFromCart(String itemId) async {
    try {
      await apiClient.delete('/cart/items/$itemId');
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }

  @override
  Future<void> removeAllFromCart(int productId) async {
    try {
      await apiClient.delete('/cart/items/product/$productId');
    } catch (e) {
      throw Exception('Failed to remove all from cart: $e');
    }
  }

  @override
  Future<CartSummaryModel> getCartSummary() async {
    try {
      final response = await apiClient.get('/cart/summary');
      return CartSummaryModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get cart summary: $e');
    }
  }

  @override
  Future<double> calculateShipping({
    required String address,
    required String city,
    required String postalCode,
  }) async {
    try {
      final response = await apiClient.post(
        '/cart/shipping',
        data: {'address': address, 'city': city, 'postal_code': postalCode},
      );
      return (response.data['shipping_cost'] as num).toDouble();
    } catch (e) {
      throw Exception('Failed to calculate shipping: $e');
    }
  }

  @override
  Future<bool> validateCart() async {
    try {
      final response = await apiClient.get('/cart/validate');
      return response.data['is_valid'] as bool;
    } catch (e) {
      throw Exception('Failed to validate cart: $e');
    }
  }

  @override
  Future<List<String>> getCartValidationErrors() async {
    try {
      final response = await apiClient.get('/cart/validate');
      return List<String>.from(response.data['errors'] ?? []);
    } catch (e) {
      throw Exception('Failed to get cart validation errors: $e');
    }
  }

  @override
  Future<bool> checkItemStock({
    required int productId,
    required int quantity,
  }) async {
    try {
      final response = await apiClient.get(
        '/products/$productId/stock',
        queryParameters: {'quantity': quantity},
      );
      return response.data['in_stock'] as bool;
    } catch (e) {
      throw Exception('Failed to check item stock: $e');
    }
  }
}
