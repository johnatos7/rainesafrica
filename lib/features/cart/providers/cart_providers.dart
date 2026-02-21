import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/data/datasources/cart_hive_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/data/repositories/cart_hive_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/domain/entities/cart_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/product_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/providers/product_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';

// Hive data source provider
final cartHiveDataSourceProvider = Provider<CartHiveDataSource>((ref) {
  return CartHiveDataSourceImpl();
});

// Repository provider - using Hive instead of remote API
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final hiveDataSource = ref.watch(cartHiveDataSourceProvider);
  final productRepository = ref.watch(productRepositoryProvider);
  return CartHiveRepositoryImpl(
    hiveDataSource: hiveDataSource,
    productRepository: productRepository,
  );
});

// Cart state providers
final cartProvider = FutureProvider<CartEntity>((ref) async {
  try {
    print('CartProvider: Getting cart...');
    final repository = ref.watch(cartRepositoryProvider);
    final result = await repository.getCart();

    return result.fold(
      (failure) {
        print('CartProvider: Failed to get cart: ${failure.message}');
        // Get selected currency for empty cart
        final currencyState = ref.read(currencyProvider);
        final selectedCurrency = currencyState.selectedCurrency;
        final currency = selectedCurrency?.code ?? 'USD';

        // Return empty cart instead of throwing exception
        return CartEntity(
          id: 'empty',
          items: [],
          subtotal: 0.0,
          tax: 0.0,
          shipping: 0.0,
          discount: 0.0,
          total: 0.0,
          currency: currency,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      },
      (cart) {
        print('CartProvider: Got cart with ${cart.items.length} items');
        // Update cart currency to match selected currency
        final currencyState = ref.read(currencyProvider);
        final selectedCurrency = currencyState.selectedCurrency;
        if (selectedCurrency != null &&
            cart.currency != selectedCurrency.code) {
          return cart.copyWith(currency: selectedCurrency.code);
        }
        return cart;
      },
    );
  } catch (e) {
    // Get selected currency for empty cart
    final currencyState = ref.read(currencyProvider);
    final selectedCurrency = currencyState.selectedCurrency;
    final currency = selectedCurrency?.code ?? 'USD';

    // Return empty cart on any error
    return CartEntity(
      id: 'empty',
      items: [],
      subtotal: 0.0,
      tax: 0.0,
      shipping: 0.0,
      discount: 0.0,
      total: 0.0,
      currency: currency,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
});

final cartSummaryProvider = FutureProvider<CartSummaryEntity>((ref) async {
  try {
    final repository = ref.watch(cartRepositoryProvider);
    final result = await repository.getCartSummary();

    return result.fold(
      (failure) {
        // Get selected currency for empty summary
        final currencyState = ref.read(currencyProvider);
        final selectedCurrency = currencyState.selectedCurrency;
        final currency = selectedCurrency?.code ?? 'USD';

        // Return empty summary instead of throwing exception
        return CartSummaryEntity(
          totalItems: 0,
          subtotal: 0.0,
          tax: 0.0,
          shipping: 0.0,
          discount: 0.0,
          expeditedShippingFee: 0.0,
          total: 0.0,
          currency: currency,
        );
      },
      (summary) {
        // Update summary currency to match selected currency
        final currencyState = ref.read(currencyProvider);
        final selectedCurrency = currencyState.selectedCurrency;
        if (selectedCurrency != null &&
            summary.currency != selectedCurrency.code) {
          return CartSummaryEntity(
            totalItems: summary.totalItems,
            subtotal: summary.subtotal,
            tax: summary.tax,
            shipping: summary.shipping,
            discount: summary.discount,
            expeditedShippingFee: summary.expeditedShippingFee,
            total: summary.total,
            currency: selectedCurrency.code,
          );
        }
        return summary;
      },
    );
  } catch (e) {
    // Get selected currency for empty summary
    final currencyState = ref.read(currencyProvider);
    final selectedCurrency = currencyState.selectedCurrency;
    final currency = selectedCurrency?.code ?? 'USD';

    // Return empty summary on any error
    return CartSummaryEntity(
      totalItems: 0,
      subtotal: 0.0,
      tax: 0.0,
      shipping: 0.0,
      discount: 0.0,
      expeditedShippingFee: 0.0,
      total: 0.0,
      currency: currency,
    );
  }
});

// Cart item count provider
final cartItemCountProvider = FutureProvider<int>((ref) async {
  final cart = await ref.watch(cartProvider.future);
  return cart.itemCount;
});

// Cart total provider
final cartTotalProvider = FutureProvider<double>((ref) async {
  final cart = await ref.watch(cartProvider.future);
  return cart.calculatedTotal;
});

// Cart validation providers
final cartValidationProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(cartRepositoryProvider);
  final result = await repository.validateCart();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (isValid) => isValid,
  );
});

final cartValidationErrorsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(cartRepositoryProvider);
  final result = await repository.getCartValidationErrors();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (errors) => errors,
  );
});

// Cart action providers
final addToCartProvider = FutureProvider.family<void, Map<String, dynamic>>((
  ref,
  params,
) async {
  try {
    final repository = ref.watch(cartRepositoryProvider);
    final result = await repository.addToCart(
      productId: params['productId'] as int,
      quantity: params['quantity'] as int,
      selectedVariationId: params['selectedVariationId'] as int?,
      selectedVariation: params['selectedVariation'] as String?,
      selectedAttributes: params['selectedAttributes'] as Map<String, String>?,
      selectedAttributeIds: params['selectedAttributeIds'] as List<int>?,
      variationDisplayName: params['variationDisplayName'] as String?,
    );

    return result.fold((failure) {
      // Log error but don't throw exception
      print('Failed to add to cart: ${failure.message}');
      return null;
    }, (_) => null);
  } catch (e) {
    // Log error but don't throw exception
    print('Failed to add to cart: $e');
    return null;
  }
});

final updateCartItemProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
      final repository = ref.watch(cartRepositoryProvider);
      final result = await repository.updateCartItem(
        itemId: params['itemId'] as String,
        quantity: params['quantity'] as int,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) => null,
      );
    });

final updateCartItemShippingProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
      final repository = ref.watch(cartRepositoryProvider);
      final result = await repository.updateCartItemShipping(
        itemId: params['itemId'] as String,
        shippingMethod: params['shippingMethod'] as String?,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) => null,
      );
    });

final removeFromCartProvider = FutureProvider.family<void, String>((
  ref,
  itemId,
) async {
  final repository = ref.watch(cartRepositoryProvider);
  final result = await repository.removeFromCart(itemId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) => null,
  );
});

final removeAllFromCartProvider = FutureProvider.family<void, int>((
  ref,
  productId,
) async {
  final repository = ref.watch(cartRepositoryProvider);
  final result = await repository.removeAllFromCart(productId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) => null,
  );
});

final clearCartProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(cartRepositoryProvider);
  final result = await repository.clearCart();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) => null,
  );
});

// Stock checking provider
final checkItemStockProvider =
    FutureProvider.family<bool, Map<String, dynamic>>((ref, params) async {
      final repository = ref.watch(cartRepositoryProvider);
      final result = await repository.checkItemStock(
        productId: params['productId'] as int,
        quantity: params['quantity'] as int,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (isInStock) => isInStock,
      );
    });

// Shipping calculation provider
final calculateShippingProvider =
    FutureProvider.family<double, Map<String, String>>((ref, params) async {
      final repository = ref.watch(cartRepositoryProvider);
      final result = await repository.calculateShipping(
        address: params['address']!,
        city: params['city']!,
        postalCode: params['postalCode']!,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (shippingCost) => shippingCost,
      );
    });

// Local storage providers
final saveCartToLocalProvider = FutureProvider.family<void, CartEntity>((
  ref,
  cart,
) async {
  final repository = ref.watch(cartRepositoryProvider);
  final result = await repository.saveCartToLocal(cart);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) => null,
  );
});

final getCartFromLocalProvider = FutureProvider<CartEntity?>((ref) async {
  final repository = ref.watch(cartRepositoryProvider);
  final result = await repository.getCartFromLocal();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (cart) => cart,
  );
});

final clearLocalCartProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(cartRepositoryProvider);
  final result = await repository.clearLocalCart();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) => null,
  );
});

// Product storage providers - using Hive
final saveProductProvider = FutureProvider.family<void, ProductModel>((
  ref,
  product,
) async {
  final hiveDataSource = ref.watch(cartHiveDataSourceProvider);
  await hiveDataSource.saveProduct(product);
});

final getProductProvider = FutureProvider.family<ProductModel?, int>((
  ref,
  productId,
) async {
  final hiveDataSource = ref.watch(cartHiveDataSourceProvider);
  return await hiveDataSource.getProduct(productId);
});

final saveProductsProvider = FutureProvider.family<void, List<ProductModel>>((
  ref,
  products,
) async {
  final hiveDataSource = ref.watch(cartHiveDataSourceProvider);
  await hiveDataSource.saveProducts(products);
});

final getProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final hiveDataSource = ref.watch(cartHiveDataSourceProvider);
  return await hiveDataSource.getProducts();
});
