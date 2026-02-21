import 'package:equatable/equatable.dart';

class PaginationModel extends Equatable {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    final currentPage = json['current_page'] as int? ?? 1;
    final lastPage = json['last_page'] as int? ?? 1;
    final perPage = json['per_page'] as int? ?? 20;
    final total = json['total'] as int? ?? 0;

    return PaginationModel(
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
      total: total,
      hasNextPage: currentPage < lastPage,
      hasPreviousPage: currentPage > 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
    };
  }

  @override
  List<Object?> get props => [
    currentPage,
    lastPage,
    perPage,
    total,
    hasNextPage,
    hasPreviousPage,
  ];

  @override
  String toString() {
    return 'PaginationModel(currentPage: $currentPage, lastPage: $lastPage, perPage: $perPage, total: $total, hasNextPage: $hasNextPage, hasPreviousPage: $hasPreviousPage)';
  }
}
