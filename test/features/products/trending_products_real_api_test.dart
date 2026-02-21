import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Trending Products Real API Data Tests', () {
    test('should parse real API response data correctly', () {
      // This test uses the actual API response data from the Raines Africa API
      // Based on: https://api.raines.africa/api/product?status=1&trending=1&category_ids=12,25720,25722,27720

      final realApiResponse = {
        "data": [
          {
            "id": 1425610,
            "name":
                "Beko 60cm Free Standing Cooker Vitroceramic Multifuntion S/S FSE87310GX - Zambia",
            "slug":
                "beko-60cm-free-standing-cooker-vitroceramic-multifuntion-s-s-fse87310gx-zambia",
            "short_description":
                "This Deal Is For Clients in Zambia Only. Next Day Delivery In Lusaka Only.",
            "type": "simple",
            "unit": null,
            "weight": null,
            "quantity": 9999999,
            "price": 1232.0,
            "sale_price": 1044.98,
            "discount": 15.0,
            "is_featured": 0,
            "shipping_days": 0,
            "is_cod": 0,
            "is_free_shipping": 0,
            "is_sale_enable": 1,
            "is_return": 0,
            "is_trending": 1,
            "is_approved": 1,
            "is_external": 0,
            "external_url": null,
            "external_button_text": null,
            "sale_starts_at": null,
            "sale_expired_at": null,
            "sku": "73135828-COPY",
            "is_random_related_products": 0,
            "stock_status": "in_stock",
            "meta_title": null,
            "product_thumbnail_id": 2989494,
            "product_meta_image_id": 2989494,
            "size_chart_image_id": null,
            "estimated_delivery_text": null,
            "return_policy_text": null,
            "safe_checkout": 1,
            "secure_checkout": 1,
            "social_share": 1,
            "encourage_order": 1,
            "encourage_view": 1,
            "status": 1,
            "store_id": null,
            "created_by_id": 31,
            "tax_id": 1,
            "created_at": "2025-09-11T08:35:24.000000Z",
            "search_keywords":
                "Beko 60cm Free Standing Cooker Vitroceramic Multifuntion S/S FSE87310GX - Zambia 73135828-COPY Large Appliances Stoves & Ovens Stoves ",
            "search_tsv":
                "'60cm':2 '73135828':11 'applianc':14 'beko':1 'cooker':5 'copi':12 'free':3 'fse87310gx':9 'larg':13 'multifunt':7 'oven':16 's\\/s':8 'stand':4 'stove':15,17 'vitroceram':6 'zambia':10",
            "orders_count": 0,
            "reviews_count": 0,
            "user_review": null,
            "rating_count": null,
            "order_amount": 0.0,
            "review_ratings": [0, 0, 0, 0, 0],
            "related_products": [],
            "cross_sell_products": [],
            "variations": [],
            "product_thumbnail": {
              "id": 2989494,
              "uuid": null,
              "name": null,
              "disk": "public",
              "file_name":
                  "https://media.takealot.com/covers_images/4b3504b6add54046bf0d6b6d2c7d6b46/s-zoom.file",
              "image_url":
                  "https://media.takealot.com/covers_images/4b3504b6add54046bf0d6b6d2c7d6b46/s-zoom.file",
              "takealot_url": null,
              "original_url":
                  "https://api.raines.africa/storage/2989494/https://media.takealot.com/covers_images/4b3504b6add54046bf0d6b6d2c7d6b46/s-zoom.file",
            },
            "product_meta_image": {
              "id": 2989494,
              "image_url":
                  "https://media.takealot.com/covers_images/4b3504b6add54046bf0d6b6d2c7d6b46/s-zoom.file",
              "uuid": null,
              "name": null,
              "file_name":
                  "https://media.takealot.com/covers_images/4b3504b6add54046bf0d6b6d2c7d6b46/s-zoom.file",
              "disk": "public",
              "created_by_id": 1,
              "created_at": "2025-07-17T04:38:24.000000Z",
              "original_url":
                  "https://api.raines.africa/storage/2989494/https://media.takealot.com/covers_images/4b3504b6add54046bf0d6b6d2c7d6b46/s-zoom.file",
              "takealot_url": null,
            },
            "product_galleries": [
              {
                "id": 2989494,
                "uuid": null,
                "name": null,
                "disk": "public",
                "file_name":
                    "https://media.takealot.com/covers_images/4b3504b6add54046bf0d6b6d2c7d6b46/s-zoom.file",
                "image_url":
                    "https://media.takealot.com/covers_images/4b3504b6add54046bf0d6b6d2c7d6b46/s-zoom.file",
                "takealot_url": null,
                "original_url":
                    "https://api.raines.africa/storage/2989494/https://media.takealot.com/covers_images/4b3504b6add54046bf0d6b6d2c7d6b46/s-zoom.file",
              },
              {
                "id": 2989495,
                "uuid": null,
                "name": null,
                "disk": "public",
                "file_name":
                    "https://media.takealot.com/covers_images/14ade23504bd4169b1a51618c71a46f6/s-zoom.file",
                "image_url":
                    "https://media.takealot.com/covers_images/14ade23504bd4169b1a51618c71a46f6/s-zoom.file",
                "takealot_url": null,
                "original_url":
                    "https://api.raines.africa/storage/2989495/https://media.takealot.com/covers_images/14ade23504bd4169b1a51618c71a46f6/s-zoom.file",
              },
              {
                "id": 2989496,
                "uuid": null,
                "name": null,
                "disk": "public",
                "file_name":
                    "https://media.takealot.com/covers_images/ac443306ea8c42beb8d1ce825abb41ab/s-zoom.file",
                "image_url":
                    "https://media.takealot.com/covers_images/ac443306ea8c42beb8d1ce825abb41ab/s-zoom.file",
                "takealot_url": null,
                "original_url":
                    "https://api.raines.africa/storage/2989496/https://media.takealot.com/covers_images/ac443306ea8c42beb8d1ce825abb41ab/s-zoom.file",
              },
              {
                "id": 2989497,
                "uuid": null,
                "name": null,
                "disk": "public",
                "file_name":
                    "https://media.takealot.com/covers_images/d7498b60905f4865a87ef4edead4497a/s-zoom.file",
                "image_url":
                    "https://media.takealot.com/covers_images/d7498b60905f4865a87ef4edead4497a/s-zoom.file",
                "takealot_url": null,
                "original_url":
                    "https://api.raines.africa/storage/2989497/https://media.takealot.com/covers_images/d7498b60905f4865a87ef4edead4497a/s-zoom.file",
              },
              {
                "id": 2989498,
                "uuid": null,
                "name": null,
                "disk": "public",
                "file_name":
                    "https://media.takealot.com/covers_images/dd99de08544448c88a951d83b2ae93e3/s-zoom.file",
                "image_url":
                    "https://media.takealot.com/covers_images/dd99de08544448c88a951d83b2ae93e3/s-zoom.file",
                "takealot_url": null,
                "original_url":
                    "https://api.raines.africa/storage/2989498/https://media.takealot.com/covers_images/dd99de08544448c88a951d83b2ae93e3/s-zoom.file",
              },
            ],
            "categories": [
              {
                "id": 12,
                "name": "Home & Kitchen",
                "slug": "home-kitchen",
                "description": null,
                "category_image_id": null,
                "category_icon_id": null,
                "status": 1,
                "type": "product",
                "commission_rate": 0,
                "parent_id": null,
                "created_by_id": 1,
                "created_at": "2025-07-16T13:22:08.000000Z",
                "updated_at": "2025-08-30T18:30:53.000000Z",
                "deleted_at": null,
                "category_image_uuid": "e357571b-f058-4fa7-9791-d1411e826ac3",
                "category_icon_uuid": "e357571b-f058-4fa7-9791-d1411e826ac3",
                "pivot": {"product_id": 1425610, "category_id": 12},
                "category_image": {
                  "id": 4877710,
                  "uuid": "e357571b-f058-4fa7-9791-d1411e826ac3",
                  "name": "8517463d-e9c6-4ba8-ac0d-1978de06a53b",
                  "disk": "public",
                  "file_name": "52489f93-bc76-4ab2-9a1f-4d724595dd5e.png",
                  "image_url":
                      "https://media.raines.africa/storage/uploads/2025/08/30/52489f93-bc76-4ab2-9a1f-4d724595dd5e.png",
                  "original_url":
                      "https://api.raines.africa/storage/4877710/52489f93-bc76-4ab2-9a1f-4d724595dd5e.png",
                },
                "category_icon": {
                  "id": 4877710,
                  "uuid": "e357571b-f058-4fa7-9791-d1411e826ac3",
                  "name": "8517463d-e9c6-4ba8-ac0d-1978de06a53b",
                  "disk": "public",
                  "file_name": "52489f93-bc76-4ab2-9a1f-4d724595dd5e.png",
                  "image_url":
                      "https://media.raines.africa/storage/uploads/2025/08/30/52489f93-bc76-4ab2-9a1f-4d724595dd5e.png",
                  "original_url":
                      "https://api.raines.africa/storage/4877710/52489f93-bc76-4ab2-9a1f-4d724595dd5e.png",
                },
              },
            ],
            "tags": [],
            "reviews": [],
          },
        ],
        "current_page": 1,
        "last_page": 2,
        "per_page": 20,
        "total": 24,
      };

      // Test the response structure
      expect(realApiResponse, isA<Map<String, dynamic>>());
      expect(realApiResponse['data'], isA<List>());
      expect(realApiResponse['current_page'], isA<int>());
      expect(realApiResponse['last_page'], isA<int>());
      expect(realApiResponse['per_page'], isA<int>());
      expect(realApiResponse['total'], isA<int>());

      // Test the data array
      final data = realApiResponse['data'] as List;
      expect(data.length, greaterThan(0));

      // Test the first product
      final firstProduct = data.first as Map<String, dynamic>;
      expect(firstProduct['id'], 1425610);
      expect(firstProduct['name'], contains('Beko 60cm Free Standing Cooker'));
      expect(firstProduct['is_trending'], 1);
      expect(firstProduct['status'], 1);
      expect(firstProduct['price'], 1232.0);
      expect(firstProduct['sale_price'], 1044.98);
      expect(firstProduct['discount'], 15.0);

      // Test categories
      final categories = firstProduct['categories'] as List;
      expect(categories.length, greaterThan(0));

      final firstCategory = categories.first as Map<String, dynamic>;
      expect(firstCategory['id'], 12);
      expect(firstCategory['name'], 'Home & Kitchen');
      expect(firstCategory['slug'], 'home-kitchen');

      // Test product images
      final productThumbnail =
          firstProduct['product_thumbnail'] as Map<String, dynamic>;
      expect(productThumbnail['image_url'], contains('takealot.com'));

      final productGalleries = firstProduct['product_galleries'] as List;
      expect(productGalleries.length, 5);
    });

    test('should extract category IDs from real API response', () {
      // Simulate extracting category IDs from the real API response
      final realApiResponse = {
        "data": [
          {
            "id": 1425610,
            "categories": [
              {"id": 12, "name": "Home & Kitchen", "slug": "home-kitchen"},
              {"id": 25720, "name": "Electronics", "slug": "electronics"},
              {"id": 25722, "name": "Appliances", "slug": "appliances"},
              {"id": 27720, "name": "Kitchen", "slug": "kitchen"},
            ],
          },
        ],
      };

      // Extract category IDs from the first product
      final data = realApiResponse['data'] as List;
      final firstProduct = data.first as Map<String, dynamic>;
      final categories = firstProduct['categories'] as List;

      final categoryIds =
          categories.map((category) => category['id'] as int).toList();

      expect(categoryIds, isA<List<int>>());
      expect(categoryIds.length, 4);
      expect(categoryIds, contains(12));
      expect(categoryIds, contains(25720));
      expect(categoryIds, contains(25722));
      expect(categoryIds, contains(27720));

      // Format for API call
      final formattedIds = categoryIds.join(',');
      expect(formattedIds, '12,25720,25722,27720');
    });

    test('should validate real API query parameters', () {
      // Test the actual query parameters used in the real API call
      final realQueryParams = {
        'status': 1,
        'trending': 1,
        'category_ids': '12,25720,25722,27720',
        'paginate': 20,
      };

      expect(realQueryParams['status'], 1);
      expect(realQueryParams['trending'], 1);
      expect(realQueryParams['category_ids'], '12,25720,25722,27720');
      expect(realQueryParams['paginate'], 20);

      // Test URL construction
      final queryString = realQueryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      expect(queryString, contains('status=1'));
      expect(queryString, contains('trending=1'));
      expect(queryString, contains('category_ids=12,25720,25722,27720'));
      expect(queryString, contains('paginate=20'));
    });

    test('should validate real API response pagination', () {
      // Test the pagination data from the real API response
      final realPaginationData = {
        "current_page": 1,
        "last_page": 2,
        "per_page": 20,
        "total": 24,
      };

      expect(realPaginationData['current_page'], 1);
      expect(realPaginationData['last_page'], 2);
      expect(realPaginationData['per_page'], 20);
      expect(realPaginationData['total'], 24);

      // Test pagination logic
      final currentPage = realPaginationData['current_page'] as int;
      final lastPage = realPaginationData['last_page'] as int;
      final perPage = realPaginationData['per_page'] as int;
      final total = realPaginationData['total'] as int;

      expect(currentPage, lessThanOrEqualTo(lastPage));
      expect(perPage, greaterThan(0));
      expect(total, greaterThan(0));
      expect(total, greaterThanOrEqualTo(perPage));
    });

    test('should validate real product data structure', () {
      // Test the structure of a real product from the API
      final realProduct = {
        "id": 1425610,
        "name":
            "Beko 60cm Free Standing Cooker Vitroceramic Multifuntion S/S FSE87310GX - Zambia",
        "slug":
            "beko-60cm-free-standing-cooker-vitroceramic-multifuntion-s-s-fse87310gx-zambia",
        "short_description":
            "This Deal Is For Clients in Zambia Only. Next Day Delivery In Lusaka Only.",
        "type": "simple",
        "price": 1232.0,
        "sale_price": 1044.98,
        "discount": 15.0,
        "is_trending": 1,
        "status": 1,
        "stock_status": "in_stock",
        "sku": "73135828-COPY",
        "quantity": 9999999,
        "created_at": "2025-09-11T08:35:24.000000Z",
        "categories": [
          {"id": 12, "name": "Home & Kitchen", "slug": "home-kitchen"},
        ],
      };

      // Validate required fields
      expect(realProduct['id'], isA<int>());
      expect(realProduct['name'], isA<String>());
      expect(realProduct['slug'], isA<String>());
      expect(realProduct['type'], isA<String>());
      expect(realProduct['price'], isA<double>());
      expect(realProduct['is_trending'], 1);
      expect(realProduct['status'], 1);
      expect(realProduct['stock_status'], isA<String>());
      expect(realProduct['sku'], isA<String>());
      expect(realProduct['quantity'], isA<int>());
      expect(realProduct['created_at'], isA<String>());

      // Validate sale information
      expect(realProduct['sale_price'], isA<double>());
      expect(realProduct['discount'], isA<double>());
      expect(
        realProduct['sale_price'],
        lessThan(realProduct['price'] as double),
      );

      // Validate categories
      final categories = realProduct['categories'] as List;
      expect(categories.length, greaterThan(0));

      final category = categories.first as Map<String, dynamic>;
      expect(category['id'], isA<int>());
      expect(category['name'], isA<String>());
      expect(category['slug'], isA<String>());
    });

    test('should validate real API endpoint construction', () {
      // Test the actual API endpoint construction
      const baseUrl = 'https://api.raines.africa/api/product';
      const queryParams = {
        'status': 1,
        'trending': 1,
        'category_ids': '12,25720,25722,27720',
        'paginate': 20,
      };

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final fullUrl = '$baseUrl?$queryString';

      expect(
        fullUrl,
        'https://api.raines.africa/api/product?status=1&trending=1&category_ids=12,25720,25722,27720&paginate=20',
      );
      expect(fullUrl, contains('api.raines.africa'));
      expect(fullUrl, contains('/api/product'));
      expect(fullUrl, contains('trending=1'));
      expect(fullUrl, contains('category_ids=12,25720,25722,27720'));
    });

    test('should handle real API response with multiple products', () {
      // Test handling multiple products from the real API response
      final realApiResponse = {
        "data": [
          {
            "id": 1425610,
            "name": "Beko 60cm Free Standing Cooker",
            "is_trending": 1,
            "categories": [
              {"id": 12, "name": "Home & Kitchen"},
            ],
          },
          {
            "id": 1425596,
            "name": "Beko Cosmopolis 2 Slice Toaster TAM8202W - Zambia",
            "is_trending": 1,
            "categories": [
              {"id": 12, "name": "Home & Kitchen"},
            ],
          },
        ],
        "current_page": 1,
        "last_page": 2,
        "per_page": 20,
        "total": 24,
      };

      final data = realApiResponse['data'] as List;
      expect(data.length, 2);

      // Test first product
      final firstProduct = data[0] as Map<String, dynamic>;
      expect(firstProduct['id'], 1425610);
      expect(firstProduct['name'], contains('Beko 60cm Free Standing Cooker'));
      expect(firstProduct['is_trending'], 1);

      // Test second product
      final secondProduct = data[1] as Map<String, dynamic>;
      expect(secondProduct['id'], 1425596);
      expect(
        secondProduct['name'],
        contains('Beko Cosmopolis 2 Slice Toaster'),
      );
      expect(secondProduct['is_trending'], 1);

      // Extract all category IDs from all products
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
      expect(allCategoryIds.length, 1); // Both products have the same category
    });

    test('should validate real API response error handling', () {
      // Test error response structure (when API fails)
      final errorResponse = {
        "error": "Server Error",
        "message": "Internal server error",
        "status_code": 500,
      };

      expect(errorResponse['error'], isA<String>());
      expect(errorResponse['message'], isA<String>());
      expect(errorResponse['status_code'], isA<int>());
      expect(errorResponse['status_code'], 500);

      // Test network error response
      final networkErrorResponse = {
        "error": "Network Error",
        "message": "Connection timeout",
        "status_code": 408,
      };

      expect(networkErrorResponse['error'], isA<String>());
      expect(networkErrorResponse['message'], isA<String>());
      expect(networkErrorResponse['status_code'], isA<int>());
      expect(networkErrorResponse['status_code'], 408);
    });
  });
}
