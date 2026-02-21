# Cart Feature Troubleshooting Guide

This guide helps identify and resolve common issues with the cart functionality.

## 🚨 Common Issues & Solutions

### 1. **"Failed to add to cart" Errors**

#### **Issue**: Network/API Errors
```
Failed to add to cart: Exception: Failed to add to cart: [error details]
```

**Solutions**:
- ✅ **Mock Data Source**: Currently using `CartMockDataSource` for development
- ✅ **API Endpoints**: Real API endpoints not yet implemented
- ✅ **Error Handling**: Comprehensive error handling in place

**To switch to real API**:
1. Uncomment the real API client in `cart_providers.dart`
2. Comment out the mock data source
3. Ensure API endpoints are implemented

#### **Issue**: Product Entity Issues
```
The getter 'id' isn't defined for the type 'ProductEntity'
```

**Solutions**:
- ✅ **Product Model**: Ensure `ProductEntity` has proper `id` field
- ✅ **Type Safety**: Check product model structure
- ✅ **Import Issues**: Verify correct imports

### 2. **Cart Screen Loading Issues**

#### **Issue**: Cart Screen Shows Loading Forever
```
Cart screen stuck on loading state
```

**Solutions**:
- ✅ **Provider Issues**: Check `cartProvider` implementation
- ✅ **Network Issues**: Verify network connectivity
- ✅ **Mock Data**: Mock data source provides immediate response

#### **Issue**: Empty Cart Not Showing
```
Cart shows loading instead of empty state
```

**Solutions**:
- ✅ **Empty State**: `_EmptyCartWidget` implemented
- ✅ **Condition Check**: `cart.isEmpty` properly checked
- ✅ **UI States**: Loading, error, and empty states handled

### 3. **Navigation Issues**

#### **Issue**: Cart Navigation Not Working
```
Tapping cart icon doesn't navigate to cart screen
```

**Solutions**:
- ✅ **GoRouter**: Navigation using `context.go(AppConstants.cartRoute)`
- ✅ **Route Constants**: `AppConstants.cartRoute` defined
- ✅ **Router Setup**: Cart route added to `app_router.dart`

#### **Issue**: "View Cart" Button Not Working
```
SnackBar "View Cart" action doesn't navigate
```

**Solutions**:
- ✅ **Navigation Fixed**: Uncommented navigation in `AddToCartButton`
- ✅ **Context**: Proper context usage for navigation
- ✅ **Route**: Correct route constant usage

### 4. **State Management Issues**

#### **Issue**: Cart Count Not Updating
```
Cart badge shows wrong count or doesn't update
```

**Solutions**:
- ✅ **Provider Invalidation**: `ref.invalidate()` calls after cart operations
- ✅ **Real-time Updates**: `cartItemCountProvider` watches cart state
- ✅ **State Sync**: Cart state synchronized across providers

#### **Issue**: Cart Items Not Persisting
```
Cart items disappear after app restart
```

**Solutions**:
- ✅ **Local Storage**: `CartLocalDataSource` for offline persistence
- ✅ **Data Sync**: Local and remote data synchronization
- ✅ **Mock Persistence**: Mock data source maintains state during session

### 5. **UI/UX Issues**

#### **Issue**: Cart Icon Badge Not Showing
```
Cart icon doesn't show item count badge
```

**Solutions**:
- ✅ **Badge Logic**: Badge shows when count > 0
- ✅ **Provider Watch**: `cartItemCountProvider` properly watched
- ✅ **State Updates**: Badge updates with cart changes

#### **Issue**: Add to Cart Button Not Working
```
Button shows loading but doesn't add items
```

**Solutions**:
- ✅ **Loading States**: Proper loading state management
- ✅ **Error Handling**: Try-catch blocks with user feedback
- ✅ **Success Feedback**: SnackBar confirmation on success

## 🔧 Debugging Steps

### **Step 1: Check Console Logs**
```dart
// Add debug prints to cart operations
print('Adding to cart: ${product.name}');
print('Cart state: ${cart.items.length} items');
```

### **Step 2: Verify Provider State**
```dart
// Check provider state in widgets
final cartAsync = ref.watch(cartProvider);
print('Cart provider state: ${cartAsync.runtimeType}');
```

### **Step 3: Test Mock Data**
```dart
// Verify mock data source is working
final mockDataSource = CartMockDataSource();
final cart = await mockDataSource.getCart();
print('Mock cart: ${cart.items.length} items');
```

### **Step 4: Check Network Connectivity**
```dart
// Verify network info provider
final networkInfo = ref.watch(networkInfoProvider);
final isConnected = await networkInfo.isConnected;
print('Network connected: $isConnected');
```

## 🛠️ Development Tools

### **Mock Data Source**
- ✅ **Immediate Response**: No network delays for development
- ✅ **Realistic Data**: Mock products and cart items
- ✅ **State Persistence**: Maintains state during app session
- ✅ **Error Simulation**: Can simulate various error conditions

### **Error Simulation**
```dart
// In CartMockDataSource, you can simulate errors:
if (productId == 999) {
  throw Exception('Simulated error for testing');
}
```

### **Debug Mode**
```dart
// Add debug mode to providers
final debugMode = Provider<bool>((ref) => true);

final cartProvider = FutureProvider<CartEntity>((ref) async {
  final debug = ref.watch(debugMode);
  if (debug) {
    print('Cart provider called');
  }
  // ... rest of implementation
});
```

## 📱 Testing Checklist

### **Cart Functionality**
- [ ] Add item to cart from product details
- [ ] Add item to cart from product card
- [ ] Update item quantity in cart
- [ ] Remove item from cart
- [ ] Clear entire cart
- [ ] Cart count updates in real-time
- [ ] Cart persists after app restart

### **Navigation**
- [ ] Cart icon navigates to cart screen
- [ ] "View Cart" button navigates to cart screen
- [ ] Bottom navigation cart tab works
- [ ] Back navigation from cart screen works

### **UI States**
- [ ] Loading states show during operations
- [ ] Error states show with retry options
- [ ] Empty cart state displays correctly
- [ ] Success feedback shows after operations

### **Error Handling**
- [ ] Network errors show user-friendly messages
- [ ] API errors are handled gracefully
- [ ] Validation errors are displayed
- [ ] Retry mechanisms work

## 🚀 Performance Optimization

### **Provider Optimization**
```dart
// Use autoDispose for temporary providers
final cartProvider = FutureProvider.autoDispose<CartEntity>((ref) async {
  // Implementation
});
```

### **State Caching**
```dart
// Cache cart state to reduce API calls
final cachedCartProvider = Provider<CartEntity?>((ref) => null);
```

### **Lazy Loading**
```dart
// Load cart only when needed
final cartProvider = FutureProvider<CartEntity>((ref) async {
  // Only load when cart screen is accessed
  return await repository.getCart();
});
```

## 🔄 Migration to Real API

### **Step 1: Update Data Source**
```dart
// In cart_providers.dart
final cartRemoteDataSourceProvider = Provider<CartRemoteDataSource>((ref) {
  final apiClient = ref.watch(cartApiClientProvider);
  return CartRemoteDataSourceImpl(apiClient: apiClient);
});
```

### **Step 2: Implement API Endpoints**
- `GET /cart` - Get current cart
- `POST /cart/items` - Add item to cart
- `PUT /cart/items/{id}` - Update cart item
- `DELETE /cart/items/{id}` - Remove cart item

### **Step 3: Update Error Handling**
```dart
// Add specific error handling for API responses
if (response.statusCode == 404) {
  throw CartNotFoundException('Cart not found');
}
```

### **Step 4: Test with Real Data**
- Test with actual product data
- Verify API response formats
- Test error scenarios
- Validate data persistence

## 📞 Support

If you encounter issues not covered in this guide:

1. **Check Console Logs**: Look for error messages and stack traces
2. **Verify Dependencies**: Ensure all required packages are installed
3. **Test Mock Data**: Verify mock data source is working
4. **Check Provider State**: Use Riverpod dev tools to inspect state
5. **Network Issues**: Test with and without network connectivity

## 🎯 Quick Fixes

### **Cart Not Loading**
```dart
// Force refresh cart provider
ref.invalidate(cartProvider);
```

### **Navigation Issues**
```dart
// Use Navigator instead of GoRouter as fallback
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => CartScreen()),
);
```

### **State Not Updating**
```dart
// Manually invalidate all cart providers
ref.invalidate(cartProvider);
ref.invalidate(cartItemCountProvider);
ref.invalidate(cartSummaryProvider);
```

### **Mock Data Issues**
```dart
// Reset mock data source
final mockDataSource = CartMockDataSource();
await mockDataSource.clearCart();
```
