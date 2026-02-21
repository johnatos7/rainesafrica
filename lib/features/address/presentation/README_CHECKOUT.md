# Checkout Address Selection Feature

A comprehensive checkout address selection system that allows users to select shipping and billing addresses for their orders, with the option to use the same address for both.

## 🎯 Features

### Core Functionality
- ✅ **Shipping Address Selection**: Choose delivery address from saved addresses
- ✅ **Billing Address Selection**: Choose billing address from saved addresses  
- ✅ **Same Address Option**: Use shipping address as billing address
- ✅ **Address Management**: Add, edit, delete addresses during checkout
- ✅ **Address Validation**: Ensure both addresses are selected before proceeding
- ✅ **Address Summary**: Review selected addresses before placing order

### UI Components
- ✅ **CheckoutAddressSelectionScreen**: Main address selection interface
- ✅ **CheckoutAddressSummaryWidget**: Display selected addresses
- ✅ **QuickAddressSelectionWidget**: Quick address selection for simple flows
- ✅ **CheckoutScreen**: Complete checkout flow with address selection
- ✅ **ExampleCheckoutUsage**: Integration examples

## 📱 Usage Examples

### 1. Basic Address Selection

```dart
// Navigate to address selection
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => CheckoutAddressSelectionScreen(
      onAddressesSelected: (shipping, billing) {
        // Handle selected addresses
        print('Shipping: ${shipping?.title}');
        print('Billing: ${billing?.title}');
      },
    ),
  ),
);
```

### 2. Pre-populated Address Selection

```dart
// With initial addresses
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => CheckoutAddressSelectionScreen(
      initialShippingAddress: currentShippingAddress,
      initialBillingAddress: currentBillingAddress,
      onAddressesSelected: (shipping, billing) {
        // Update addresses
        ref.read(checkoutAddressProvider.notifier).setBothAddresses(shipping, billing);
      },
    ),
  ),
);
```

### 3. Address Summary Widget

```dart
// Display address summary
CheckoutAddressSummaryWidget(
  onEdit: () => _navigateToAddressSelection(),
  title: 'Delivery Addresses',
)
```

### 4. Quick Address Selection

```dart
// Quick selection widget
QuickAddressSelectionWidget(
  title: 'Select Addresses',
  onSelect: () => _navigateToAddressSelection(),
)
```

### 5. Complete Checkout Flow

```dart
// Full checkout screen
class MyCheckoutScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CheckoutScreen();
  }
}
```

## 🔄 State Management

### Checkout Address Providers

```dart
// Main state provider
final checkoutAddressProvider = StateNotifierProvider<CheckoutAddressNotifier, CheckoutAddressState>(...);

// Derived providers
final shippingAddressProvider = Provider<AddressEntity?>(...);
final billingAddressProvider = Provider<AddressEntity?>(...);
final useSameAddressProvider = Provider<bool>(...);
final checkoutAddressCompleteProvider = Provider<bool>(...);
```

### State Management Methods

```dart
// Set addresses
ref.read(checkoutAddressProvider.notifier).setShippingAddress(address);
ref.read(checkoutAddressProvider.notifier).setBillingAddress(address);
ref.read(checkoutAddressProvider.notifier).setBothAddresses(shipping, billing);

// Toggle same address
ref.read(checkoutAddressProvider.notifier).setUseSameAddress(true);

// Clear addresses
ref.read(checkoutAddressProvider.notifier).clearAddresses();
```

## 🎨 UI Components

### CheckoutAddressSelectionScreen
Main screen for selecting shipping and billing addresses:

**Features:**
- Shipping address selection with country/state dropdowns
- Billing address selection (can be same as shipping)
- "Use same address" checkbox
- Address summary display
- Continue button (enabled when both addresses selected)

**Usage:**
```dart
CheckoutAddressSelectionScreen(
  initialShippingAddress: shippingAddress,
  initialBillingAddress: billingAddress,
  onAddressesSelected: (shipping, billing) {
    // Handle selection
  },
)
```

### CheckoutAddressSummaryWidget
Displays selected addresses with edit option:

**Features:**
- Shows shipping and billing addresses
- Edit button to change addresses
- Incomplete state handling
- Address validation display

**Usage:**
```dart
CheckoutAddressSummaryWidget(
  onEdit: () => _navigateToAddressSelection(),
  showEditButton: true,
  title: 'Delivery Addresses',
)
```

### QuickAddressSelectionWidget
Simplified address selection for quick flows:

**Features:**
- Tap to select addresses
- Address preview
- Navigation to full selection screen

**Usage:**
```dart
QuickAddressSelectionWidget(
  title: 'Select Addresses',
  onSelect: () => _navigateToAddressSelection(),
)
```

## 🔧 Configuration

### Address State Management

```dart
// Initialize checkout addresses
ref.read(checkoutAddressProvider.notifier).setBothAddresses(
  shippingAddress,
  billingAddress,
);

// Check if addresses are complete
final isComplete = ref.watch(checkoutAddressCompleteProvider);

// Get validation errors
final errors = ref.watch(checkoutAddressValidationErrorsProvider);
```

### Address Selection Logic

```dart
// Set shipping address
void _setShippingAddress(AddressEntity address) {
  ref.read(checkoutAddressProvider.notifier).setShippingAddress(address);
  
  // If using same address, update billing too
  final state = ref.read(checkoutAddressProvider);
  if (state.useSameAddress) {
    ref.read(checkoutAddressProvider.notifier).setBillingAddress(address);
  }
}

// Toggle same address
void _toggleSameAddress(bool useSame) {
  ref.read(checkoutAddressProvider.notifier).setUseSameAddress(useSame);
}
```

## 📋 Address Selection Flow

### 1. **Address Selection Screen**
- User sees list of saved addresses
- Can select shipping address
- Can select billing address (or use same as shipping)
- Can add new address
- Can edit existing address

### 2. **Address Validation**
- Shipping address must be selected
- Billing address must be selected (unless using same address)
- Addresses must be valid

### 3. **Address Summary**
- Shows selected shipping address
- Shows selected billing address
- Indicates if same address is used for both
- Allows editing addresses

### 4. **Checkout Integration**
- Addresses are passed to checkout flow
- User can proceed to payment
- Addresses are used for order processing

## 🎯 Key Features

### 1. **Same Address Option**
Users can choose to use the same address for both shipping and billing:

```dart
// Enable same address
ref.read(checkoutAddressProvider.notifier).setUseSameAddress(true);

// Check if using same address
final useSame = ref.watch(useSameAddressProvider);
```

### 2. **Address Validation**
Comprehensive validation ensures both addresses are selected:

```dart
// Check if addresses are complete
final isComplete = ref.watch(checkoutAddressCompleteProvider);

// Get validation errors
final errors = ref.watch(checkoutAddressValidationErrorsProvider);
```

### 3. **Address Management**
Users can manage addresses during checkout:

```dart
// Add new address
void _addNewAddress() {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => AddEditAddressScreen(),
    ),
  );
}

// Edit existing address
void _editAddress(AddressEntity address) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => AddEditAddressScreen(address: address),
    ),
  );
}
```

### 4. **Address Summary Display**
Clear display of selected addresses:

```dart
// Show address summary
CheckoutAddressSummaryWidget(
  onEdit: () => _navigateToAddressSelection(),
)
```

## 🔄 Integration with Existing Address System

The checkout address selection integrates seamlessly with the existing address management system:

### 1. **Uses Existing Address Entities**
- `AddressEntity` for address data
- `AddressFormData` for form validation
- Existing address CRUD operations

### 2. **Leverages Address Providers**
- `userAddressesProvider` for address list
- `countriesProvider` for country selection
- `statesProvider` for state selection

### 3. **Reuses Address Components**
- `AddressFormWidget` for address editing
- `AddressManagementWidget` for address display
- `CheckoutAddressSelector` for address selection

## 📱 Complete Checkout Flow Example

```dart
class MyCheckoutFlow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAddressComplete = ref.watch(checkoutAddressCompleteProvider);
    
    return Scaffold(
      body: Column(
        children: [
          // Address Selection
          CheckoutAddressSummaryWidget(
            onEdit: () => _navigateToAddressSelection(context),
          ),
          
          // Payment Selection (placeholder)
          PaymentSelectionWidget(),
          
          // Continue Button
          ElevatedButton(
            onPressed: isAddressComplete ? _proceedToPayment : null,
            child: Text('Continue to Payment'),
          ),
        ],
      ),
    );
  }
  
  void _navigateToAddressSelection(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutAddressSelectionScreen(
          onAddressesSelected: (shipping, billing) {
            ref.read(checkoutAddressProvider.notifier).setBothAddresses(shipping, billing);
          },
        ),
      ),
    );
  }
}
```

## 🎨 UI/UX Features

### 1. **Progress Indicators**
- Step-by-step checkout process
- Visual progress indication
- Clear navigation between steps

### 2. **Address Validation**
- Real-time validation feedback
- Clear error messages
- Disabled states for incomplete forms

### 3. **Address Summary**
- Clear display of selected addresses
- Easy editing options
- Visual confirmation of selections

### 4. **Responsive Design**
- Works on all screen sizes
- Touch-friendly interface
- Accessible design patterns

## 🔧 Customization

### 1. **Theming**
All components use your app's primary color theme:

```dart
// Components automatically use theme colors
CheckoutAddressSelectionScreen() // Uses Theme.of(context).primaryColor
```

### 2. **Customization Options**
- Custom titles and subtitles
- Custom button text
- Custom validation messages
- Custom styling options

### 3. **Integration Points**
- Easy integration with existing checkout flows
- Flexible callback system
- Customizable navigation

## 📚 Documentation

- Complete usage examples provided
- Integration patterns documented
- Customization options explained
- Best practices included

This checkout address selection feature provides a complete solution for handling address selection in your Flutter app's checkout flow, with modern UI, comprehensive functionality, and seamless integration with your existing address management system! 🎯
