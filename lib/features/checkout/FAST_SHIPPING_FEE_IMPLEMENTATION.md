# Fast Shipping Fee Implementation

This document outlines the implementation of fast shipping fee calculation and display in the order summary and checkout process.

## Overview

The fast shipping fee functionality has been implemented to:
1. Calculate total expedited shipping fees from cart items that have expedited shipping selected
2. Display the fast shipping fee as a separate line item in the order summary
3. Include the fast shipping fee in the order total calculations
4. Update the order payload to include the correct totals

## Implementation Details

### 1. Cart Entity Enhancement

**File**: `lib/features/cart/domain/entities/cart_entity.dart`

Added a new getter to calculate the total expedited shipping fee:

```dart
// Calculate total expedited shipping fee
double get calculatedExpeditedShippingFee {
  double totalFee = 0.0;
  for (final item in items) {
    if (item.itemShippingMethod == 'expedited' && item.product != null) {
      final expeditedPrice = item.product!.expeditedShippingPrice ?? 0.0;
      totalFee += expeditedPrice;
    }
  }
  return totalFee;
}
```

**Logic**:
- Iterates through all cart items
- Checks if the item has expedited shipping selected (`itemShippingMethod == 'expedited'`)
- Sums up the `expeditedShippingPrice` from each product
- Returns the total fee

### 2. Checkout Summary Enhancement

**File**: `lib/features/checkout/presentation/widgets/checkout_summary_section.dart`

#### Updated Total Calculation

```dart
// Fast shipping fee: calculated from cart items with expedited shipping
final double fastShippingFee = cart.calculatedExpeditedShippingFee;

final total = subtotal + tax + shippingFee + deliveryFee + fastShippingFee;
```

#### Updated Price Breakdown

```dart
Widget _buildPriceBreakdown(
  BuildContext context,
  String Function(double) formatCurrency,
  double subtotal,
  double tax,
  double shippingFee,
  double deliveryFee,
  double fastShippingFee, // New parameter
) {
  return Column(
    children: [
      _buildPriceRow(context, 'Subtotal', formatCurrency(subtotal)),
      _buildPriceRow(
        context,
        'Shipping',
        shippingFee == 0 ? 'FREE' : formatCurrency(shippingFee),
        isFree: shippingFee == 0,
      ),
      _buildPriceRow(
        context,
        'Delivery Fee',
        deliveryFee == 0 ? 'FREE' : formatCurrency(deliveryFee),
        isFree: deliveryFee == 0,
      ),
      if (fastShippingFee > 0) // Only show if there's a fee
        _buildPriceRow(
          context,
          'Fast Shipping Fee',
          formatCurrency(fastShippingFee),
          isFree: false,
        ),
    ],
  );
}
```

**Features**:
- Only displays the "Fast Shipping Fee" line item when the fee is greater than 0
- Uses the same styling as other price breakdown items
- Properly formatted currency display

### 3. Checkout Providers Enhancement

**File**: `lib/features/checkout/presentation/providers/checkout_providers.dart`

#### Updated Order Total Calculation

```dart
// Calculate fast shipping fee from cart items
final double fastShippingFee = cart.calculatedExpeditedShippingFee;

final double grand_total =
    subtotal + shippingFee + state.selectedShipping!.price + fastShippingFee;
```

**Impact**:
- The `grand_total` now includes the fast shipping fee
- This affects the `orderTotal` and `grandTotal` fields in the order payload
- Ensures accurate order totals for the backend

## Order Summary Display

The order summary now displays the following structure:

```
Order Summary
├── Cart Items
├── ────────────────────────
├── Subtotal: $X,XXX.XX
├── Shipping: FREE / $XX.XX
├── Delivery Fee: FREE / $XX.XX
├── Fast Shipping Fee: $XXX.XX (only if > 0)
├── ────────────────────────
└── Total: $X,XXX.XX
```

### Example Scenarios

#### Scenario 1: No Fast Shipping Selected
```
Subtotal: $1,000.00
Shipping: FREE
Delivery Fee: $15.00
Total: $1,015.00
```

#### Scenario 2: One Item with Fast Shipping
```
Subtotal: $1,000.00
Shipping: FREE
Delivery Fee: $15.00
Fast Shipping Fee: $350.00
Total: $1,365.00
```

#### Scenario 3: Multiple Items with Fast Shipping
```
Subtotal: $2,000.00
Shipping: FREE
Delivery Fee: $15.00
Fast Shipping Fee: $700.00 (2 items × $350.00)
Total: $2,715.00
```

## Order Payload Impact

The updated order payload now includes the fast shipping fee in the totals:

```json
{
  "sub_total": 2000.00,
  "shipping_total": 0,
  "order_total": 2715.00,
  "grand_total": 2715.00,
  "products": [
    {
      "product_id": 123,
      "quantity": 1,
      "price": 1000.00,
      "item_shipping_method": "expedited"
    },
    {
      "product_id": 456,
      "quantity": 1,
      "price": 1000.00,
      "item_shipping_method": "expedited"
    }
  ]
}
```

## Technical Notes

### Currency Handling
- The fast shipping fee is calculated in the cart's base currency
- No additional currency conversion is needed as it's already in the correct currency
- The fee is included in the total calculation before any final currency formatting

### Performance Considerations
- The calculation is performed on-demand when the cart is accessed
- No caching is implemented as cart items can change frequently
- The calculation is lightweight and runs in O(n) time where n is the number of cart items

### Error Handling
- Null safety is maintained with null-aware operators
- If a product doesn't have an expedited shipping price, it defaults to 0.0
- If an item doesn't have a product reference, it's skipped

## Testing Scenarios

To test the implementation:

1. **Add products with expedited shipping** to cart
2. **Select fast shipping** for some items
3. **Verify order summary** shows "Fast Shipping Fee" line item
4. **Check total calculation** includes the fast shipping fee
5. **Verify order payload** has correct totals including fast shipping fee
6. **Test mixed scenarios** with some items having fast shipping and others not

## Backward Compatibility

- The implementation is fully backward compatible
- Existing orders without fast shipping will continue to work
- The fast shipping fee line item only appears when there's actually a fee to display
- No changes to existing API contracts are required
