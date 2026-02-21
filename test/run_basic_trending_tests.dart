import 'package:flutter_test/flutter_test.dart';

// Import the basic tests
import 'features/products/trending_products_basic_test.dart' as basic_test;
import 'features/products/trending_products_api_structure_test.dart'
    as api_structure_test;
import 'features/products/trending_products_real_api_test.dart'
    as real_api_test;
import 'features/products/trending_products_api_flow_test.dart'
    as api_flow_test;

void main() {
  group('Trending Products Complete Test Suite', () {
    group('Basic Functionality Tests', () {
      basic_test.main();
    });

    group('API Structure Tests', () {
      api_structure_test.main();
    });

    group('Real API Data Tests', () {
      real_api_test.main();
    });

    group('API Flow Tests', () {
      api_flow_test.main();
    });
  });
}
