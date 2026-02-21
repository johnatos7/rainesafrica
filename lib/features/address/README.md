# Address Management Feature

A comprehensive address management system for the Raines Africa mobile app, supporting user address CRUD operations, country/state selection, and integration with checkout flow.

## 🏗️ Architecture

This feature follows Clean Architecture principles with clear separation of concerns:

```
lib/features/address/
├── data/
│   ├── datasources/
│   │   ├── address_remote_data_source.dart
│   │   └── country_remote_data_source.dart
│   ├── models/
│   │   └── address_model.dart
│   └── repositories/
│       └── address_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── address_entity.dart
│   ├── repositories/
│   │   └── address_repository.dart
│   └── usecases/
│       ├── get_user_addresses_use_case.dart
│       ├── manage_address_use_case.dart
│       └── get_countries_use_case.dart
└── presentation/
    ├── providers/
    │   └── address_providers.dart
    ├── screens/
    │   ├── address_list_screen.dart
    │   ├── add_edit_address_screen.dart
    │   └── account_addresses_tab.dart
    └── widgets/
        ├── address_form_widget.dart
        ├── address_management_widget.dart
        └── checkout_address_selector.dart
```

## 🚀 Features

### Core Functionality
- ✅ **User Address Management**: Create, read, update, delete user addresses
- ✅ **Country/State Selection**: Dynamic country and state dropdowns
- ✅ **Default Address**: Set and manage default addresses
- ✅ **Address Validation**: Comprehensive form validation
- ✅ **Offline Support**: Local caching with network fallback

### UI Components
- ✅ **Reusable Address Form**: Can be used in multiple contexts
- ✅ **Address List Management**: Full CRUD operations with modern UI
- ✅ **Checkout Integration**: Address selection for checkout flow
- ✅ **Account Tab Integration**: Seamless integration with user account

### API Integration
- ✅ **Protected Endpoints**: Bearer token authentication
- ✅ **Country Data**: Integration with `/api/country` endpoint
- ✅ **Address Operations**: Full CRUD with `/api/address` endpoint

## 📱 Usage Examples

### 1. Address Management in Account Tab

```dart
// In your account screen
class AccountScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TabBarView(
      children: [
        // Other tabs...
        const AccountAddressesTab(), // Address management tab
      ],
    );
  }
}
```

### 2. Checkout Address Selection

```dart
class CheckoutScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CheckoutAddressSelector(
      selectedAddress: selectedAddress,
      onAddressChanged: (address) {
        setState(() {
          selectedAddress = address;
        });
      },
      title: 'Delivery Address',
      subtitle: 'Select where you want your order delivered',
    );
  }
}
```

### 3. Standalone Address Form

```dart
class MyAddressForm extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AddressFormWidget(
      onSaved: () {
        // Handle form submission
        Navigator.pop(context);
      },
      onCancel: () {
        Navigator.pop(context);
      },
    );
  }
}
```

### 4. Address Management Widget

```dart
class MyAddressesWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AddressManagementWidget(
      showTitle: true,
      showAddButton: true,
      maxAddresses: 3, // Limit displayed addresses
    );
  }
}
```

## 🔧 API Integration

### Endpoints Used

1. **GET /api/country** - Fetch countries with states
2. **GET /api/address** - Get user addresses
3. **POST /api/address** - Create new address
4. **PUT /api/address/{id}** - Update address
5. **DELETE /api/address/{id}** - Delete address
6. **PATCH /api/address/{id}/set-default** - Set default address

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

### Response Format

```json
{
  "id": 577,
  "title": "Home",
  "user_id": 1015,
  "street": "123 Main Street",
  "city": "Harare",
  "pincode": "12345",
  "is_default": 1,
  "country_code": "263",
  "phone": 716876033,
  "country_id": 716,
  "state_id": 3923,
  "country": {
    "id": 716,
    "name": "Zimbabwe"
  },
  "state": {
    "id": 3923,
    "name": "Harare",
    "country_id": 716
  }
}
```

## 🎨 UI Components

### AddressFormWidget
A reusable form component with:
- Title, street, city, pincode fields
- Country/state selection with flags
- Phone number with country code
- Form validation
- Customizable submit/cancel buttons

### AddressManagementWidget
A comprehensive address management widget with:
- Address list display
- Add/edit/delete operations
- Default address management
- Empty state handling
- Error state handling

### CheckoutAddressSelector
A specialized widget for checkout flow:
- Address selection with radio buttons
- Quick add new address
- Edit existing addresses
- Default address highlighting

## 🔄 State Management

### Providers Available

```dart
// Address data
final userAddressesProvider = FutureProvider<List<AddressEntity>>(...);
final defaultAddressProvider = Provider<AddressEntity?>(...);

// Country data
final countriesProvider = FutureProvider<List<CountryEntity>>(...);
final statesProvider = FutureProvider.family<List<StateEntity>, int>(...);

// Form management
final addressFormProvider = StateNotifierProvider<AddressFormNotifier, AddressFormData>(...);
final addressFormValidationProvider = Provider<bool>(...);
```

### Use Cases

```dart
// Address operations
final getUserAddressesUseCaseProvider = Provider<GetUserAddressesUseCase>(...);
final createAddressUseCaseProvider = Provider<CreateAddressUseCase>(...);
final updateAddressUseCaseProvider = Provider<UpdateAddressUseCase>(...);
final deleteAddressUseCaseProvider = Provider<DeleteAddressUseCase>(...);
final setDefaultAddressUseCaseProvider = Provider<SetDefaultAddressUseCase>(...);

// Country operations
final getCountriesUseCaseProvider = Provider<GetCountriesUseCase>(...);
final getStatesByCountryUseCaseProvider = Provider<GetStatesByCountryUseCase>(...);
```

## 🛡️ Error Handling

The feature includes comprehensive error handling:

- **Network Errors**: Timeout, connection issues
- **Authentication Errors**: Unauthorized access
- **Validation Errors**: Form validation failures
- **Server Errors**: API server issues
- **User Feedback**: SnackBar notifications for all operations

## 🎯 Key Features

### 1. **Dynamic Country/State Selection**
- Fetches countries from API with flags
- States are loaded dynamically based on country selection
- Proper error handling for network issues

### 2. **Address Validation**
- Required field validation
- Phone number format validation
- Country/state selection validation
- Real-time validation feedback

### 3. **Default Address Management**
- Set any address as default
- Visual indicators for default addresses
- Automatic default selection in checkout

### 4. **Reusable Components**
- AddressFormWidget can be used anywhere
- CheckoutAddressSelector for checkout flow
- AddressManagementWidget for account management

### 5. **Modern UI/UX**
- Material Design 3 components
- Consistent theming with primary colors
- Loading states and error handling
- Intuitive user interactions

## 🔧 Configuration

### Theme Integration
The components automatically use your app's primary color theme:

```dart
// In your main app
MaterialApp(
  theme: ThemeData(
    primaryColor: Colors.blue, // Your primary color
    // ... other theme settings
  ),
  // ...
)
```

### API Client Configuration
Make sure your `ApiClient` is configured with Bearer token authentication:

```dart
// In your API client setup
class ApiClient {
  String? _token;
  
  void setToken(String token) {
    _token = token;
  }
  
  Future<dynamic> get(String endpoint) async {
    final headers = {
      if (_token != null) 'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    };
    // ... implementation
  }
}
```

## 📋 Future Enhancements

- [ ] Address geocoding integration
- [ ] Address search and filtering
- [ ] Bulk address operations
- [ ] Address import/export
- [ ] Advanced address validation
- [ ] Address history tracking

## 🧪 Testing

The architecture supports easy testing with mockable dependencies:

```dart
// Example test setup
class MockAddressRepository implements AddressRepository {
  @override
  Future<Either<Failure, List<AddressEntity>>> getUserAddresses() async {
    return Right([/* mock addresses */]);
  }
  // ... other methods
}
```

## 📚 Documentation

- All components are fully documented
- Usage examples provided
- API integration details included
- Error handling patterns documented

This address management feature provides a complete solution for handling user addresses in your Flutter app, with modern UI, comprehensive functionality, and seamless integration with your existing architecture.
