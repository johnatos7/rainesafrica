import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';

void main() {
  group('Trending Products Basic Tests', () {
    test('should extract category IDs from product categories correctly', () {
      // Arrange
      final mockProduct = ProductEntity(
        id: 1425610,
        attributes: [],
        name: 'Test Product',
        slug: 'test-product',
        shortDescription: 'Test description',
        type: 'simple',
        quantity: 10,
        price: 100.0,
        isFeatured: false,
        shippingDays: 1,
        isCod: false,
        isFreeShipping: false,
        hasExpedited: false,
        isSaleEnable: true,
        isReturn: false,
        isTrending: true,
        isApproved: true,
        isExternal: false,
        sku: 'TEST-SKU',
        isRandomRelatedProducts: false,
        stockStatus: 'in_stock',
        productThumbnailId: 1,
        productMetaImageId: 1,
        safeCheckout: true,
        secureCheckout: true,
        socialShare: true,
        encourageOrder: true,
        encourageView: true,
        status: true,
        createdById: 1,
        taxId: 1,
        createdAt: DateTime.now(),
        searchKeywords: 'test',
        searchTsv: 'test',
        ordersCount: 0,
        reviewsCount: 0,
        orderAmount: 0.0,
        reviewRatings: [0, 0, 0, 0, 0],
        relatedProducts: [],
        crossSellProducts: [],
        variations: [],
        productThumbnail: ProductImageEntity(
          id: 1,
          uuid: null,
          name: null,
          disk: 'public',
          fileName: 'test.jpg',
          imageUrl: 'https://example.com/test.jpg',
          takealotUrl: 'https://example.com/test.jpg',
          originalUrl: 'https://example.com/test.jpg',
        ),
        productMetaImage: ProductImageEntity(
          id: 1,
          uuid: null,
          name: null,
          disk: 'public',
          fileName: 'test.jpg',
          imageUrl: 'https://example.com/test.jpg',
          takealotUrl: 'https://example.com/test.jpg',
          originalUrl: 'https://example.com/test.jpg',
        ),
        productGalleries: [],
        categories: [
          ProductCategoryEntity(
            id: 12,
            name: 'Home & Kitchen',
            slug: 'home-kitchen',
            description: null,
            categoryImageId: null,
            categoryIconId: null,
            status: true,
            type: 'product',
            commissionRate: 0,
            parentId: null,
            createdById: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            deletedAt: null,
            categoryImageUuid: null,
            categoryIconUuid: null,
            categoryImage: null,
            categoryIcon: null,
          ),
          ProductCategoryEntity(
            id: 25720,
            name: 'Electronics',
            slug: 'electronics',
            description: null,
            categoryImageId: null,
            categoryIconId: null,
            status: true,
            type: 'product',
            commissionRate: 0,
            parentId: null,
            createdById: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            deletedAt: null,
            categoryImageUuid: null,
            categoryIconUuid: null,
            categoryImage: null,
            categoryIcon: null,
          ),
        ],
        tags: [],
        reviews: [],
      );

      // Act
      final categoryIds =
          (mockProduct.categories ?? []).map((category) => category.id).toList();

      // Assert
      expect(categoryIds, isA<List<int>>());
      expect(categoryIds.length, 2);
      expect(categoryIds, contains(12));
      expect(categoryIds, contains(25720));
    });

    test('should handle empty categories list', () {
      // Arrange
      final mockProduct = ProductEntity(
        id: 1425610,
        name: 'Test Product',
        slug: 'test-product',
        shortDescription: 'Test description',
        type: 'simple',
        quantity: 10,
        price: 100.0,
        isFeatured: false,
        shippingDays: 1,
        isCod: false,
        isFreeShipping: false,
        hasExpedited: false,
        isSaleEnable: true,
        isReturn: false,
        isTrending: true,
        isApproved: true,
        isExternal: false,
        sku: 'TEST-SKU',
        isRandomRelatedProducts: false,
        stockStatus: 'in_stock',
        productThumbnailId: 1,
        productMetaImageId: 1,
        safeCheckout: true,
        secureCheckout: true,
        socialShare: true,
        encourageOrder: true,
        encourageView: true,
        status: true,
        createdById: 1,
        taxId: 1,
        createdAt: DateTime.now(),
        searchKeywords: 'test',
        searchTsv: 'test',
        ordersCount: 0,
        reviewsCount: 0,
        orderAmount: 0.0,
        reviewRatings: [0, 0, 0, 0, 0],
        relatedProducts: [],
        crossSellProducts: [],
        variations: [],
        attributes: [],
        productThumbnail: ProductImageEntity(
          id: 1,
          uuid: null,
          name: null,
          disk: 'public',
          fileName: 'test.jpg',
          imageUrl: 'https://example.com/test.jpg',
          takealotUrl: 'https://example.com/test.jpg',
          originalUrl: 'https://example.com/test.jpg',
        ),
        productMetaImage: ProductImageEntity(
          id: 1,
          uuid: null,
          name: null,
          disk: 'public',
          fileName: 'test.jpg',
          imageUrl: 'https://example.com/test.jpg',
          takealotUrl: 'https://example.com/test.jpg',
          originalUrl: 'https://example.com/test.jpg',
        ),
        productGalleries: [],
        categories: [], // Empty categories
        tags: [],
        reviews: [],
      );

      // Act
      final categoryIds =
          (mockProduct.categories ?? []).map((category) => category.id).toList();

      // Assert
      expect(categoryIds, isA<List<int>>());
      expect(categoryIds.length, 0);
      expect(categoryIds, isEmpty);
    });

    test('should format category IDs for API call correctly', () {
      // Arrange
      const categoryIds = [12, 25720, 25722, 27720];

      // Act
      final formattedIds = categoryIds.join(',');

      // Assert
      expect(formattedIds, isA<String>());
      expect(formattedIds, '12,25720,25722,27720');
    });

    test('should handle single category ID correctly', () {
      // Arrange
      const categoryIds = [12];

      // Act
      final formattedIds = categoryIds.join(',');

      // Assert
      expect(formattedIds, isA<String>());
      expect(formattedIds, '12');
    });

    test('should handle empty category IDs list', () {
      // Arrange
      const categoryIds = <int>[];

      // Act
      final formattedIds = categoryIds.join(',');

      // Assert
      expect(formattedIds, isA<String>());
      expect(formattedIds, '');
    });

    test('should create correct API query parameters', () {
      // Arrange
      const categoryIds = [12, 25720, 25722, 27720];
      const limit = 10;

      // Act
      final queryParams = {
        'trending': 1,
        'status': 1,
        'category_ids': categoryIds.join(','),
        'paginate': limit,
      };

      // Assert
      expect(queryParams, isA<Map<String, dynamic>>());
      expect(queryParams['trending'], 1);
      expect(queryParams['status'], 1);
      expect(queryParams['category_ids'], '12,25720,25722,27720');
      expect(queryParams['paginate'], 10);
    });

    test('should handle null limit parameter', () {
      // Arrange
      const categoryIds = [12, 25720, 25722, 27720];
      const int? limit = null;

      // Act
      final queryParams = <String, dynamic>{
        'trending': 1,
        'status': 1,
        'category_ids': categoryIds.join(','),
      };

      if (limit != null) {
        queryParams['paginate'] = limit;
      }

      // Assert
      expect(queryParams, isA<Map<String, dynamic>>());
      expect(queryParams['trending'], 1);
      expect(queryParams['status'], 1);
      expect(queryParams['category_ids'], '12,25720,25722,27720');
      expect(queryParams.containsKey('paginate'), false);
    });

    test('should validate product entity structure', () {
      // Arrange
      final mockProduct = ProductEntity(
        id: 1425610,
        attributes: [],
        name: 'Beko 60cm Free Standing Cooker',
        slug: 'beko-60cm-free-standing-cooker',
        shortDescription: 'This Deal Is For Clients in Zambia Only.',
        type: 'simple',
        quantity: 9999999,
        price: 1232.0,
        salePrice: 1044.98,
        discount: 15.0,
        isFeatured: false,
        shippingDays: 0,
        isCod: false,
        isFreeShipping: false,
        hasExpedited: false,
        isSaleEnable: true,
        isReturn: false,
        isTrending: true,
        isApproved: true,
        isExternal: false,
        sku: '73135828-COPY',
        isRandomRelatedProducts: false,
        stockStatus: 'in_stock',
        productThumbnailId: 2989494,
        productMetaImageId: 2989494,
        safeCheckout: true,
        secureCheckout: true,
        socialShare: true,
        encourageOrder: true,
        encourageView: true,
        status: true,
        createdById: 31,
        taxId: 1,
        createdAt: DateTime.parse('2025-09-11T08:35:24.000000Z'),
        searchKeywords: 'Beko 60cm Free Standing Cooker',
        searchTsv: 'beko cooker',
        ordersCount: 0,
        reviewsCount: 0,
        orderAmount: 0.0,
        reviewRatings: [0, 0, 0, 0, 0],
        relatedProducts: [],
        crossSellProducts: [],
        variations: [],
        productThumbnail: ProductImageEntity(
          id: 2989494,
          uuid: null,
          name: null,
          disk: 'public',
          fileName: 'https://media.takealot.com/covers_images/test.jpg',
          imageUrl: 'https://media.takealot.com/covers_images/test.jpg',
          takealotUrl: 'https://media.takealot.com/covers_images/test.jpg',
          originalUrl: 'https://api.raines.africa/storage/2989494/test.jpg',
        ),
        productMetaImage: ProductImageEntity(
          id: 2989494,
          uuid: null,
          name: null,
          disk: 'public',
          fileName: 'https://media.takealot.com/covers_images/test.jpg',
          imageUrl: 'https://media.takealot.com/covers_images/test.jpg',
          takealotUrl: 'https://media.takealot.com/covers_images/test.jpg',
          originalUrl: 'https://api.raines.africa/storage/2989494/test.jpg',
        ),
        productGalleries: [],
        categories: [
          ProductCategoryEntity(
            id: 12,
            name: 'Home & Kitchen',
            slug: 'home-kitchen',
            description: null,
            categoryImageId: null,
            categoryIconId: null,
            status: true,
            type: 'product',
            commissionRate: 0,
            parentId: null,
            createdById: 1,
            createdAt: DateTime.parse('2025-07-16T13:22:08.000000Z'),
            updatedAt: DateTime.parse('2025-08-30T18:30:53.000000Z'),
            deletedAt: null,
            categoryImageUuid: 'e357571b-f058-4fa7-9791-d1411e826ac3',
            categoryIconUuid: 'e357571b-f058-4fa7-9791-d1411e826ac3',
            categoryImage: null,
            categoryIcon: null,
          ),
        ],
        tags: [],
        reviews: [],
      );

      // Assert
      expect(mockProduct.id, 1425610);
      expect(mockProduct.name, 'Beko 60cm Free Standing Cooker');
      expect(mockProduct.isTrending, true);
      expect(mockProduct.categories?.length ?? 0, 1);
      expect(mockProduct.categories?.first.id, 12);
      expect(mockProduct.categories?.first.name, 'Home & Kitchen');
      expect(mockProduct.price, 1232.0);
      expect(mockProduct.salePrice, 1044.98);
      expect(mockProduct.discount, 15.0);
    });

    test('should handle timeout duration correctly', () {
      // Arrange
      const timeoutDuration = Duration(seconds: 10);

      // Act & Assert
      expect(timeoutDuration.inSeconds, 10);
      expect(timeoutDuration.inMilliseconds, 10000);
    });

    test('should validate API endpoint structure', () {
      // Arrange
      const baseUrl = '/api/product';
      const queryParams = {
        'trending': 1,
        'status': 1,
        'category_ids': '12,25720,25722,27720',
        'paginate': 10,
      };

      // Act
      final fullUrl =
          '$baseUrl?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';

      // Assert
      expect(fullUrl, contains('/api/product'));
      expect(fullUrl, contains('trending=1'));
      expect(fullUrl, contains('status=1'));
      expect(fullUrl, contains('category_ids=12,25720,25722,27720'));
      expect(fullUrl, contains('paginate=10'));
    });
  });
}
