# Updated Order Payload Structure

This document outlines the updated order payload structure that now includes the `item_shipping_method` field for each product, supporting the new shipping selection functionality.

## Order Payload Structure

The order payload now includes the `item_shipping_method` field for each product in the `products` array:

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

## Product Object Structure

Each product in the `products` array now includes the `item_shipping_method` field:

```json
{
  "product_id": 785807,
  "variation_id": null,
  "quantity": 1,
  "price": 3373.08,
  "item_shipping_method": "expedited"
}
```

### Field Descriptions

- **`product_id`** (int): The unique identifier of the product
- **`variation_id`** (int?, nullable): The variation ID if the product has variations
- **`quantity`** (int): The quantity of the product being ordered
- **`price`** (double): The unit price of the product
- **`item_shipping_method`** (string?, nullable): The shipping method selected for this specific product

## Shipping Method Values

The `item_shipping_method` field can have the following values:

### `null` (Standard Shipping)
- **When**: User selects "Standard" shipping or product doesn't support expedited shipping
- **Meaning**: Use standard shipping (18+ days, $0.00)
- **Example**: `"item_shipping_method": null`

### `"expedited"` (Fast Shipping)
- **When**: User selects "Fast" shipping for products that support it
- **Meaning**: Use expedited shipping (7 days, $350.00)
- **Example**: `"item_shipping_method": "expedited"`

### Default Behavior
- **Products without expedited shipping**: Always `null`
- **Products with expedited shipping but no selection**: Defaults to `null` (standard)
- **Products with expedited shipping and user selection**: Uses selected method

## Implementation Details

### Files Modified

1. **CheckoutEntity** (`lib/features/checkout/domain/entities/checkout_entity.dart`)
   - Added `itemShippingMethod` field to `CheckoutProductEntity`

2. **CheckoutModel** (`lib/features/checkout/data/models/checkout_request_model.dart`)
   - Added `itemShippingMethod` field to `CheckoutProductModel`
   - Updated `toJson()` method to include `item_shipping_method`
   - Updated `fromCart()` factory to map shipping method from cart items

3. **CheckoutProviders** (`lib/features/checkout/presentation/providers/checkout_providers.dart`)
   - Updated product mapping to include `itemShippingMethod` from cart items

4. **CheckoutRepository** (`lib/features/checkout/data/repositories/checkout_repository_impl.dart`)
   - Updated request model creation to include shipping method

### Data Flow

1. **Cart Item Creation**: Cart items store `itemShippingMethod` from user selection
2. **Checkout Process**: Cart items are mapped to checkout products with shipping method
3. **API Request**: Checkout products include `item_shipping_method` in JSON payload
4. **Server Processing**: Backend receives shipping method for each product

## Usage Examples

### Example 1: Mixed Shipping Methods
```json
{
  "products": [
    {
      "product_id": 785878,
      "quantity": 1,
      "price": 4078.89,
      "item_shipping_method": null
    },
    {
      "product_id": 785807,
      "quantity": 1,
      "price": 3373.08,
      "item_shipping_method": "expedited"
    }
  ]
}
```

### Example 2: All Standard Shipping
```json
{
  "products": [
    {
      "product_id": 785878,
      "quantity": 1,
      "price": 4078.89,
      "item_shipping_method": null
    },
    {
      "product_id": 785807,
      "quantity": 1,
      "price": 3373.08,
      "item_shipping_method": null
    }
  ]
}
```

### Example 3: All Expedited Shipping
```json
{
  "products": [
    {
      "product_id": 785878,
      "quantity": 1,
      "price": 4078.89,
      "item_shipping_method": "expedited"
    },
    {
      "product_id": 785807,
      "quantity": 1,
      "price": 3373.08,
      "item_shipping_method": "expedited"
    }
  ]
}
```

## Backend Integration

The backend should handle the `item_shipping_method` field as follows:

1. **Parse the field**: Extract `item_shipping_method` from each product
2. **Apply shipping logic**: Use the shipping method to determine delivery time and cost
3. **Calculate totals**: Include expedited shipping costs in order totals if applicable
4. **Store in database**: Save the shipping method with each order item

## Testing

To test the updated payload structure:

1. **Add products with expedited shipping** to cart
2. **Select different shipping methods** for different products
3. **Proceed to checkout** and verify the payload includes correct `item_shipping_method` values
4. **Check API logs** to confirm the field is included in the request
5. **Verify backend processing** handles the new field correctly

## Migration Notes

- **Backward Compatibility**: The field is nullable, so existing orders without this field will continue to work
- **Default Behavior**: Products without the field will default to standard shipping
- **API Versioning**: Consider API versioning if backward compatibility is required
