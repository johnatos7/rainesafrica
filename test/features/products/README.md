# Trending Products API Tests

This directory contains comprehensive tests for the new `getTrendingProductsByCategoryIds` functionality.

## Test Structure

### 1. Data Source Tests (`data/datasources/product_remote_data_source_test.dart`)
Tests the `ProductRemoteDataSourceImpl.getTrendingProductsByCategoryIds()` method:
- ✅ Successful API calls with valid responses
- ✅ Empty data responses
- ✅ Invalid response formats
- ✅ Network exceptions
- ✅ Parameter handling (null limits, empty category IDs)
- ✅ Category ID formatting (single vs multiple IDs)

### 2. Repository Tests (`data/repositories/product_repository_impl_test.dart`)
Tests the `ProductRepositoryImpl.getTrendingProductsByCategoryIds()` method:
- ✅ Successful repository calls
- ✅ Network connectivity checks
- ✅ Server exceptions handling
- ✅ Network exceptions handling
- ✅ Timeout exceptions handling
- ✅ Generic exceptions handling
- ✅ Empty results handling

### 3. Provider Tests (`providers/trending_products_provider_test.dart`)
Tests the `trendingProductsByCategoryIdsProvider`:
- ✅ Successful provider calls
- ✅ Repository failure handling
- ✅ Exception handling (timeout, generic)
- ✅ Parameter handling
- ✅ Caching behavior
- ✅ Empty results handling

### 4. Integration Tests (`integration/trending_products_integration_test.dart`)
End-to-end tests covering the complete flow:
- ✅ Full API integration with mock HTTP responses
- ✅ Network failure scenarios
- ✅ HTTP error responses
- ✅ Malformed JSON handling
- ✅ Timeout scenarios
- ✅ Empty responses
- ✅ Single and multiple category ID handling

## Running the Tests

### Run All Trending Products Tests
```bash
flutter test test/run_trending_products_tests.dart
```

### Run Individual Test Suites
```bash
# Data Source Tests
flutter test test/features/products/data/datasources/product_remote_data_source_test.dart

# Repository Tests
flutter test test/features/products/data/repositories/product_repository_impl_test.dart

# Provider Tests
flutter test test/features/products/providers/trending_products_provider_test.dart

# Integration Tests
flutter test test/features/products/integration/trending_products_integration_test.dart
```

### Generate Mock Files (if needed)
```bash
flutter packages pub run build_runner build
```

## Test Coverage

The tests cover:

### API Integration
- ✅ Correct API endpoint calls (`/api/product`)
- ✅ Proper query parameters (`trending=1&status=1&category_ids=12,25720,25722,27720`)
- ✅ Category ID formatting (comma-separated)
- ✅ Limit parameter handling

### Error Handling
- ✅ Network failures
- ✅ Server errors (500, 404, etc.)
- ✅ Timeout scenarios (8-10 second timeouts)
- ✅ Malformed JSON responses
- ✅ Empty responses
- ✅ Invalid response formats

### Data Flow
- ✅ Model to Entity conversion
- ✅ Provider caching
- ✅ Repository error propagation
- ✅ UI-friendly error states

### Edge Cases
- ✅ Empty category ID lists
- ✅ Null limit parameters
- ✅ Single vs multiple category IDs
- ✅ Empty product lists
- ✅ Network connectivity checks

## API Format Tested

The tests verify the correct API call format:
```
GET /api/product?trending=1&status=1&category_ids=12,25720,25722,27720&paginate=10
```

This matches the expected API format from the Raines Africa API documentation.

## Mock Data

Tests use realistic mock data based on the actual API response structure, including:
- Product details (name, price, images, etc.)
- Category information
- Product thumbnails and galleries
- Review and rating data

## Dependencies

The tests require:
- `flutter_test` - Core testing framework
- `mockito` - Mocking framework
- `dartz` - Functional programming (Either type)
- `flutter_riverpod` - State management
- `http` - HTTP client mocking

## Notes

- All tests are designed to be fast and isolated
- Mock data is based on real API responses
- Error scenarios are thoroughly tested
- Timeout mechanisms are verified
- Caching behavior is tested
- The tests ensure the endless loading issue is fixed
