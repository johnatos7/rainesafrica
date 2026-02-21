import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/usecases/get_countries_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';

// Address providers - Load addresses from user data instead of direct API call
final userAddressesProvider = FutureProvider<List<AddressEntity>>((ref) async {
  final authState = ref.watch(authProvider);

  // If user is not authenticated, return empty list instead of throwing error
  if (!authState.isAuthenticated || authState.user == null) {
    return [];
  }

  // Get addresses from user data
  final user = authState.user!;
  print("############################");
  print(user.address);
  return user.address;
});

// Provider to refresh user data when addresses are updated
final refreshUserAddressesProvider = Provider<void Function()>((ref) {
  return () {
    // Invalidate both the auth provider and userAddressesProvider to refresh user data
    ref.invalidate(authProvider);
    ref.invalidate(userAddressesProvider);
    // Also invalidate the default address provider since it depends on userAddressesProvider
    ref.invalidate(defaultAddressProvider);

    // Reload user profile data to ensure all user information is up to date
    // Use unawaited to avoid blocking the UI
    ref.read(authProvider.notifier).reloadUser().catchError((e) {
      print('Error reloading user data: $e');
      // Continue even if reload fails - the invalidation above should still work
    });
  };
});

// Default address provider
final defaultAddressProvider = Provider<AddressEntity?>((ref) {
  final addressesAsync = ref.watch(userAddressesProvider);
  return addressesAsync.when(
    data: (addresses) {
      if (addresses.isEmpty) return null;

      // Try to find default address first
      try {
        return addresses.firstWhere((address) => address.isDefaultAddress);
      } catch (e) {
        // If no default address found, return the first one
        return addresses.first;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Countries provider
final countriesProvider = FutureProvider<List<CountryEntity>>((ref) async {
  final getCountriesUseCase = ref.watch(getCountriesUseCaseProvider);
  final result = await getCountriesUseCase.execute();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (countries) => countries,
  );
});

// States provider for a specific country
final statesProvider = FutureProvider.family<List<StateEntity>, int>((
  ref,
  countryId,
) async {
  final getStatesUseCase = ref.watch(getStatesByCountryUseCaseProvider);
  final result = await getStatesUseCase.execute(countryId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (states) => states,
  );
});

// Address form state provider
final addressFormProvider =
    StateNotifierProvider<AddressFormNotifier, AddressFormData>((ref) {
      return AddressFormNotifier();
    });

// Address form notifier
class AddressFormNotifier extends StateNotifier<AddressFormData> {
  AddressFormNotifier() : super(AddressFormData.empty());

  void updateTitle(String title) {
    print('DEBUG: updateTitle called with: "$title"');
    state = state.copyWith(title: title);
    print('DEBUG: Title updated in state: "${state.title}"');
  }

  void updateStreet(String street) {
    print('DEBUG: updateStreet called with: "$street"');
    state = state.copyWith(street: street);
    print('DEBUG: Street updated in state: "${state.street}"');
  }

  void updateCity(String city) {
    print('DEBUG: updateCity called with: "$city"');
    state = state.copyWith(city: city);
    print('DEBUG: City updated in state: "${state.city}"');
  }

  void updatePincode(String? pincode) {
    print('DEBUG: updatePincode called with: "$pincode"');
    state = state.copyWith(pincode: pincode);
    print('DEBUG: Pincode updated in state: "${state.pincode}"');
  }

  void updateCountryCode(String countryCode) {
    print('DEBUG: updateCountryCode called with: "$countryCode"');
    state = state.copyWith(countryCode: countryCode);
    print('DEBUG: Country code updated in state: "${state.countryCode}"');
  }

  void updatePhone(String phone) {
    print('DEBUG: updatePhone called with: "$phone"');
    state = state.copyWith(phone: phone);
    print('DEBUG: Phone updated in state: "${state.phone}"');
  }

  void updateCountry(int countryId) {
    print('DEBUG: updateCountry called with: $countryId');
    state = state.copyWith(countryId: countryId);
    print('DEBUG: Country ID updated in state: ${state.countryId}');
  }

  void updateState(int stateId) {
    print('DEBUG: updateState called with: $stateId');
    state = state.copyWith(stateId: stateId);
    print('DEBUG: State ID updated in state: ${state.stateId}');
  }

  void updateType(int? type) {
    print('DEBUG: updateType called with: $type');
    state = state.copyWith(type: type);
    print('DEBUG: Type updated in state: ${state.type}');
  }

  void loadFromAddress(AddressEntity address) {
    print('DEBUG: loadFromAddress called with: $address');
    state = AddressFormData.fromAddress(address);
    print('DEBUG: State loaded from address: $state');
  }

  void reset() {
    print('DEBUG: reset called - clearing form state');
    state = AddressFormData.empty();
    print('DEBUG: Form state reset to empty');
  }

  // Helper method to get country calling code
  String? getCountryCallingCode(List<CountryEntity> countries) {
    if (state.countryId <= 0) return null;
    final country = countries.firstWhere(
      (c) => c.id == state.countryId,
      orElse: () => CountryEntity.empty(),
    );
    return country.isEmpty ? null : country.callingCode;
  }

  // Validate the form and return true if valid
  bool validateForm() {
    print('DEBUG: validateForm called');
    print('DEBUG: Current state: $state');
    print('DEBUG: isValid: ${state.isValid}');
    print('DEBUG: Validation errors: ${state.validationErrors}');
    return state.isValid;
  }

  // Check if the form has any changes from the initial empty state
  bool hasChanges() {
    print('DEBUG: hasChanges called');
    final emptyForm = AddressFormData.empty();
    final hasChanges = state != emptyForm;
    print('DEBUG: Form has changes: $hasChanges');
    return hasChanges;
  }
}

// Address form validation provider
final addressFormValidationProvider = Provider<bool>((ref) {
  final formData = ref.watch(addressFormProvider);
  return formData.isValid;
});

// Address form errors provider
final addressFormErrorsProvider = Provider<List<String>>((ref) {
  final formData = ref.watch(addressFormProvider);
  return formData.validationErrors;
});
