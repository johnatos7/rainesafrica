import 'package:flutter_riverpod_clean_architecture/features/currency/domain/entities/currency_entity.dart';

class CurrencyModel {
  final int id;
  final String code;
  final String symbol;
  final int noOfDecimal;
  final String exchangeRate;
  final String symbolPosition;
  final String thousandsSeparator;
  final String decimalSeparator;
  final int systemReserve;
  final int status;
  final dynamic createdById;
  final String createdAt;
  final String updatedAt;
  final dynamic deletedAt;

  CurrencyModel({
    required this.id,
    required this.code,
    required this.symbol,
    required this.noOfDecimal,
    required this.exchangeRate,
    required this.symbolPosition,
    required this.thousandsSeparator,
    required this.decimalSeparator,
    required this.systemReserve,
    required this.status,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  // Convert model to entity
  CurrencyEntity toEntity() {
    return CurrencyEntity(
      id: id,
      code: code,
      symbol: symbol,
      noOfDecimal: noOfDecimal,
      exchangeRate: exchangeRate,
      symbolPosition: symbolPosition,
      thousandsSeparator: thousandsSeparator,
      decimalSeparator: decimalSeparator,
      systemReserve: systemReserve,
      status: status,
      createdById: createdById,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      symbol: json['symbol'] as String,
      noOfDecimal: (json['no_of_decimal'] as num).toInt(),
      exchangeRate: json['exchange_rate'] as String,
      symbolPosition: json['symbol_position'] as String,
      thousandsSeparator: json['thousands_separator'] as String,
      decimalSeparator: json['decimal_separator'] as String,
      systemReserve: (json['system_reserve'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      createdById: json['created_by_id'],
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      deletedAt: json['deleted_at'],
    );
  }
}

class PaginatedCurrencyResponse {
  final int currentPage;
  final List<CurrencyModel> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<PaginationLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  PaginatedCurrencyResponse({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory PaginatedCurrencyResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedCurrencyResponse(
      currentPage: (json['current_page'] as num).toInt(),
      data:
          (json['data'] as List<dynamic>)
              .map((e) => CurrencyModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      firstPageUrl: json['first_page_url'] as String,
      from: (json['from'] as num).toInt(),
      lastPage: (json['last_page'] as num).toInt(),
      lastPageUrl: json['last_page_url'] as String,
      links:
          (json['links'] as List<dynamic>)
              .map((e) => PaginationLink.fromJson(e as Map<String, dynamic>))
              .toList(),
      nextPageUrl: json['next_page_url'] as String?,
      path: json['path'] as String,
      perPage:
          (json['per_page'] is String)
              ? int.tryParse(json['per_page'] as String) ?? 0
              : (json['per_page'] as num).toInt(),
      prevPageUrl: json['prev_page_url'] as String?,
      to: (json['to'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );
  }
}

class PaginationLink {
  final String? url;
  final String label;
  final bool active;

  PaginationLink({
    required this.url,
    required this.label,
    required this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'] as String?,
      label: json['label'] as String,
      active: json['active'] as bool,
    );
  }
}
