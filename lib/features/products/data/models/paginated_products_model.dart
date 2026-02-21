import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/product_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/pagination_model.dart';

class PaginatedProductsModel extends Equatable {
  final List<ProductModel> products;
  final PaginationModel pagination;

  const PaginatedProductsModel({
    required this.products,
    required this.pagination,
  });

  factory PaginatedProductsModel.fromJson(Map<String, dynamic> json) {
    final products =
        (json['data'] as List? ?? [])
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();

    final pagination = PaginationModel.fromJson(json);

    return PaginatedProductsModel(products: products, pagination: pagination);
  }

  Map<String, dynamic> toJson() {
    return {
      'data': products.map((product) => product.toJson()).toList(),
      ...pagination.toJson(),
    };
  }

  @override
  List<Object?> get props => [products, pagination];

  @override
  String toString() {
    return 'PaginatedProductsModel(products: ${products.length}, pagination: $pagination)';
  }
}
