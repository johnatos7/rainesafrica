import 'dart:convert';
import 'package:flutter_riverpod_clean_architecture/core/storage/local_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/data/models/cart_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/product_model.dart';

abstract class CartLocalDataSource {
  Future<void> saveCart(CartModel cart);
  Future<CartModel?> getCart();
  Future<void> clearCart();
  Future<void> saveCartItem(CartItemModel item);
  Future<void> updateCartItemShipping({
    required String itemId,
    required String? shippingMethod,
  });
  Future<void> removeCartItem(String itemId);
  Future<List<CartItemModel>> getCartItems();

  // Product storage methods
  Future<void> saveProduct(ProductModel product);
  Future<ProductModel?> getProduct(int productId);
  Future<List<ProductModel>> getProducts();
  Future<void> saveProducts(List<ProductModel> products);
  Future<void> clearProducts();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final LocalStorageService localStorageService;
  static const String _cartKey = 'cart';
  static const String _cartItemsKey = 'cart_items';
  static const String _productsKey = 'products';
  static const String _productPrefix = 'product_';

  CartLocalDataSourceImpl({required this.localStorageService});

  @override
  Future<void> saveCart(CartModel cart) async {
    try {
      final cartJson = jsonEncode(cart.toJson());
      await localStorageService.setString(_cartKey, cartJson);
    } catch (e) {
      throw Exception('Failed to save cart locally: $e');
    }
  }

  @override
  Future<CartModel?> getCart() async {
    try {
      final cartJson = localStorageService.getString(_cartKey);
      if (cartJson == null) return null;

      final cartData = jsonDecode(cartJson) as Map<String, dynamic>;
      return CartModel.fromJson(cartData);
    } catch (e) {
      throw Exception('Failed to get cart from local storage: $e');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      localStorageService.remove(_cartKey);
      localStorageService.remove(_cartItemsKey);
    } catch (e) {
      throw Exception('Failed to clear cart from local storage: $e');
    }
  }

  @override
  Future<void> saveCartItem(CartItemModel item) async {
    try {
      final items = await getCartItems();

      // Remove existing item with same product ID and variation
      items.removeWhere(
        (existingItem) =>
            existingItem.product?.id == item.product?.id &&
            existingItem.selectedVariation == item.selectedVariation,
      );

      // Add new item
      items.add(item);

      final itemsJson = jsonEncode(items.map((item) => item.toJson()).toList());
      await localStorageService.setString(_cartItemsKey, itemsJson);
    } catch (e) {
      throw Exception('Failed to save cart item locally: $e');
    }
  }

  @override
  Future<void> updateCartItemShipping({
    required String itemId,
    required String? shippingMethod,
  }) async {
    try {
      final items = await getCartItems();
      final itemIndex = items.indexWhere((item) => item.id == itemId);

      if (itemIndex == -1) {
        throw Exception('Cart item with ID $itemId not found');
      }

      // Update the shipping method for the item
      final updatedItem = CartItemModel(
        id: items[itemIndex].id,
        cartId: items[itemIndex].cartId,
        product: items[itemIndex].product,
        productId: items[itemIndex].productId,
        quantity: items[itemIndex].quantity,
        unitPrice: items[itemIndex].unitPrice,
        totalPrice: items[itemIndex].totalPrice,
        selectedVariation: items[itemIndex].selectedVariation,
        selectedVariationId: items[itemIndex].selectedVariationId,
        selectedAttributes: items[itemIndex].selectedAttributes,
        itemShippingMethod: shippingMethod,
        addedAt: items[itemIndex].addedAt,
        updatedAt: DateTime.now(),
      );

      items[itemIndex] = updatedItem;

      final itemsJson = jsonEncode(items.map((item) => item.toJson()).toList());
      await localStorageService.setString(_cartItemsKey, itemsJson);
    } catch (e) {
      throw Exception('Failed to update cart item shipping locally: $e');
    }
  }

  @override
  Future<void> removeCartItem(String itemId) async {
    try {
      final items = await getCartItems();
      items.removeWhere((item) => item.id == itemId);

      final itemsJson = jsonEncode(items.map((item) => item.toJson()).toList());
      await localStorageService.setString(_cartItemsKey, itemsJson);
    } catch (e) {
      throw Exception('Failed to remove cart item from local storage: $e');
    }
  }

  @override
  Future<List<CartItemModel>> getCartItems() async {
    try {
      final itemsJson = localStorageService.getString(_cartItemsKey);
      if (itemsJson == null) return [];

      final itemsData = jsonDecode(itemsJson) as List<dynamic>;
      return itemsData
          .map(
            (itemData) =>
                CartItemModel.fromJson(itemData as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get cart items from local storage: $e');
    }
  }

  // Product storage methods
  @override
  Future<void> saveProduct(ProductModel product) async {
    try {
      final productJson = jsonEncode(product.toJson());
      await localStorageService.setString(
        '$_productPrefix${product.id}',
        productJson,
      );
    } catch (e) {
      throw Exception('Failed to save product locally: $e');
    }
  }

  @override
  Future<ProductModel?> getProduct(int productId) async {
    try {
      final productJson = localStorageService.getString(
        '$_productPrefix$productId',
      );
      if (productJson == null) return null;

      final productData = jsonDecode(productJson) as Map<String, dynamic>;
      return ProductModel.fromJson(productData);
    } catch (e) {
      throw Exception('Failed to get product from local storage: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final productsJson = localStorageService.getString(_productsKey);
      if (productsJson == null) return [];

      final productsData = jsonDecode(productsJson) as List<dynamic>;
      return productsData
          .map(
            (productData) =>
                ProductModel.fromJson(productData as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get products from local storage: $e');
    }
  }

  @override
  Future<void> saveProducts(List<ProductModel> products) async {
    try {
      final productsJson = jsonEncode(
        products.map((product) => product.toJson()).toList(),
      );
      await localStorageService.setString(_productsKey, productsJson);
    } catch (e) {
      throw Exception('Failed to save products locally: $e');
    }
  }

  @override
  Future<void> clearProducts() async {
    try {
      localStorageService.remove(_productsKey);
      // Note: Individual product keys are not cleared to avoid performance issues
      // They will be overwritten when new products are saved
    } catch (e) {
      throw Exception('Failed to clear products from local storage: $e');
    }
  }
}
