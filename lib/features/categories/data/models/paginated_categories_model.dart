import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/data/models/category_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/pagination_model.dart';

class PaginatedCategoriesModel extends Equatable {
  final List<CategoryModel> categories;
  final PaginationModel pagination;

  const PaginatedCategoriesModel({
    required this.categories,
    required this.pagination,
  });

  factory PaginatedCategoriesModel.fromJson(Map<String, dynamic> json) {
    final categories =
        (json['data'] as List? ?? [])
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();

    final pagination = PaginationModel.fromJson(json);

    return PaginatedCategoriesModel(
      categories: categories,
      pagination: pagination,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': categories.map((category) => category.toJson()).toList(),
      ...pagination.toJson(),
    };
  }

  @override
  List<Object?> get props => [categories, pagination];

  @override
  String toString() {
    return 'PaginatedCategoriesModel(categories: ${categories.length}, pagination: $pagination)';
  }
}
