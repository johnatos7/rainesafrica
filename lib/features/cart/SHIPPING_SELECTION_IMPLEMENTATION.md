# Shipping Selection Implementation

This document outlines the implementation of shipping selection functionality in the cart, allowing users to choose between standard and expedited shipping for products that support it.

## Overview

The shipping selection feature allows users to:
- Choose between Standard (18+ days, $0.00) and Fast (7 days, $350.00) shipping
- Only shows shipping options for products with `hasExpeditedShipping = true`
- Updates the cart item with the selected shipping method
- Includes the shipping method in the order payload

## Implementation Details

### 1. Product Entity Updates
Added new fields to `ProductEntity`:
- `hasExpeditedShipping` (bool?, nullable)
- `standardShippingDays` (int?, nullable) 
- `expeditedShippingDays` (int?, nullable)
- `standardShippingPrice` (double?, nullable)
- `expeditedShippingPrice` (double?, nullable)

### 2. Cart Item Updates
Added `itemShippingMethod` field to:
- `CartItemEntity` - stores the selected shipping method
- `CartItemModel` - handles JSON serialization/deserialization

### 3. UI Components

#### ShippingSelectionWidget
- Displays shipping options for products with expedited shipping
- Shows Standard and Fast options with days and prices
- Uses radio button selection
- Only appears when `product.hasExpeditedShipping == true`

#### CartItemWidget Updates
- Integrated `ShippingSelectionWidget` for eligible products
- Added `onShippingMethodChanged` callback
- Shows shipping selection below quantity selector

### 4. Data Flow

1. **Product Display**: Products with `hasExpeditedShipping = true` show shipping options
2. **User Selection**: User selects Standard (null) or Fast ("expedited")
3. **Cart Update**: `updateCartItemShippingProvider` updates the cart item
4. **Persistence**: Shipping method is saved to local storage (Hive)
5. **Order Payload**: Shipping method is included in checkout

### 5. Repository Updates

Added `updateCartItemShipping` method to:
- `CartRepository` interface
- `CartHiveRepositoryImpl` implementation
- Updates cart item with selected shipping method

## Order Payload Structure

The order payload now includes `item_shipping_method` for each product:

```json
{
  "billing_address_id": 946,
  "shipping_address_id": 946,
  "payment_method": "pese",
  "delivery_title": "",
  "delivery_description": "Standard Home Delivery | NB: This covers 15km radius from the nearest branch",
  "delivery_price": 15,
  "coupon_code": "",
  "points_amount": 0,
  "wallet_balance": 0,
  "products": [
    {
      "product_id": 785878,
      "variation_id": null,
      "quantity": 1,
      "price": 4078.89,
      "item_shipping_method": null
    },
    {
      "product_id": 785807,
      "variation_id": null,
      "quantity": 1,
      "price": 3373.08,
      "item_shipping_method": "expedited"
    },
    {
      "product_id": 107269,
      "variation_id": null,
      "quantity": 1,
      "price": 7.4,
      "item_shipping_method": null
    }
  ],
  "note": "",
  "currency": "USD",
  "currency_symbol": "$",
  "sub_total": 7459.36,
  "shipping_total": 0,
  "tax_total": 0,
  "order_total": 7824.36,
  "grand_total": 7824.36,
  "return_url": "https://raines.africa/en/account/order/details",
  "cancel_url": "https://raines.africa"
}
```

### Shipping Method Values

- `null` or `"standard"` - Standard shipping (18+ days, $0.00)
- `"expedited"` - Fast shipping (7 days, $350.00)
- `null` - Default for products without expedited shipping option

## Usage

### For Products with Expedited Shipping
1. Product has `hasExpeditedShipping = true`
2. Cart item shows shipping selection widget
3. User can choose between Standard and Fast shipping
4. Selection is saved and included in order payload

### For Products without Expedited Shipping
1. Product has `hasExpeditedShipping = false` or `null`
2. No shipping selection widget is shown
3. `item_shipping_method` is always `null` in order payload

## Files Modified

### Domain Layer
- `lib/features/products/domain/entities/product_entity.dart`
- `lib/features/cart/domain/entities/cart_entity.dart`
- `lib/features/cart/domain/repositories/cart_repository.dart`

### Data Layer
- `lib/features/products/data/models/product_model.dart`
- `lib/features/cart/data/models/cart_model.dart`
- `lib/features/cart/data/repositories/cart_hive_repository_impl.dart`

### Presentation Layer
- `lib/features/cart/presentation/widgets/shipping_selection_widget.dart` (new)
- `lib/features/cart/presentation/widgets/cart_item_widget.dart`
- `lib/features/cart/presentation/screens/cart_screen.dart`
- `lib/features/cart/providers/cart_providers.dart`

## Testing

To test the implementation:

1. **Add products with expedited shipping** to cart
2. **Verify shipping options appear** in cart items
3. **Select different shipping methods** and verify they're saved
4. **Check order payload** includes correct `item_shipping_method` values
5. **Test products without expedited shipping** don't show options

## Future Enhancements

- Add shipping cost calculation to cart totals
- Implement shipping method validation
- Add shipping method to order confirmation
- Support for multiple shipping methods per product
