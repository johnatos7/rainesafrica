import 'package:equatable/equatable.dart';

class PointsEntity extends Equatable {
  final int id;
  final int consumerId;
  final double balance;
  final PointsTransactionsEntity transactions;

  const PointsEntity({
    required this.id,
    required this.consumerId,
    required this.balance,
    required this.transactions,
  });

  factory PointsEntity.fromJson(Map<String, dynamic> json) {
    return PointsEntity(
      id: json['id'] as int? ?? 0,
      consumerId: json['consumer_id'] as int? ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      transactions: PointsTransactionsEntity.fromJson(
        json['transactions'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consumer_id': consumerId,
      'balance': balance,
      'transactions': transactions.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, consumerId, balance, transactions];
}

class PointsTransactionsEntity extends Equatable {
  final int currentPage;
  final List<PointsTransactionEntity> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<PointsLinkEntity> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  const PointsTransactionsEntity({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory PointsTransactionsEntity.fromJson(Map<String, dynamic> json) {
    return PointsTransactionsEntity(
      currentPage: json['current_page'] as int? ?? 1,
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (e) =>
                    PointsTransactionEntity.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      firstPageUrl: json['first_page_url'] as String? ?? '',
      from: json['from'] as int? ?? 0,
      lastPage: json['last_page'] as int? ?? 1,
      lastPageUrl: json['last_page_url'] as String? ?? '',
      links:
          (json['links'] as List<dynamic>?)
              ?.map((e) => PointsLinkEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nextPageUrl: json['next_page_url'] as String?,
      path: json['path'] as String? ?? '',
      perPage: json['per_page'] as int? ?? 10,
      prevPageUrl: json['prev_page_url'] as String?,
      to: json['to'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': data.map((e) => e.toJson()).toList(),
      'first_page_url': firstPageUrl,
      'from': from,
      'last_page': lastPage,
      'last_page_url': lastPageUrl,
      'links': links.map((e) => e.toJson()).toList(),
      'next_page_url': nextPageUrl,
      'path': path,
      'per_page': perPage,
      'prev_page_url': prevPageUrl,
      'to': to,
      'total': total,
    };
  }

  @override
  List<Object?> get props => [
    currentPage,
    data,
    firstPageUrl,
    from,
    lastPage,
    lastPageUrl,
    links,
    nextPageUrl,
    path,
    perPage,
    prevPageUrl,
    to,
    total,
  ];
}

class PointsTransactionEntity extends Equatable {
  final int id;
  final int? walletId;
  final int? orderId;
  final int pointId;
  final double amount;
  final String type;
  final String detail;
  final int from;
  final DateTime createdAt;

  const PointsTransactionEntity({
    required this.id,
    this.walletId,
    this.orderId,
    required this.pointId,
    required this.amount,
    required this.type,
    required this.detail,
    required this.from,
    required this.createdAt,
  });

  factory PointsTransactionEntity.fromJson(Map<String, dynamic> json) {
    return PointsTransactionEntity(
      id: json['id'] as int? ?? 0,
      walletId: json['wallet_id'] as int?,
      orderId: json['order_id'] as int?,
      pointId: json['point_id'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
      from: json['from'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'order_id': orderId,
      'point_id': pointId,
      'amount': amount,
      'type': type,
      'detail': detail,
      'from': from,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    walletId,
    orderId,
    pointId,
    amount,
    type,
    detail,
    from,
    createdAt,
  ];
}

class PointsLinkEntity extends Equatable {
  final String? url;
  final String label;
  final bool active;

  const PointsLinkEntity({this.url, required this.label, required this.active});

  factory PointsLinkEntity.fromJson(Map<String, dynamic> json) {
    return PointsLinkEntity(
      url: json['url'] as String?,
      label: json['label'] as String? ?? '',
      active: json['active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'label': label, 'active': active};
  }

  @override
  List<Object?> get props => [url, label, active];
}
