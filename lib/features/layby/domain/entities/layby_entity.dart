// ─── Safe JSON parsing helpers ───
double _toDouble(dynamic v, [double fallback = 0.0]) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? fallback;
}

double? _toDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

int _toInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

int? _toIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

/// Layby eligibility check response
class LaybyEligibility {
  final bool eligible;
  final double price;
  final double priceUsd;
  final String currency;
  final double threshold;
  final bool isSaleProduct;
  final int depositPercentage;
  final List<int> availableDurations;

  const LaybyEligibility({
    required this.eligible,
    required this.price,
    required this.priceUsd,
    required this.currency,
    required this.threshold,
    required this.isSaleProduct,
    required this.depositPercentage,
    required this.availableDurations,
  });

  factory LaybyEligibility.fromJson(Map<String, dynamic> json) {
    return LaybyEligibility(
      eligible: json['eligible'] as bool? ?? false,
      price: _toDouble(json['price']),
      priceUsd: _toDouble(json['price_usd']),
      currency: json['currency'] as String? ?? 'USD',
      threshold: _toDouble(json['threshold']),
      isSaleProduct: json['is_sale_product'] as bool? ?? false,
      depositPercentage: _toInt(json['deposit_percentage']),
      availableDurations:
          (json['available_durations'] as List<dynamic>?)
              ?.map((e) => _toInt(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eligible': eligible,
      'price': price,
      'price_usd': priceUsd,
      'currency': currency,
      'threshold': threshold,
      'is_sale_product': isSaleProduct,
      'deposit_percentage': depositPercentage,
      'available_durations': availableDurations,
    };
  }
}

/// Uploaded ID document
class LaybyDocument {
  final int id;
  final int attachmentId;
  final String type;
  final String number;
  final String url;
  final String uploadedAt;

  const LaybyDocument({
    required this.id,
    required this.attachmentId,
    required this.type,
    required this.number,
    required this.url,
    required this.uploadedAt,
  });

  factory LaybyDocument.fromJson(Map<String, dynamic> json) {
    return LaybyDocument(
      id: json['id'] as int,
      attachmentId: json['attachment_id'] as int,
      type: json['type'] as String? ?? '',
      number: json['number'] as String? ?? '',
      url: json['url'] as String? ?? '',
      uploadedAt: json['uploaded_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attachment_id': attachmentId,
      'type': type,
      'number': number,
      'url': url,
      'uploaded_at': uploadedAt,
    };
  }
}

/// Attachment returned from upload-complete
class LaybyAttachment {
  final String id;
  final String uuid;
  final String url;

  const LaybyAttachment({
    required this.id,
    required this.uuid,
    required this.url,
  });

  factory LaybyAttachment.fromJson(Map<String, dynamic> json) {
    return LaybyAttachment(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid']?.toString() ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'uuid': uuid, 'url': url};
  }
}

/// Lightweight product in layby context
class LaybyProduct {
  final int id;
  final String name;
  final String slug;
  final String? sku;
  final double? price;
  final double? salePrice;
  final int? discount;
  final String? stockStatus;
  final LaybyProductThumbnail? productThumbnail;
  final List<LaybyProductGallery> productGalleries;
  final List<LaybyVariation> variations;

  const LaybyProduct({
    required this.id,
    required this.name,
    required this.slug,
    this.sku,
    this.price,
    this.salePrice,
    this.discount,
    this.stockStatus,
    this.productThumbnail,
    this.productGalleries = const [],
    this.variations = const [],
  });

  factory LaybyProduct.fromJson(Map<String, dynamic> json) {
    return LaybyProduct(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      sku: json['sku'] as String?,
      price: _toDoubleOrNull(json['price']),
      salePrice: _toDoubleOrNull(json['sale_price']),
      discount: _toIntOrNull(json['discount']),
      stockStatus: json['stock_status'] as String?,
      productThumbnail:
          json['product_thumbnail'] != null
              ? LaybyProductThumbnail.fromJson(
                json['product_thumbnail'] as Map<String, dynamic>,
              )
              : null,
      productGalleries:
          (json['product_galleries'] as List<dynamic>?)
              ?.map(
                (e) => LaybyProductGallery.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      variations:
          (json['variations'] as List<dynamic>?)
              ?.map((e) => LaybyVariation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'sku': sku,
      'price': price,
      'sale_price': salePrice,
      'discount': discount,
      'stock_status': stockStatus,
      'product_thumbnail': productThumbnail?.toJson(),
      'product_galleries': productGalleries.map((e) => e.toJson()).toList(),
      'variations': variations.map((e) => e.toJson()).toList(),
    };
  }
}

class LaybyProductThumbnail {
  final int? id;
  final String imageUrl;
  final String? originalUrl;

  const LaybyProductThumbnail({
    this.id,
    required this.imageUrl,
    this.originalUrl,
  });

  factory LaybyProductThumbnail.fromJson(Map<String, dynamic> json) {
    return LaybyProductThumbnail(
      id: json['id'] as int?,
      imageUrl: json['image_url'] as String? ?? '',
      originalUrl: json['original_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'image_url': imageUrl, 'original_url': originalUrl};
  }
}

class LaybyProductGallery {
  final String imageUrl;

  const LaybyProductGallery({required this.imageUrl});

  factory LaybyProductGallery.fromJson(Map<String, dynamic> json) {
    return LaybyProductGallery(imageUrl: json['image_url'] as String? ?? '');
  }

  Map<String, dynamic> toJson() => {'image_url': imageUrl};
}

/// Variation in layby context
class LaybyVariation {
  final int id;
  final String name;
  final double? price;
  final int? quantity;
  final double? salePrice;
  final String? stockStatus;
  final List<LaybyAttributeValue> attributeValues;

  const LaybyVariation({
    required this.id,
    required this.name,
    this.price,
    this.quantity,
    this.salePrice,
    this.stockStatus,
    this.attributeValues = const [],
  });

  factory LaybyVariation.fromJson(Map<String, dynamic> json) {
    return LaybyVariation(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: _toDoubleOrNull(json['price']),
      quantity: _toIntOrNull(json['quantity']),
      salePrice: _toDoubleOrNull(json['sale_price']),
      stockStatus: json['stock_status'] as String?,
      attributeValues:
          (json['attribute_values'] as List<dynamic>?)
              ?.map(
                (e) => LaybyAttributeValue.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'sale_price': salePrice,
      'stock_status': stockStatus,
      'attribute_values': attributeValues.map((e) => e.toJson()).toList(),
    };
  }
}

class LaybyAttributeValue {
  final int id;
  final String value;
  final String? slug;

  const LaybyAttributeValue({required this.id, required this.value, this.slug});

  factory LaybyAttributeValue.fromJson(Map<String, dynamic> json) {
    return LaybyAttributeValue(
      id: json['id'] as int,
      value: json['value'] as String? ?? '',
      slug: json['slug'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'value': value, 'slug': slug};
  }
}

/// Payment record
class LaybyPayment {
  final int id;
  final double amount;
  final String status;
  final String? paymentMethod;
  final String? createdAt;
  final String? updatedAt;

  const LaybyPayment({
    required this.id,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.createdAt,
    this.updatedAt,
  });

  factory LaybyPayment.fromJson(Map<String, dynamic> json) {
    return LaybyPayment(
      id: json['id'] as int,
      amount: _toDouble(json['amount']),
      status: json['status'] as String? ?? '',
      paymentMethod: json['payment_method'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'status': status,
      'payment_method': paymentMethod,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// Full layby application
class LaybyApplication {
  final int id;
  final String applicationNumber;
  final int userId;
  final int productId;
  final int? variationId;
  final List<int>? selectedAttributeIds;
  final String? variationDisplayName;
  final String productName;
  final String productPrice;
  final String currency;
  final String currencySymbol;
  final String exchangeRate;
  final int durationMonths;
  final String depositAmount;
  final String monthlyAmount;
  final String totalAmount;
  final String status;
  final String? rejectionReason;
  final String? approvedAt;
  final String? rejectedAt;
  final dynamic approvedBy;
  final String totalPaid;
  final String balanceRemaining;
  final String? lastPaymentAt;
  final String? completedAt;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? idDocumentPath;
  final String? idDocumentType;
  final String? idDocumentNumber;
  final int? orderId;
  final int? idDocumentAttachmentId;
  final String? cancellationReason;
  final String? cancelledAt;
  final dynamic cancelledBy;
  final LaybyProduct? product;
  final LaybyVariation? variation;
  final dynamic order;
  final List<LaybyPayment> payments;

  const LaybyApplication({
    required this.id,
    required this.applicationNumber,
    required this.userId,
    required this.productId,
    this.variationId,
    this.selectedAttributeIds,
    this.variationDisplayName,
    required this.productName,
    required this.productPrice,
    required this.currency,
    required this.currencySymbol,
    required this.exchangeRate,
    required this.durationMonths,
    required this.depositAmount,
    required this.monthlyAmount,
    required this.totalAmount,
    required this.status,
    this.rejectionReason,
    this.approvedAt,
    this.rejectedAt,
    this.approvedBy,
    required this.totalPaid,
    required this.balanceRemaining,
    this.lastPaymentAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.idDocumentPath,
    this.idDocumentType,
    this.idDocumentNumber,
    this.orderId,
    this.idDocumentAttachmentId,
    this.cancellationReason,
    this.cancelledAt,
    this.cancelledBy,
    this.product,
    this.variation,
    this.order,
    this.payments = const [],
  });

  factory LaybyApplication.fromJson(Map<String, dynamic> json) {
    return LaybyApplication(
      id: _toInt(json['id']),
      applicationNumber: json['application_number']?.toString() ?? '',
      userId: _toInt(json['user_id']),
      productId: _toInt(json['product_id']),
      variationId: _toIntOrNull(json['variation_id']),
      selectedAttributeIds:
          (json['selected_attribute_ids'] as List<dynamic>?)
              ?.map((e) => _toInt(e))
              .toList(),
      variationDisplayName: json['variation_display_name'] as String?,
      productName: json['product_name']?.toString() ?? '',
      productPrice: json['product_price']?.toString() ?? '0',
      currency: json['currency']?.toString() ?? 'USD',
      currencySymbol: json['currency_symbol']?.toString() ?? '\$',
      exchangeRate: json['exchange_rate']?.toString() ?? '1',
      durationMonths: _toInt(json['duration_months']),
      depositAmount: json['deposit_amount']?.toString() ?? '0',
      monthlyAmount: json['monthly_amount']?.toString() ?? '0',
      totalAmount: json['total_amount']?.toString() ?? '0',
      status: json['status'] as String? ?? 'pending',
      rejectionReason: json['rejection_reason'] as String?,
      approvedAt: json['approved_at'] as String?,
      rejectedAt: json['rejected_at'] as String?,
      approvedBy: json['approved_by'],
      totalPaid: json['total_paid']?.toString() ?? '0',
      balanceRemaining: json['balance_remaining']?.toString() ?? '0',
      lastPaymentAt: json['last_payment_at'] as String?,
      completedAt: json['completed_at'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      deletedAt: json['deleted_at'] as String?,
      idDocumentPath: json['id_document_path'] as String?,
      idDocumentType: json['id_document_type'] as String?,
      idDocumentNumber: json['id_document_number'] as String?,
      orderId: _toIntOrNull(json['order_id']),
      idDocumentAttachmentId: _toIntOrNull(json['id_document_attachment_id']),
      cancellationReason: json['cancellation_reason'] as String?,
      cancelledAt: json['cancelled_at'] as String?,
      cancelledBy: json['cancelled_by'],
      product:
          json['product'] != null
              ? LaybyProduct.fromJson(json['product'] as Map<String, dynamic>)
              : null,
      variation:
          json['variation'] != null
              ? LaybyVariation.fromJson(
                json['variation'] as Map<String, dynamic>,
              )
              : null,
      order: json['order'],
      payments:
          (json['payments'] as List<dynamic>?)
              ?.map((e) => LaybyPayment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'application_number': applicationNumber,
      'user_id': userId,
      'product_id': productId,
      'variation_id': variationId,
      'selected_attribute_ids': selectedAttributeIds,
      'variation_display_name': variationDisplayName,
      'product_name': productName,
      'product_price': productPrice,
      'currency': currency,
      'currency_symbol': currencySymbol,
      'exchange_rate': exchangeRate,
      'duration_months': durationMonths,
      'deposit_amount': depositAmount,
      'monthly_amount': monthlyAmount,
      'total_amount': totalAmount,
      'status': status,
      'rejection_reason': rejectionReason,
      'approved_at': approvedAt,
      'rejected_at': rejectedAt,
      'approved_by': approvedBy,
      'total_paid': totalPaid,
      'balance_remaining': balanceRemaining,
      'last_payment_at': lastPaymentAt,
      'completed_at': completedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'id_document_path': idDocumentPath,
      'id_document_type': idDocumentType,
      'id_document_number': idDocumentNumber,
      'order_id': orderId,
      'id_document_attachment_id': idDocumentAttachmentId,
      'cancellation_reason': cancellationReason,
      'cancelled_at': cancelledAt,
      'cancelled_by': cancelledBy,
      'product': product?.toJson(),
      'variation': variation?.toJson(),
      'order': order,
      'payments': payments.map((e) => e.toJson()).toList(),
    };
  }

  /// Payment progress as a percentage (0.0 to 1.0)
  double get paymentProgress {
    final total = double.tryParse(totalAmount) ?? 0;
    final paid = double.tryParse(totalPaid) ?? 0;
    if (total <= 0) return 0;
    return (paid / total).clamp(0.0, 1.0);
  }

  /// Get the product thumbnail URL
  String? get thumbnailUrl => product?.productThumbnail?.imageUrl;
}

/// Paginated response for applications list
class LaybyApplicationsResponse {
  final int currentPage;
  final List<LaybyApplication> data;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  const LaybyApplicationsResponse({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory LaybyApplicationsResponse.fromJson(Map<String, dynamic> json) {
    return LaybyApplicationsResponse(
      currentPage: json['current_page'] as int? ?? 1,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => LaybyApplication.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      nextPageUrl: json['next_page_url'] as String?,
      prevPageUrl: json['prev_page_url'] as String?,
    );
  }

  bool get hasMore => currentPage < lastPage;
}

/// Request model for applying for layby
class LaybyApplyRequest {
  final int productId;
  final int? variationId;
  final List<int>? selectedAttributeIds;
  final String? variationDisplayName;
  final int durationMonths;
  final String idDocumentAttachmentId;
  final String idDocumentType;
  final String idDocumentNumber;

  const LaybyApplyRequest({
    required this.productId,
    this.variationId,
    this.selectedAttributeIds,
    this.variationDisplayName,
    required this.durationMonths,
    required this.idDocumentAttachmentId,
    required this.idDocumentType,
    required this.idDocumentNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      if (variationId != null) 'variation_id': variationId,
      if (selectedAttributeIds != null)
        'selected_attribute_ids': selectedAttributeIds,
      if (variationDisplayName != null)
        'variation_display_name': variationDisplayName,
      'duration_months': durationMonths,
      'id_document_attachment_id': idDocumentAttachmentId,
      'id_document_type': idDocumentType,
      'id_document_number': idDocumentNumber,
    };
  }
}
