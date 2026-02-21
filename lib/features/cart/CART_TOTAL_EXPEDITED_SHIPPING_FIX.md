# Cart Total Expedited Shipping Fix

This document outlines the implementation of expedited shipping fee integration into the cart total calculation and display.

## Problem

The cart total was not updating when users selected fast shipping because:
1. The `CartSummaryEntity` didn't include expedited shipping fee field
2. The cart summary calculation didn't account for expedited shipping fees
3. The cart screen didn't display expedited shipping fee breakdown

## Solution

### 1. Enhanced CartSummaryEntity

**File**: `lib/features/cart/domain/entities/cart_entity.dart`

Added `expeditedShippingFee` field to `CartSummaryEntity`:

```dart
class CartSummaryEntity extends Equatable {
  final int totalItems;
  final double subtotal;
  final double tax;
  final double shipping;
  final double discount;
  final double expeditedShippingFee; // New field
  final double total;
  final String currency;

  const CartSummaryEntity({
    required this.totalItems,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.discount,
    required this.expeditedShippingFee, // New required parameter
    required this.total,
    required this.currency,
  });
  
  // Updated props list and copyWith method
}
```

### 2. Updated Cart Summary Calculation

**File**: `lib/features/cart/data/repositories/cart_hive_repository_impl.dart`

Enhanced the `getCartSummary()` method to calculate expedited shipping fees:

```dart
// Calculate expedited shipping fee
double expeditedShippingFee = 0.0;
for (final item in items) {
  if (item.itemShippingMethod == 'expedited' && item.product != null) {
    final expeditedPrice = item.product!.shippingOptions?.expeditedShippingPrice ?? 0.0;
    expeditedShippingFee += expeditedPrice;
  }
}

final total = subtotal + (subtotal * tax) + shipping + expeditedShippingFee - discount;

final summary = CartSummaryEntity(
  totalItems: items.length,
  subtotal: subtotal,
  tax: subtotal * tax,
  shipping: shipping,
  discount: discount,
  expeditedShippingFee: expeditedShippingFee, // Include in summary
  total: total,
  currency: 'ZAR',
);
```

### 3. Enhanced Cart Model

**File**: `lib/features/cart/data/models/cart_model.dart`

Updated `CartSummaryModel` to include expedited shipping fee:

```dart
class CartSummaryModel extends Equatable {
  final int? totalItems;
  final double? subtotal;
  final double? tax;
  final double? shipping;
  final double? discount;
  final double? expeditedShippingFee; // New field
  final double? total;
  final String? currency;

  // Updated fromJson, toJson, and toEntity methods
}
```

### 4. Enhanced Cart Screen Display

**File**: `lib/features/cart/presentation/screens/cart_screen.dart`

Updated `_CartSummaryWidget` to show expedited shipping fee breakdown:

```dart
// Subtotal
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('Subtotal: (${summary.totalItems} Items)'),
    Text(ref.watch(currencyFormattingProvider)(summary.subtotal)),
  ],
),

// Fast Shipping Fee (only show if > 0)
if (summary.expeditedShippingFee > 0) ...[
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text('Fast Shipping Fee:'),
      Text(ref.watch(currencyFormattingProvider)(summary.expeditedShippingFee)),
    ],
  ),
],

// Total
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('TOTAL:'),
    Text(ref.watch(currencyFormattingProvider)(summary.total)),
  ],
),
```

### 5. Updated Cart Providers

**File**: `lib/features/cart/providers/cart_providers.dart`

Updated all `CartSummaryEntity` constructors to include `expeditedShippingFee`:

```dart
return CartSummaryEntity(
  totalItems: 0,
  subtotal: 0.0,
  tax: 0.0,
  shipping: 0.0,
  discount: 0.0,
  expeditedShippingFee: 0.0, // Added field
  total: 0.0,
  currency: currency,
);
```

## Cart Display Structure

The cart screen now displays:

```
┌─────────────────────────────────────┐
│ Subtotal: (2 Items)           $100.00 │
│ Fast Shipping Fee:              $350.00 │
│ ───────────────────────────────────── │
│ TOTAL:                          $450.00 │
│                                     │
│ [PROCEED TO CHECKOUT]                │
└─────────────────────────────────────┘
```

### Display Logic

- **Subtotal**: Always shown with item count
- **Fast Shipping Fee**: Only shown when `expeditedShippingFee > 0`
- **Total**: Always shown, includes expedited shipping fee
- **Visual Separation**: Divider between breakdown and total

## Real-time Updates

The cart total now updates in real-time when users:

1. **Select Fast Shipping**: Cart total increases by expedited shipping fee
2. **Change to Standard Shipping**: Cart total decreases by expedited shipping fee
3. **Remove Items with Fast Shipping**: Cart total decreases appropriately
4. **Add Items with Fast Shipping**: Cart total increases appropriately

## Integration with Existing Features

### Cart Entity Integration

The cart entity's `calculatedExpeditedShippingFee` getter is used in:
- Cart summary calculation
- Checkout total calculation
- Order payload generation

### Checkout Integration

The expedited shipping fee is included in:
- Order summary display
- Order total calculation
- Order payload (`orderTotal` and `grandTotal`)

## Testing Scenarios

### Scenario 1: No Fast Shipping
```
Subtotal: (2 Items)     $100.00
TOTAL:                  $100.00
```

### Scenario 2: One Item with Fast Shipping
```
Subtotal: (2 Items)     $100.00
Fast Shipping Fee:      $350.00
TOTAL:                  $450.00
```

### Scenario 3: Multiple Items with Fast Shipping
```
Subtotal: (3 Items)     $200.00
Fast Shipping Fee:      $700.00  (2 items × $350.00)
TOTAL:                  $900.00
```

### Scenario 4: Mixed Shipping Methods
```
Subtotal: (3 Items)     $200.00
Fast Shipping Fee:      $350.00  (1 item × $350.00)
TOTAL:                  $550.00
```

## Performance Considerations

- **Calculation**: O(n) where n is number of cart items
- **Caching**: Cart summary is cached and refreshed when needed
- **Real-time Updates**: Provider refresh triggers recalculation
- **Memory**: Minimal memory overhead for additional field

## Backward Compatibility

- **Existing Orders**: Continue to work without expedited shipping fee
- **API Compatibility**: No breaking changes to existing endpoints
- **Data Migration**: No migration needed for existing cart data
- **Default Values**: Expedited shipping fee defaults to 0.0

## Error Handling

- **Null Safety**: All fields are nullable with proper defaults
- **Product Validation**: Checks for product existence before accessing shipping options
- **Price Validation**: Uses null-aware operators for price calculations
- **Currency Handling**: Maintains existing currency formatting

## Future Enhancements

Potential improvements:
1. **Caching**: Cache expedited shipping calculations
2. **Validation**: Add validation for shipping method selection
3. **Analytics**: Track expedited shipping usage
4. **Promotions**: Support for expedited shipping discounts
