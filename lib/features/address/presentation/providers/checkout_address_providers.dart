import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';

// Checkout address state
class CheckoutAddressState {
  final AddressEntity? shippingAddress;
  final AddressEntity? billingAddress;
  final bool useSameAddress;

  const CheckoutAddressState({
    this.shippingAddress,
    this.billingAddress,
    this.useSameAddress = false,
  });

  CheckoutAddressState copyWith({
    AddressEntity? shippingAddress,
    AddressEntity? billingAddress,
    bool? useSameAddress,
  }) {
    return CheckoutAddressState(
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      useSameAddress: useSameAddress ?? this.useSameAddress,
    );
  }

  bool get isComplete {
    if (useSameAddress) {
      return shippingAddress != null;
    }
    return shippingAddress != null && billingAddress != null;
  }

  bool get hasShippingAddress => shippingAddress != null;
  bool get hasBillingAddress => billingAddress != null;

  // Get the effective billing address (either selected or same as shipping)
  AddressEntity? get effectiveBillingAddress {
    if (useSameAddress) {
      return shippingAddress;
    }
    return billingAddress;
  }

  // Check if addresses are the same
  bool get addressesAreSame {
    if (shippingAddress == null || billingAddress == null) return false;
    return shippingAddress!.id == billingAddress!.id;
  }
}

// Checkout address notifier
class CheckoutAddressNotifier extends StateNotifier<CheckoutAddressState> {
  CheckoutAddressNotifier() : super(const CheckoutAddressState());

  void setShippingAddress(AddressEntity? address) {
    state = state.copyWith(
      shippingAddress: address,
      billingAddress: state.useSameAddress ? address : state.billingAddress,
    );
  }

  void setBillingAddress(AddressEntity? address) {
    state = state.copyWith(billingAddress: address);
  }

  void setUseSameAddress(bool useSame) {
    state = state.copyWith(
      useSameAddress: useSame,
      billingAddress: useSame ? state.shippingAddress : state.billingAddress,
    );
  }

  void setBothAddresses(AddressEntity? shipping, AddressEntity? billing) {
    state = state.copyWith(shippingAddress: shipping, billingAddress: billing);
  }

  void clearAddresses() {
    state = const CheckoutAddressState();
  }

  void clearShippingAddress() {
    state = state.copyWith(
      shippingAddress: null,
      billingAddress: state.useSameAddress ? null : state.billingAddress,
    );
  }

  void clearBillingAddress() {
    state = state.copyWith(billingAddress: null);
  }

  // Helper methods
  void setDefaultShippingAddress(AddressEntity address) {
    setShippingAddress(address);
    if (state.useSameAddress) {
      setBillingAddress(address);
    }
  }

  void setDefaultBillingAddress(AddressEntity address) {
    setBillingAddress(address);
  }

  // Validation methods
  bool canProceedToPayment() {
    return state.isComplete;
  }

  List<String> getValidationErrors() {
    final errors = <String>[];

    if (state.shippingAddress == null) {
      errors.add('Please select a shipping address');
    }

    if (!state.useSameAddress && state.billingAddress == null) {
      errors.add('Please select a billing address');
    }

    return errors;
  }
}

// Provider
final checkoutAddressProvider =
    StateNotifierProvider<CheckoutAddressNotifier, CheckoutAddressState>((ref) {
      return CheckoutAddressNotifier();
    });

// Derived providers
final shippingAddressProvider = Provider<AddressEntity?>((ref) {
  return ref.watch(checkoutAddressProvider).shippingAddress;
});

final billingAddressProvider = Provider<AddressEntity?>((ref) {
  final state = ref.watch(checkoutAddressProvider);
  return state.effectiveBillingAddress;
});

final useSameAddressProvider = Provider<bool>((ref) {
  return ref.watch(checkoutAddressProvider).useSameAddress;
});

final checkoutAddressCompleteProvider = Provider<bool>((ref) {
  return ref.watch(checkoutAddressProvider).isComplete;
});

final checkoutAddressValidationErrorsProvider = Provider<List<String>>((ref) {
  final notifier = ref.watch(checkoutAddressProvider.notifier);
  return notifier.getValidationErrors();
});

// Helper providers for UI
final shippingAddressDisplayProvider = Provider<String>((ref) {
  final address = ref.watch(shippingAddressProvider);
  if (address == null) return 'No shipping address selected';
  return '${address.title} - ${address.shortAddress}';
});

final billingAddressDisplayProvider = Provider<String>((ref) {
  final address = ref.watch(billingAddressProvider);
  if (address == null) return 'No billing address selected';
  return '${address.title} - ${address.shortAddress}';
});

final addressesAreSameProvider = Provider<bool>((ref) {
  final state = ref.watch(checkoutAddressProvider);
  return state.addressesAreSame;
});

// Checkout summary provider
final checkoutAddressSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(checkoutAddressProvider);

  return {
    'shippingAddress':
        state.shippingAddress != null
            ? {
              'id': state.shippingAddress!.id,
              'title': state.shippingAddress!.title,
              'fullAddress': state.shippingAddress!.fullAddress,
            }
            : null,
    'billingAddress':
        state.effectiveBillingAddress != null
            ? {
              'id': state.effectiveBillingAddress!.id,
              'title': state.effectiveBillingAddress!.title,
              'fullAddress': state.effectiveBillingAddress!.fullAddress,
            }
            : null,
    'useSameAddress': state.useSameAddress,
    'isComplete': state.isComplete,
    'validationErrors': ref.watch(checkoutAddressValidationErrorsProvider),
  };
});
