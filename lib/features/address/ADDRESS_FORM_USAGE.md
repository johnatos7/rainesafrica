# Address Form Usage Guide

This guide explains how to use the address form system for both shipping and billing addresses in the checkout screen.

## Overview

The address form system provides a comprehensive solution for managing user addresses in the checkout flow. It includes:

- **Address Form Widget**: A reusable form for adding/editing addresses
- **Address Management**: Loading and displaying user addresses
- **Checkout Integration**: Seamless integration with the checkout screen
- **Address Types**: Support for both shipping and billing addresses

## Components

### 1. AddressFormWidget

A comprehensive form widget for creating and editing addresses.

```dart
AddressFormWidget(
  initialAddress: address, // Optional: for editing existing address
  submitButtonText: 'Save Address',
  onSaved: () {
    // Handle address save
  },
  onCancel: () {
    // Handle cancel
  },
)
```

**Features:**
- Title, street, city, pincode fields
- Country/state selection with flags
- Phone number with country code
- Form validation
- Customizable submit/cancel buttons

### 2. CheckoutAddressSection

A specialized widget for the checkout screen that displays address selection.

```dart
CheckoutAddressSection(
  title: 'Shipping Address',
  addressType: AddressType.shipping,
  selectedAddress: checkoutState.shippingAddress,
  onAddressSelected: (address) {
    // Handle address selection
  },
  onAddNewAddress: () {
    // Navigate to add address form
  },
)
```

### 3. Address Management

The system provides several providers for address management:

```dart
// Load user addresses from API
final addressesAsync = ref.watch(userAddressesProvider);

// Get default address
final defaultAddress = ref.watch(defaultAddressProvider);

// Load countries for address form
final countriesAsync = ref.watch(countriesProvider);

// Load states for selected country
final statesAsync = ref.watch(statesProvider(countryId));
```

## Usage in Checkout Screen

### 1. Basic Integration

```dart
class CheckoutScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Shipping Address Section
          CheckoutAddressSection(
            title: 'Shipping Address',
            addressType: AddressType.shipping,
            selectedAddress: checkoutState.shippingAddress,
            onAddressSelected: (address) {
              ref.read(checkoutProvider.notifier).setShippingAddress(address);
            },
            onAddNewAddress: () => _navigateToAddAddress(AddressType.shipping),
          ),
          
          // Billing Address Section
          CheckoutAddressSection(
            title: 'Billing Address',
            addressType: AddressType.billing,
            selectedAddress: checkoutState.billingAddress,
            onAddressSelected: (address) {
              ref.read(checkoutProvider.notifier).setBillingAddress(address);
            },
            onAddNewAddress: () => _navigateToAddAddress(AddressType.billing),
          ),
        ],
      ),
    );
  }
}
```

### 2. Add Address Navigation

```dart
void _navigateToAddAddress(AddressType type) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => AddEditAddressScreen(
        onAddressSaved: (address) {
          // Refresh addresses and set the new address as selected
          ref.invalidate(userAddressesProvider);
          if (type == AddressType.shipping) {
            ref.read(checkoutProvider.notifier).setShippingAddress(address);
          } else {
            ref.read(checkoutProvider.notifier).setBillingAddress(address);
          }
          Navigator.of(context).pop();
        },
      ),
    ),
  );
}
```

### 3. Address Form in Modal

```dart
void _showAddAddressForm(AddressType type) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Add ${type.name} Address',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(),
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: AddressFormWidget(
                submitButtonText: 'Save ${type.name} Address',
                onSaved: () {
                  // Refresh addresses
                  ref.invalidate(userAddressesProvider);
                  Navigator.of(context).pop();
                },
                onCancel: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```

## Address Models

### AddressEntity

The main address entity with all necessary fields:

```dart
class AddressEntity {
  final int id;
  final String title;
  final int userId;
  final String street;
  final String city;
  final String? pincode;
  final int isDefault;
  final String countryCode;
  final int phone;
  final int countryId;
  final int stateId;
  final CountryEntity? country;
  final StateEntity? state;
}
```

### AddressFormData

Form data for creating/updating addresses:

```dart
class AddressFormData {
  final String title;
  final String street;
  final String city;
  final String? pincode;
  final String countryCode;
  final String phone;
  final int countryId;
  final int stateId;
  final int? type; // Optional type field
}
```

## API Integration

### Endpoints Used

1. **GET /api/address** - Get user addresses
2. **POST /api/address** - Create new address
3. **PUT /api/address/{id}** - Update address
4. **DELETE /api/address/{id}** - Delete address
5. **PATCH /api/address/{id}/set-default** - Set default address
6. **GET /api/country** - Get countries with states

### Request Format

```json
{
  "title": "Home",
  "street": "123 Main Street",
  "city": "Harare",
  "country_id": 716,
  "state_id": 3923,
  "phone": "716876033",
  "country_code": "263",
  "pincode": "12345",
  "type": null
}
```

## State Management

### Providers Available

```dart
// Address data
final userAddressesProvider = FutureProvider<List<AddressEntity>>(...);
final defaultAddressProvider = Provider<AddressEntity?>(...);

// Country data
final countriesProvider = FutureProvider<List<CountryEntity>>(...);
final statesProvider = FutureProvider.family<List<StateEntity>, int>(...);

// Form state
final addressFormProvider = StateNotifierProvider<AddressFormNotifier, AddressFormData>(...);
final addressFormValidationProvider = Provider<bool>(...);
```

### Form State Management

```dart
// Update form fields
ref.read(addressFormProvider.notifier).updateTitle(title);
ref.read(addressFormProvider.notifier).updateStreet(street);
ref.read(addressFormProvider.notifier).updateCity(city);
ref.read(addressFormProvider.notifier).updateCountry(countryId);
ref.read(addressFormProvider.notifier).updateState(stateId);

// Load from existing address
ref.read(addressFormProvider.notifier).loadFromAddress(address);

// Reset form
ref.read(addressFormProvider.notifier).reset();
```

## Validation

The address form includes comprehensive validation:

```dart
// Check if form is valid
final isValid = ref.watch(addressFormValidationProvider);

// Get validation errors
final errors = ref.watch(addressFormErrorsProvider);
```

**Validation Rules:**
- Title is required
- Street address is required
- City is required
- Country must be selected
- State must be selected
- Phone number is required

## Demo Screen

A comprehensive demo screen is available at:
`lib/features/address/presentation/screens/address_form_demo_screen.dart`

This demo shows:
- How to load and display user addresses
- Address selection for shipping and billing
- Using the same address for both shipping and billing
- Adding new addresses using the form
- Address summary display

## Best Practices

1. **Always refresh addresses** after creating/updating addresses:
   ```dart
   ref.invalidate(userAddressesProvider);
   ```

2. **Handle loading and error states** when displaying addresses:
   ```dart
   addressesAsync.when(
     data: (addresses) => _buildAddressList(addresses),
     loading: () => const CircularProgressIndicator(),
     error: (error, stack) => _buildErrorState(error),
   );
   ```

3. **Use proper address types** for shipping and billing:
   ```dart
   enum AddressType { shipping, billing }
   ```

4. **Validate form before submission**:
   ```dart
   if (_formKey.currentState!.validate()) {
     // Submit form
   }
   ```

5. **Provide user feedback** for successful operations:
   ```dart
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
       content: Text('Address saved successfully'),
       backgroundColor: Colors.green,
     ),
   );
   ```

## Troubleshooting

### Common Issues

1. **Addresses not loading**: Check if the user is authenticated and the API is accessible
2. **Form validation failing**: Ensure all required fields are filled
3. **Country/state not loading**: Check network connection and API endpoints
4. **Address not saving**: Verify the form data is valid and the API is responding

### Debug Tips

1. Check the console for API errors
2. Verify the address form data before submission
3. Ensure the user is authenticated before making API calls
4. Check network connectivity for country/state data

## Example Implementation

See the complete implementation in:
- `lib/features/checkout/presentation/screens/checkout_screen.dart`
- `lib/features/address/presentation/screens/add_edit_address_screen.dart`
- `lib/features/address/presentation/widgets/address_form_widget.dart`
- `lib/features/address/presentation/screens/address_form_demo_screen.dart`
