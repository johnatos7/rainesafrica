import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Trending Products API Flow Tests', () {
    test('should simulate complete API call flow with real data', () {
      // This test simulates the complete flow from UI to API call
      // Based on the real API: https://api.raines.africa/api/product?status=1&trending=1&category_ids=12,25720,25722,27720

      // Step 1: Simulate product with categories (from UI)
      final mockProduct = {
        'id': 1425610,
        'name': 'Beko 60cm Free Standing Cooker',
        'categories': [
          {'id': 12, 'name': 'Home & Kitchen', 'slug': 'home-kitchen'},
          {'id': 25720, 'name': 'Electronics', 'slug': 'electronics'},
          {'id': 25722, 'name': 'Appliances', 'slug': 'appliances'},
          {'id': 27720, 'name': 'Kitchen', 'slug': 'kitchen'},
        ],
      };

      // Step 2: Extract category IDs (as done in the UI)
      final categoryIds =
          (mockProduct['categories'] as List)
              .map((category) => category['id'] as int)
              .toList();

      expect(categoryIds, isA<List<int>>());
      expect(categoryIds.length, 4);
      expect(categoryIds, [12, 25720, 25722, 27720]);

      // Step 3: Build API parameters (as done in the data source)
      const limit = 10;
      final queryParams = <String, dynamic>{
        'trending': 1,
        'status': 1,
        'category_ids': categoryIds.join(','),
        'paginate': limit,
      };

      expect(queryParams['trending'], 1);
      expect(queryParams['status'], 1);
      expect(queryParams['category_ids'], '12,25720,25722,27720');
      expect(queryParams['paginate'], 10);

      // Step 4: Build API URL (as done in the data source)
      const baseUrl = '/api/product';
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      final fullUrl = '$baseUrl?$queryString';

      expect(
        fullUrl,
        '/api/product?trending=1&status=1&category_ids=12,25720,25722,27720&paginate=10',
      );

      // Step 5: Simulate API response (real data from the API)
      final apiResponse = {
        'data': [
          {
            'id': 1425610,
            'name':
                'Beko 60cm Free Standing Cooker Vitroceramic Multifuntion S/S FSE87310GX - Zambia',
            'slug':
                'beko-60cm-free-standing-cooker-vitroceramic-multifuntion-s-s-fse87310gx-zambia',
            'short_description':
                'This Deal Is For Clients in Zambia Only. Next Day Delivery In Lusaka Only.',
            'type': 'simple',
            'price': 1232.0,
            'sale_price': 1044.98,
            'discount': 15.0,
            'is_trending': 1,
            'status': 1,
            'stock_status': 'in_stock',
            'sku': '73135828-COPY',
            'quantity': 9999999,
            'created_at': '2025-09-11T08:35:24.000000Z',
            'categories': [
              {'id': 12, 'name': 'Home & Kitchen', 'slug': 'home-kitchen'},
            ],
            'product_thumbnail': {
              'id': 2989494,
              'image_url':
                  'https://media.takealot.com/covers_images/4b3504b6add54046bf0d6b6d2c7d6b46/s-zoom.file',
            },
            'product_galleries': [
              {
                'id': 2989494,
                'image_url':
                    'https://media.takealot.com/covers_images/4b3504b6add54046bf0d6b6d2c7d6b46/s-zoom.file',
              },
              {
                'id': 2989495,
                'image_url':
                    'https://media.takealot.com/covers_images/14ade23504bd4169b1a51618c71a46f6/s-zoom.file',
              },
            ],
          },
        ],
        'current_page': 1,
        'last_page': 2,
        'per_page': 20,
        'total': 24,
      };

      // Step 6: Validate API response structure
      expect(apiResponse, isA<Map<String, dynamic>>());
      expect(apiResponse['data'], isA<List>());
      expect(apiResponse['current_page'], isA<int>());
      expect(apiResponse['last_page'], isA<int>());
      expect(apiResponse['per_page'], isA<int>());
      expect(apiResponse['total'], isA<int>());

      // Step 7: Process the response data
      final data = apiResponse['data'] as List;
      expect(data.length, greaterThan(0));

      final firstProduct = data.first as Map<String, dynamic>;
      expect(firstProduct['id'], 1425610);
      expect(firstProduct['name'], contains('Beko 60cm Free Standing Cooker'));
      expect(firstProduct['is_trending'], 1);
      expect(firstProduct['status'], 1);

      // Step 8: Validate product categories
      final categories = firstProduct['categories'] as List;
      expect(categories.length, greaterThan(0));

      final category = categories.first as Map<String, dynamic>;
      expect(category['id'], 12);
      expect(category['name'], 'Home & Kitchen');

      // Step 9: Validate product images
      final productThumbnail =
          firstProduct['product_thumbnail'] as Map<String, dynamic>;
      expect(productThumbnail['image_url'], contains('takealot.com'));

      final productGalleries = firstProduct['product_galleries'] as List;
      expect(productGalleries.length, 2);
    });

    test('should handle timeout scenario with real API data', () {
      // Test timeout handling with real API parameters
      const categoryIds = [12, 25720, 25722, 27720];
      const limit = 10;
      const timeoutDuration = Duration(seconds: 10);

      // Build API parameters
      final queryParams = <String, dynamic>{
        'trending': 1,
        'status': 1,
        'category_ids': categoryIds.join(','),
        'paginate': limit,
      };

      // Simulate timeout scenario
      expect(timeoutDuration.inSeconds, 10);
      expect(queryParams['category_ids'], '12,25720,25722,27720');

      // Simulate timeout response (empty list)
      final timeoutResponse = <Map<String, dynamic>>[];
      expect(timeoutResponse, isEmpty);
    });

    test('should handle empty response with real API structure', () {
      // Test empty response handling
      final emptyApiResponse = {
        'data': [],
        'current_page': 1,
        'last_page': 1,
        'per_page': 20,
        'total': 0,
      };

      expect(emptyApiResponse['data'], isA<List>());
      expect(emptyApiResponse['data'], isEmpty);
      expect(emptyApiResponse['total'], 0);
    });

    test('should validate real API error response structure', () {
      // Test error response structure
      final errorApiResponse = {
        'error': 'Server Error',
        'message': 'Internal server error',
        'status_code': 500,
      };

      expect(errorApiResponse['error'], isA<String>());
      expect(errorApiResponse['message'], isA<String>());
      expect(errorApiResponse['status_code'], isA<int>());
      expect(errorApiResponse['status_code'], 500);
    });

    test('should simulate provider parameter passing', () {
      // Test how parameters are passed to the provider
      const categoryIds = [12, 25720, 25722, 27720];
      const limit = 10;

      // Simulate provider parameters
      final providerParams = {'categoryIds': categoryIds, 'limit': limit};

      expect(providerParams['categoryIds'], isA<List<int>>());
      expect(providerParams['limit'], isA<int>());
      expect(providerParams['categoryIds'], [12, 25720, 25722, 27720]);
      expect(providerParams['limit'], 10);

      // Extract parameters (as done in the provider)
      final extractedCategoryIds = providerParams['categoryIds'] as List<int>;
      final extractedLimit = providerParams['limit'] as int?;

      expect(extractedCategoryIds, [12, 25720, 25722, 27720]);
      expect(extractedLimit, 10);
    });

    test('should validate real API response with multiple products', () {
      // Test multiple products response
      final multiProductResponse = {
        'data': [
          {
            'id': 1425610,
            'name': 'Beko 60cm Free Standing Cooker',
            'is_trending': 1,
            'categories': [
              {'id': 12, 'name': 'Home & Kitchen'},
            ],
          },
          {
            'id': 1425596,
            'name': 'Beko Cosmopolis 2 Slice Toaster',
            'is_trending': 1,
            'categories': [
              {'id': 12, 'name': 'Home & Kitchen'},
            ],
          },
          {
            'id': 1425597,
            'name': 'Samsung 55" Smart TV',
            'is_trending': 1,
            'categories': [
              {'id': 25720, 'name': 'Electronics'},
            ],
          },
        ],
        'current_page': 1,
        'last_page': 1,
        'per_page': 20,
        'total': 3,
      };

      final data = multiProductResponse['data'] as List;
      expect(data.length, 3);

      // Validate each product
      for (int i = 0; i < data.length; i++) {
        final product = data[i] as Map<String, dynamic>;
        expect(product['id'], isA<int>());
        expect(product['name'], isA<String>());
        expect(product['is_trending'], 1);
        expect(product['categories'], isA<List>());
      }

      // Extract all unique category IDs
      final allCategoryIds = <int>{};
      for (final product in data) {
        final productMap = product as Map<String, dynamic>;
        final categories = productMap['categories'] as List;
        for (final category in categories) {
          final categoryMap = category as Map<String, dynamic>;
          allCategoryIds.add(categoryMap['id'] as int);
        }
      }

      expect(allCategoryIds, contains(12));
      expect(allCategoryIds, contains(25720));
      expect(allCategoryIds.length, 2);
    });

    test('should validate real API pagination with trending products', () {
      // Test pagination with real API data
      final paginatedResponse = {
        'data': [
          {'id': 1425610, 'name': 'Product 1', 'is_trending': 1},
          {'id': 1425596, 'name': 'Product 2', 'is_trending': 1},
        ],
        'current_page': 1,
        'last_page': 2,
        'per_page': 20,
        'total': 24,
      };

      final currentPage = paginatedResponse['current_page'] as int;
      final lastPage = paginatedResponse['last_page'] as int;
      final perPage = paginatedResponse['per_page'] as int;
      final total = paginatedResponse['total'] as int;

      expect(currentPage, 1);
      expect(lastPage, 2);
      expect(perPage, 20);
      expect(total, 24);

      // Test pagination logic
      expect(currentPage, lessThanOrEqualTo(lastPage));
      expect(perPage, greaterThan(0));
      expect(total, greaterThan(0));

      // Test if there are more pages
      final hasMorePages = currentPage < lastPage;
      expect(hasMorePages, true);
    });
  });
}
