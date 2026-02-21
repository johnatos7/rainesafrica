import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/domain/entities/currency_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/domain/usecases/get_currencies_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/domain/usecases/get_cached_currencies_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/domain/usecases/get_selected_currency_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/domain/usecases/set_selected_currency_use_case.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart' as geolocator;

// Use case providers
final getCurrenciesUseCaseProvider = Provider<GetCurrenciesUseCase>((ref) {
  return GetCurrenciesUseCase(ref.watch(currencyRepositoryProvider));
});

final getCachedCurrenciesUseCaseProvider = Provider<GetCachedCurrenciesUseCase>(
  (ref) {
    return GetCachedCurrenciesUseCase(ref.watch(currencyRepositoryProvider));
  },
);

final getSelectedCurrencyUseCaseProvider = Provider<GetSelectedCurrencyUseCase>(
  (ref) {
    return GetSelectedCurrencyUseCase(ref.watch(currencyRepositoryProvider));
  },
);

final setSelectedCurrencyUseCaseProvider = Provider<SetSelectedCurrencyUseCase>(
  (ref) {
    return SetSelectedCurrencyUseCase(ref.watch(currencyRepositoryProvider));
  },
);

// Currency state
class CurrencyState {
  final List<CurrencyEntity> currencies;
  final CurrencyEntity? selectedCurrency;
  final bool isLoading;
  final String? error;

  const CurrencyState({
    this.currencies = const [],
    this.selectedCurrency,
    this.isLoading = false,
    this.error,
  });

  CurrencyState copyWith({
    List<CurrencyEntity>? currencies,
    CurrencyEntity? selectedCurrency,
    bool? isLoading,
    String? error,
  }) {
    return CurrencyState(
      currencies: currencies ?? this.currencies,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Currency notifier
class CurrencyNotifier extends StateNotifier<CurrencyState> {
  final GetCurrenciesUseCase _getCurrenciesUseCase;
  final GetCachedCurrenciesUseCase _getCachedCurrenciesUseCase;
  final GetSelectedCurrencyUseCase _getSelectedCurrencyUseCase;
  final SetSelectedCurrencyUseCase _setSelectedCurrencyUseCase;

  CurrencyNotifier(
    this._getCurrenciesUseCase,
    this._getCachedCurrenciesUseCase,
    this._getSelectedCurrencyUseCase,
    this._setSelectedCurrencyUseCase,
  ) : super(const CurrencyState(isLoading: true)) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Load cached currencies first for quick display
    await loadCachedCurrencies();

    // Try to load previously selected currency; if present, we're done
    await loadSelectedCurrency();
    if (state.selectedCurrency != null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    // Otherwise, load from network, then default to USD
    await loadCurrencies();
    await loadSelectedCurrency();

    // If still none selected, try choose based on user's location
    if (state.selectedCurrency == null) {
      await setCurrencyBasedOnLocation();
    }
  }

  Future<void> loadCurrencies() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getCurrenciesUseCase();
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: _getErrorMessage(failure),
        );
      },
      (response) {
        final currencies =
            response.data.map((model) => model.toEntity()).toList();
        state = state.copyWith(
          currencies: currencies,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  /// Public method to reload currencies and ensure a currency is selected
  Future<void> reloadCurrencies() async {
    // First try to load cached currencies for quick fallback
    await loadCachedCurrencies();
    // Then load from network
    await loadCurrencies();

    // If no currency is selected and we have currencies available, try to set a default
    if (state.selectedCurrency == null && state.currencies.isNotEmpty) {
      await loadSelectedCurrency();
      // If still no currency selected after loading, choose based on location
      if (state.selectedCurrency == null && state.currencies.isNotEmpty) {
        await setCurrencyBasedOnLocation();
      }
    }
  }

  Future<void> loadCachedCurrencies() async {
    final result = await _getCachedCurrenciesUseCase();
    result.fold(
      (failure) {
        // Ignore cache failures, just use empty list
      },
      (currencies) {
        state = state.copyWith(currencies: currencies);
      },
    );
  }

  Future<void> loadSelectedCurrency() async {
    final result = await _getSelectedCurrencyUseCase();
    result.fold(
      (failure) {
        // If no selected currency, default to USD if available
        if (state.currencies.isNotEmpty) {
          final usdCurrency = state.currencies.firstWhere(
            (currency) => currency.code == 'USD',
            orElse: () => state.currencies.first,
          );
          setSelectedCurrency(usdCurrency);
        } else {
          // No currencies available and no selected currency, stop loading
          state = state.copyWith(isLoading: false);
        }
      },
      (currency) {
        state = state.copyWith(selectedCurrency: currency, isLoading: false);
      },
    );
  }

  Future<void> setSelectedCurrency(CurrencyEntity currency) async {
    final result = await _setSelectedCurrencyUseCase(currency);
    result.fold(
      (failure) {
        state = state.copyWith(
          error: _getErrorMessage(failure),
          isLoading: false,
        );
      },
      (_) {
        state = state.copyWith(selectedCurrency: currency, isLoading: false);
      },
    );
  }

  // Attempts to detect the user's country and set a suitable currency.
  // ZA -> ZAR, ZM -> ZMW, ZW -> USD, else USD.
  Future<void> setCurrencyBasedOnLocation() async {
    try {
      // Ensure we have permission
      final permission = await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied) {
        await geolocator.Geolocator.requestPermission();
      }

      final serviceEnabled =
          await geolocator.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Can't proceed; fall back to USD below
        _selectByCodeOrUsd('USD');
        return;
      }

      final position = await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.low,
      );

      final placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        _selectByCodeOrUsd('USD');
        return;
      }

      final iso2 = (placemarks.first.isoCountryCode ?? '').toUpperCase();
      final currencyCode = _mapCountryIso2ToCurrency(iso2);
      _selectByCodeOrUsd(currencyCode);
    } catch (_) {
      // Any failure falls back to USD
      _selectByCodeOrUsd('USD');
    }
  }

  String _mapCountryIso2ToCurrency(String iso2) {
    switch (iso2) {
      case 'ZA':
        return 'ZAR';
      case 'ZM':
        return 'ZMW';
      case 'ZW':
        return 'USD';
      default:
        return 'USD';
    }
  }

  void _selectByCodeOrUsd(String preferredCode) {
    if (state.currencies.isEmpty) {
      // No currencies available, stop loading
      state = state.copyWith(isLoading: false);
      return;
    }
    final match = state.currencies.firstWhere(
      (c) => c.code.toUpperCase() == preferredCode.toUpperCase(),
      orElse:
          () => state.currencies.firstWhere(
            (c) => c.code.toUpperCase() == 'USD',
            orElse: () => state.currencies.first,
          ),
    );
    // Fire and forget; error already handled in setSelectedCurrency
    // ignore: discarded_futures
    setSelectedCurrency(match);
  }

  String _getErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Network error: ${failure.message}';
    } else if (failure is ServerFailure) {
      return 'Server error: ${failure.message}';
    } else if (failure is CacheFailure) {
      return 'Cache error: ${failure.message}';
    } else {
      return 'An unexpected error occurred';
    }
  }

  // Helper method to format price with current currency
  String formatPrice(double price) {
    if (state.selectedCurrency != null) {
      return state.selectedCurrency!.formatPrice(price);
    }
    // Fallback to USD formatting
    return '\$${price.toStringAsFixed(2)}';
  }
}

// Currency provider
final currencyProvider = StateNotifierProvider<CurrencyNotifier, CurrencyState>(
  (ref) {
    return CurrencyNotifier(
      ref.watch(getCurrenciesUseCaseProvider),
      ref.watch(getCachedCurrenciesUseCaseProvider),
      ref.watch(getSelectedCurrencyUseCaseProvider),
      ref.watch(setSelectedCurrencyUseCaseProvider),
    );
  },
);

// Convenience providers
final selectedCurrencyProvider = Provider<CurrencyEntity?>((ref) {
  return ref.watch(currencyProvider).selectedCurrency;
});

final currenciesProvider = Provider<List<CurrencyEntity>>((ref) {
  return ref.watch(currencyProvider).currencies;
});

final currencyFormattingProvider = Provider<String Function(double)>((ref) {
  final notifier = ref.watch(currencyProvider.notifier);
  return notifier.formatPrice;
});
