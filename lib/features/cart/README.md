# Cart Feature

This feature provides a complete shopping cart functionality for the mobile app, following Clean Architecture principles.

## Features

- ✅ Add items to cart
- ✅ Update item quantities
- ✅ Remove items from cart
- ✅ Clear entire cart
- ✅ Cart validation
- ✅ Stock checking
- ✅ Shipping calculation
- ✅ Local storage for offline support
- ✅ Real-time cart item count
- ✅ Cart summary with totals
- ✅ Beautiful UI matching the provided screenshots

## Architecture

The cart feature follows Clean Architecture with three layers:

### Domain Layer
- `CartEntity` - Core business objects
- `CartItemEntity` - Individual cart item representation
- `CartSummaryEntity` - Cart totals and summary
- `CartRepository` - Repository interface

### Data Layer
- `CartModel` - Data transfer objects
- `CartRemoteDataSource` - API communication
- `CartLocalDataSource` - Local storage
- `CartRepositoryImpl` - Repository implementation

### Presentation Layer
- `CartScreen` - Main cart screen
- `CartItemWidget` - Individual cart item display
- `CartIconWidget` - Cart icon with badge
- `AddToCartButton` - Add to cart functionality
- `CartProviders` - State management

## Usage

### Adding Items to Cart

```dart
// Using the AddToCartButton widget
AddToCartButton(
  product: product,
  quantity: 2,
  selectedVariation: 'Large',
  selectedAttributes: {'Color': 'Red'},
  onAdded: () => print('Item added!'),
)

// Or programmatically
ref.read(addToCartProvider({
  'productId': product.id,
  'quantity': 1,
  'selectedVariation': null,
  'selectedAttributes': null,
}).future);
```

### Displaying Cart Icon

```dart
// In AppBar actions
AppBar(
  actions: [
    CartIconButton(),
  ],
)

// Or as a standalone widget
CartIconWidget(
  iconColor: Colors.white,
  badgeColor: Colors.red,
)
```

### Navigating to Cart

```dart
// Using GoRouter
context.go(AppConstants.cartRoute);

// Or using the cart icon widgets (they handle navigation automatically)
```

### Watching Cart State

```dart
// Cart items
final cartAsync = ref.watch(cartProvider);

// Cart item count
final itemCountAsync = ref.watch(cartItemCountProvider);

// Cart total
final totalAsync = ref.watch(cartTotalProvider);

// Cart summary
final summaryAsync = ref.watch(cartSummaryProvider);
```

## API Endpoints

The cart feature expects the following API endpoints:

- `GET /cart` - Get current cart
- `POST /cart` - Create new cart
- `PUT /cart` - Update cart
- `DELETE /cart` - Delete cart
- `DELETE /cart/items` - Clear cart items
- `POST /cart/items` - Add item to cart
- `PUT /cart/items/{itemId}` - Update cart item
- `DELETE /cart/items/{itemId}` - Remove cart item
- `GET /cart/summary` - Get cart summary
- `POST /cart/shipping` - Calculate shipping
- `GET /cart/validate` - Validate cart
- `GET /products/{productId}/stock` - Check product stock

## Local Storage

The cart automatically saves to local storage for offline support. When offline:
- Cart items are loaded from local storage
- Changes are queued and synced when online
- Basic validation is performed locally

## Error Handling

The cart feature includes comprehensive error handling:
- Network failures
- Server errors
- Validation errors
- Stock availability issues
- Local storage errors

## UI Components

### CartScreen
Main cart screen with:
- Product list with images
- Quantity selectors
- Price display with promotions
- Stock status indicators
- COD eligibility notices
- Cart summary and checkout button

### CartItemWidget
Individual cart item with:
- Product image and details
- Price with sale indicators
- Stock location badges
- Promotion badges
- Quantity controls
- Delete functionality

### CartIconWidget
Cart icon with:
- Item count badge
- Navigation to cart
- Customizable colors and size

## State Management

Uses Riverpod for state management with:
- `cartProvider` - Main cart state
- `cartItemCountProvider` - Item count
- `cartTotalProvider` - Cart total
- `cartSummaryProvider` - Cart summary
- Action providers for mutations

## Testing

The cart feature is designed to be easily testable:
- Repository interfaces for mocking
- Separate data sources for testing
- Provider-based state management
- Clean separation of concerns

## Future Enhancements

- [ ] Wishlist integration
- [ ] Save for later functionality
- [ ] Cart sharing
- [ ] Bulk operations
- [ ] Cart persistence across devices
- [ ] Advanced shipping options
- [ ] Tax calculation
- [ ] Discount codes
- [ ] Cart abandonment recovery
