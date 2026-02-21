import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/data/models/cart_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/product_model.dart';

abstract class CartHiveDataSource {
  Future<void> saveCart(CartModel cart);
  Future<CartModel?> getCart();
  Future<void> clearCart();
  Future<void> saveCartItem(CartItemModel item);
  Future<void> removeCartItem(String itemId);
  Future<List<CartItemModel>> getCartItems();

  // Product storage methods
  Future<void> saveProduct(ProductModel product);
  Future<ProductModel?> getProduct(int productId);
  Future<List<ProductModel>> getProducts();
  Future<void> saveProducts(List<ProductModel> products);
  Future<void> clearProducts();
}

class CartHiveDataSourceImpl implements CartHiveDataSource {
  late Box<String> _cartBox;
  late Box<String> _productsBox;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      try {
        print('Initializing Hive boxes...');
        _cartBox = await Hive.openBox<String>(AppConstants.cartBox);
        _productsBox = await Hive.openBox<String>(AppConstants.productsBox);
        _initialized = true;
        print('Hive boxes initialized successfully');
      } catch (e) {
        print('Failed to initialize Hive boxes: $e');
        rethrow;
      }
    }
  }

  @override
  Future<void> saveCart(CartModel cart) async {
    await _ensureInitialized();
    try {
      final cartJson = jsonEncode(cart.toJson());
      await _cartBox.put('cart', cartJson);
    } catch (e) {
      throw Exception('Failed to save cart to Hive: $e');
    }
  }

  @override
  Future<CartModel?> getCart() async {
    await _ensureInitialized();
    try {
      final cartJson = _cartBox.get('cart');
      if (cartJson == null) return null;

      final cartData = jsonDecode(cartJson) as Map<String, dynamic>;
      return CartModel.fromJson(cartData);
    } catch (e) {
      throw Exception('Failed to get cart from Hive: $e');
    }
  }

  @override
  Future<void> clearCart() async {
    await _ensureInitialized();
    try {
      print('HiveDataSource: Clearing cart data...');
      await _cartBox.clear();
      print('HiveDataSource: Cart data cleared successfully');
    } catch (e) {
      print('HiveDataSource: Failed to clear cart: $e');
      throw Exception('Failed to clear cart from Hive: $e');
    }
  }

  @override
  Future<void> saveCartItem(CartItemModel item) async {
    await _ensureInitialized();
    try {
      print('Saving cart item: ${item.id} for product: ${item.productId}');
      final items = await getCartItems();
      print('Current cart items count: ${items.length}');

      // Remove existing item with same product ID and variation
      items.removeWhere(
        (existingItem) =>
            existingItem.productId == item.productId &&
            existingItem.selectedVariationId == item.selectedVariationId &&
            existingItem.selectedVariation == item.selectedVariation,
      );

      // Add new item
      items.add(item);
      print('New cart items count: ${items.length}');

      final itemsJson = jsonEncode(items.map((item) => item.toJson()).toList());
      await _cartBox.put('cart_items', itemsJson);
      print('Cart item saved successfully');
    } catch (e) {
      print('Failed to save cart item to Hive: $e');
      throw Exception('Failed to save cart item to Hive: $e');
    }
  }

  @override
  Future<void> removeCartItem(String itemId) async {
    await _ensureInitialized();
    try {
      final items = await getCartItems();
      items.removeWhere((item) => item.id == itemId);

      final itemsJson = jsonEncode(items.map((item) => item.toJson()).toList());
      await _cartBox.put('cart_items', itemsJson);
    } catch (e) {
      throw Exception('Failed to remove cart item from Hive: $e');
    }
  }

  @override
  Future<List<CartItemModel>> getCartItems() async {
    await _ensureInitialized();
    try {
      print('HiveDataSource: Getting cart items from Hive...');
      final itemsJson = _cartBox.get('cart_items');
      print('HiveDataSource: Raw cart items JSON: $itemsJson');

      if (itemsJson == null) {
        print('HiveDataSource: No cart items found in Hive');
        return [];
      }

      final itemsData = jsonDecode(itemsJson) as List<dynamic>;
      print('HiveDataSource: Parsed ${itemsData.length} cart items');

      final cartItems =
          itemsData
              .map(
                (itemData) =>
                    CartItemModel.fromJson(itemData as Map<String, dynamic>),
              )
              .toList();

      print(
        'HiveDataSource: Created ${cartItems.length} CartItemModel objects',
      );
      return cartItems;
    } catch (e) {
      print('HiveDataSource: Error getting cart items: $e');
      throw Exception('Failed to get cart items from Hive: $e');
    }
  }

  // Product storage methods
  @override
  Future<void> saveProduct(ProductModel product) async {
    await _ensureInitialized();
    try {
      final productJson = jsonEncode(product.toJson());
      await _productsBox.put('product_${product.id}', productJson);
    } catch (e) {
      throw Exception('Failed to save product to Hive: $e');
    }
  }

  @override
  Future<ProductModel?> getProduct(int productId) async {
    await _ensureInitialized();
    try {
      final productJson = _productsBox.get('product_$productId');
      if (productJson == null) return null;

      final productData = jsonDecode(productJson) as Map<String, dynamic>;
      return ProductModel.fromJson(productData);
    } catch (e) {
      throw Exception('Failed to get product from Hive: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    await _ensureInitialized();
    try {
      final productsJson = _productsBox.get('products_list');
      if (productsJson == null) return [];

      final productsData = jsonDecode(productsJson) as List<dynamic>;
      return productsData
          .map(
            (productData) =>
                ProductModel.fromJson(productData as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get products from Hive: $e');
    }
  }

  @override
  Future<void> saveProducts(List<ProductModel> products) async {
    await _ensureInitialized();
    try {
      // Save individual products
      for (final product in products) {
        await saveProduct(product);
      }

      // Save products list
      final productsJson = jsonEncode(
        products.map((product) => product.toJson()).toList(),
      );
      await _productsBox.put('products_list', productsJson);
    } catch (e) {
      throw Exception('Failed to save products to Hive: $e');
    }
  }

  @override
  Future<void> clearProducts() async {
    await _ensureInitialized();
    try {
      await _productsBox.clear();
    } catch (e) {
      throw Exception('Failed to clear products from Hive: $e');
    }
  }
}
