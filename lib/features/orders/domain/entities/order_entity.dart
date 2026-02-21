import 'order_product_entity.dart';
import 'order_note_entity.dart';

class OrderEntity {
  final int id;
  final int orderNumber;
  final int consumerId;
  final double taxTotal;
  final double shippingTotal;
  final double pointsAmount;
  final double walletBalance;
  final double amount;
  final double total;
  final double couponTotalDiscount;
  final String paymentMethod;
  final String paymentStatus;
  final int? storeId;
  final int billingAddressId;
  final int shippingAddressId;
  final String deliveryDescription;
  final String? deliveryInterval;
  final int orderStatusId;
  final int? couponId;
  final int? parentId;
  final int createdById;
  final String? invoiceUrl;
  final int status;
  final DateTime createdAt;
  final double deliveryPrice;
  final double? fastShippingTotal;
  final String? note;
  final String currency;
  final String currencySymbol;
  final double exchangeRate;
  final ConsumerEntity consumer;
  final OrderStatusEntity orderStatus;
  final List<StatusHistoryEntity> statusHistories;
  final List<SubOrderEntity> subOrders;
  final List<OrderProductEntity> products;
  final List<OrderNoteEntity> notes;
  final OrderSummaryEntity? summary;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.consumerId,
    required this.taxTotal,
    required this.shippingTotal,
    required this.pointsAmount,
    required this.walletBalance,
    required this.amount,
    required this.total,
    required this.couponTotalDiscount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.storeId,
    required this.billingAddressId,
    required this.shippingAddressId,
    required this.deliveryDescription,
    this.deliveryInterval,
    required this.orderStatusId,
    this.couponId,
    this.parentId,
    required this.createdById,
    this.invoiceUrl,
    required this.status,
    required this.createdAt,
    required this.deliveryPrice,
    this.fastShippingTotal,
    this.note,
    required this.currency,
    required this.currencySymbol,
    required this.exchangeRate,
    required this.consumer,
    required this.orderStatus,
    required this.statusHistories,
    required this.subOrders,
    required this.products,
    required this.notes,
    this.summary,
  });

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    // Debug logging to identify null fields
    print('🔍 ORDER JSON DEBUG:');
    print(
      '  - payment_method: ${json['payment_method']} (type: ${json['payment_method'].runtimeType})',
    );
    print(
      '  - payment_status: ${json['payment_status']} (type: ${json['payment_status'].runtimeType})',
    );
    print(
      '  - delivery_description: ${json['delivery_description']} (type: ${json['delivery_description'].runtimeType})',
    );
    print(
      '  - currency: ${json['currency']} (type: ${json['currency'].runtimeType})',
    );
    print(
      '  - currency_symbol: ${json['currency_symbol']} (type: ${json['currency_symbol'].runtimeType})',
    );
    print(
      '  - created_at: ${json['created_at']} (type: ${json['created_at'].runtimeType})',
    );

    return OrderEntity(
      id: json['id'] as int,
      orderNumber: json['order_number'] as int,
      consumerId: json['consumer_id'] as int,
      taxTotal: 0.0, // Always 0 - tax removed from orders
      shippingTotal:
          0.0, // Always 0 - shipping fee removed, delivery fee is separate
      pointsAmount: (json['points_amount'] as num?)?.toDouble() ?? 0.0,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      couponTotalDiscount:
          (json['coupon_total_discount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String? ?? '',
      paymentStatus: json['payment_status'] as String? ?? '',
      storeId: json['store_id'] as int?,
      billingAddressId: json['billing_address_id'] as int? ?? 0,
      shippingAddressId: json['shipping_address_id'] as int? ?? 0,
      deliveryDescription: json['delivery_description'] as String? ?? '',
      deliveryInterval: json['delivery_interval'] as String?,
      orderStatusId: json['order_status_id'] as int? ?? 0,
      couponId: json['coupon_id'] as int?,
      parentId: json['parent_id'] as int?,
      createdById: json['created_by_id'] as int? ?? 0,
      invoiceUrl: json['invoice_url'] as String?,
      status: json['status'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      deliveryPrice: (json['delivery_price'] as num?)?.toDouble() ?? 0.0,
      fastShippingTotal:
          json['fast_shipping_total'] != null
              ? (json['fast_shipping_total'] as num).toDouble()
              : null,
      note: json['note'] as String?,
      currency: json['currency'] as String? ?? 'USD',
      currencySymbol: json['currency_symbol'] as String? ?? '\$',
      exchangeRate: (json['exchange_rate'] as num?)?.toDouble() ?? 1.0,
      consumer:
          json['consumer'] != null
              ? ConsumerEntity.fromJson(
                json['consumer'] as Map<String, dynamic>,
              )
              : const ConsumerEntity(
                id: 0,
                name: '',
                email: '',
                countryCode: '',
                role: RoleEntity(
                  id: 0,
                  name: '',
                  guardName: '',
                  systemReserve: 0,
                ),
              ),
      orderStatus:
          json['order_status'] != null
              ? OrderStatusEntity.fromJson(
                json['order_status'] as Map<String, dynamic>,
              )
              : const OrderStatusEntity(id: 0, name: '', sequence: 0, slug: ''),
      statusHistories:
          (json['status_histories'] as List<dynamic>?)
              ?.map(
                (e) => StatusHistoryEntity.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      subOrders:
          (json['sub_orders'] as List<dynamic>?)
              ?.map((e) => SubOrderEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      products:
          (json['products'] as List<dynamic>?)
              ?.map(
                (e) => OrderProductEntity.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      notes:
          (json['notes'] as List<dynamic>?)
              ?.map((e) => OrderNoteEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary:
          json['summary'] != null && json['summary'] is Map<String, dynamic>
              ? OrderSummaryEntity.fromJson(
                json['summary'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'consumer_id': consumerId,
      'tax_total': taxTotal,
      'shipping_total': shippingTotal,
      'points_amount': pointsAmount,
      'wallet_balance': walletBalance,
      'amount': amount,
      'total': total,
      'coupon_total_discount': couponTotalDiscount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'store_id': storeId,
      'billing_address_id': billingAddressId,
      'shipping_address_id': shippingAddressId,
      'delivery_description': deliveryDescription,
      'delivery_interval': deliveryInterval,
      'order_status_id': orderStatusId,
      'coupon_id': couponId,
      'parent_id': parentId,
      'created_by_id': createdById,
      'invoice_url': invoiceUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'delivery_price': deliveryPrice,
      'fast_shipping_total': fastShippingTotal,
      'note': note,
      'currency': currency,
      'currency_symbol': currencySymbol,
      'exchange_rate': exchangeRate,
      'consumer': consumer.toJson(),
      'order_status': orderStatus.toJson(),
      'status_histories': statusHistories.map((e) => e.toJson()).toList(),
      'sub_orders': subOrders.map((e) => e.toJson()).toList(),
      'products': products.map((e) => e.toJson()).toList(),
      'notes': notes.map((e) => e.toJson()).toList(),
      if (summary != null) 'summary': summary!.toJson(),
    };
  }
}

class OrderSummaryEntity {
  final double subtotal;
  final double shipping;
  final double fastShipping;
  final double delivery;
  final double tax;
  final double grandTotal;
  final double couponDiscount;
  final double pointsUsed;
  final double walletUsed;
  final double totalDiscounts;
  final double finalTotal;
  final double amountToPay;

  const OrderSummaryEntity({
    required this.subtotal,
    required this.shipping,
    required this.fastShipping,
    required this.delivery,
    required this.tax,
    required this.grandTotal,
    required this.couponDiscount,
    required this.pointsUsed,
    required this.walletUsed,
    required this.totalDiscounts,
    required this.finalTotal,
    required this.amountToPay,
  });

  factory OrderSummaryEntity.fromJson(Map<String, dynamic> json) {
    double _d(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
    return OrderSummaryEntity(
      subtotal: _d(json['subtotal']),
      shipping: _d(json['shipping']),
      fastShipping: _d(json['fast_shipping']),
      delivery: _d(json['delivery']),
      tax: _d(json['tax']),
      grandTotal: _d(json['grand_total']),
      couponDiscount: _d(json['coupon_discount']),
      pointsUsed: _d(json['points_used']),
      walletUsed: _d(json['wallet_used']),
      totalDiscounts: _d(json['total_discounts']),
      finalTotal: _d(json['final_total']),
      amountToPay: _d(json['amount_to_pay']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'shipping': shipping,
      'fast_shipping': fastShipping,
      'delivery': delivery,
      'tax': tax,
      'grand_total': grandTotal,
      'coupon_discount': couponDiscount,
      'points_used': pointsUsed,
      'wallet_used': walletUsed,
      'total_discounts': totalDiscounts,
      'final_total': finalTotal,
      'amount_to_pay': amountToPay,
    };
  }
}

class ConsumerEntity {
  final int id;
  final String name;
  final String email;
  final String countryCode;
  final int? phone;
  final RoleEntity role;
  final String? profileImage;

  const ConsumerEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.countryCode,
    this.phone,
    required this.role,
    this.profileImage,
  });

  factory ConsumerEntity.fromJson(Map<String, dynamic> json) {
    // Debug logging for ConsumerEntity
    print('🔍 CONSUMER JSON DEBUG:');
    print('  - name: ${json['name']} (type: ${json['name'].runtimeType})');
    print('  - email: ${json['email']} (type: ${json['email'].runtimeType})');
    print(
      '  - country_code: ${json['country_code']} (type: ${json['country_code'].runtimeType})',
    );

    return ConsumerEntity(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      countryCode: json['country_code'] as String? ?? '',
      phone: json['phone'] as int?,
      role: RoleEntity.fromJson(json['role'] as Map<String, dynamic>),
      profileImage: json['profile_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'country_code': countryCode,
      'phone': phone,
      'role': role.toJson(),
      'profile_image': profileImage,
    };
  }
}

class RoleEntity {
  final int id;
  final String name;
  final String guardName;
  final int systemReserve;

  const RoleEntity({
    required this.id,
    required this.name,
    required this.guardName,
    required this.systemReserve,
  });

  factory RoleEntity.fromJson(Map<String, dynamic> json) {
    // Debug logging for RoleEntity
    print('🔍 ROLE JSON DEBUG:');
    print('  - name: ${json['name']} (type: ${json['name'].runtimeType})');
    print(
      '  - guard_name: ${json['guard_name']} (type: ${json['guard_name'].runtimeType})',
    );

    return RoleEntity(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      guardName: json['guard_name'] as String? ?? '',
      systemReserve: json['system_reserve'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'guard_name': guardName,
      'system_reserve': systemReserve,
    };
  }
}

class OrderStatusEntity {
  final int id;
  final String name;
  final int sequence;
  final String slug;

  const OrderStatusEntity({
    required this.id,
    required this.name,
    required this.sequence,
    required this.slug,
  });

  factory OrderStatusEntity.fromJson(Map<String, dynamic> json) {
    // Debug logging for OrderStatusEntity
    print('🔍 ORDER_STATUS JSON DEBUG:');
    print('  - name: ${json['name']} (type: ${json['name'].runtimeType})');
    print('  - slug: ${json['slug']} (type: ${json['slug'].runtimeType})');

    return OrderStatusEntity(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      sequence: json['sequence'] as int? ?? 0,
      slug: json['slug'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'sequence': sequence, 'slug': slug};
  }
}

class StatusHistoryEntity {
  final int id;
  final String status;
  final DateTime createdAt;

  const StatusHistoryEntity({
    required this.id,
    required this.status,
    required this.createdAt,
  });

  factory StatusHistoryEntity.fromJson(Map<String, dynamic> json) {
    // Debug logging for StatusHistoryEntity
    print('🔍 STATUS_HISTORY JSON DEBUG:');
    print(
      '  - status: ${json['status']} (type: ${json['status'].runtimeType})',
    );
    print(
      '  - created_at: ${json['created_at']} (type: ${json['created_at'].runtimeType})',
    );

    return StatusHistoryEntity(
      id: json['id'] as int,
      status: json['status'] as String? ?? '',
      createdAt:
          DateTime.tryParse(
            json['created_at'] as String? ?? DateTime.now().toIso8601String(),
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class SubOrderEntity {
  final int id;
  final String name;
  final double amount;

  const SubOrderEntity({
    required this.id,
    required this.name,
    required this.amount,
  });

  factory SubOrderEntity.fromJson(Map<String, dynamic> json) {
    // Debug logging for SubOrderEntity
    print('🔍 SUB_ORDER JSON DEBUG:');
    print('  - name: ${json['name']} (type: ${json['name'].runtimeType})');

    return SubOrderEntity(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'amount': amount};
  }
}

class OrderListResponse {
  final int currentPage;
  final List<OrderEntity> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<LinkEntity> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  const OrderListResponse({
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

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    return OrderListResponse(
      currentPage: json['current_page'] as int? ?? 1,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => OrderEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      firstPageUrl: json['first_page_url'] as String? ?? '',
      from: json['from'] as int? ?? 0,
      lastPage: json['last_page'] as int? ?? 1,
      lastPageUrl: json['last_page_url'] as String? ?? '',
      links:
          (json['links'] as List<dynamic>?)
              ?.map((e) => LinkEntity.fromJson(e as Map<String, dynamic>))
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
}

class LinkEntity {
  final String? url;
  final String label;
  final bool active;

  const LinkEntity({this.url, required this.label, required this.active});

  factory LinkEntity.fromJson(Map<String, dynamic> json) {
    return LinkEntity(
      url: json['url'] as String?,
      label: json['label'] as String? ?? '',
      active: json['active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'label': label, 'active': active};
  }
}

class OrderStatusListResponse {
  final int currentPage;
  final List<OrderStatusEntity> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<LinkEntity> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  const OrderStatusListResponse({
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

  factory OrderStatusListResponse.fromJson(Map<String, dynamic> json) {
    return OrderStatusListResponse(
      currentPage: json['current_page'] as int? ?? 1,
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (e) => OrderStatusEntity.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      firstPageUrl: json['first_page_url'] as String? ?? '',
      from: json['from'] as int? ?? 0,
      lastPage: json['last_page'] as int? ?? 1,
      lastPageUrl: json['last_page_url'] as String? ?? '',
      links:
          (json['links'] as List<dynamic>?)
              ?.map((e) => LinkEntity.fromJson(e as Map<String, dynamic>))
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
}
