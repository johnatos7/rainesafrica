import 'package:flutter_riverpod_clean_architecture/features/legal/domain/entities/legal_document_entity.dart';

/// Model for legal document data serialization
class LegalDocumentModel extends LegalDocumentEntity {
  const LegalDocumentModel({
    required super.id,
    required super.title,
    required super.slug,
    required super.content,
    super.metaTitle,
    super.metaDescription,
    super.pageMetaImageId,
    required super.status,
    required super.createdById,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    super.pageMetaImage,
    super.createdBy,
  });

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) {
    return LegalDocumentModel(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      content: json['content'] as String,
      metaTitle: json['meta_title'] as String?,
      metaDescription: json['meta_description'] as String?,
      pageMetaImageId: json['page_meta_image_id'] as int?,
      status: json['status'] as int,
      createdById: json['created_by_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'] as String)
              : null,
      pageMetaImage: json['page_meta_image'] as String?,
      createdBy:
          json['created_by'] != null
              ? CreatedByModel.fromJson(
                json['created_by'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'content': content,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'page_meta_image_id': pageMetaImageId,
      'status': status,
      'created_by_id': createdById,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'page_meta_image': pageMetaImage,
      'created_by':
          createdBy != null ? (createdBy as CreatedByModel).toJson() : null,
    };
  }

  LegalDocumentEntity toEntity() {
    return LegalDocumentEntity(
      id: id,
      title: title,
      slug: slug,
      content: content,
      metaTitle: metaTitle,
      metaDescription: metaDescription,
      pageMetaImageId: pageMetaImageId,
      status: status,
      createdById: createdById,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      pageMetaImage: pageMetaImage,
      createdBy: createdBy,
    );
  }
}

/// Model for created by data serialization
class CreatedByModel extends CreatedByEntity {
  const CreatedByModel({
    required super.id,
    required super.name,
    required super.email,
    required super.countryCode,
    required super.phone,
    super.profileImageId,
    required super.systemReserve,
    required super.status,
    required super.createdById,
    required super.emailVerifiedAt,
    required super.createdAt,
    required super.ordersCount,
    super.role,
    super.profileImage,
  });

  factory CreatedByModel.fromJson(Map<String, dynamic> json) {
    return CreatedByModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      countryCode: json['country_code'] as String,
      phone: json['phone'] as int,
      profileImageId: json['profile_image_id'] as int?,
      systemReserve: json['system_reserve'] as int,
      status: json['status'] as int,
      createdById: json['created_by_id'] as int,
      emailVerifiedAt: DateTime.parse(json['email_verified_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      ordersCount: json['orders_count'] as int,
      role:
          json['role'] != null
              ? RoleModel.fromJson(json['role'] as Map<String, dynamic>)
              : null,
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
      'profile_image_id': profileImageId,
      'system_reserve': systemReserve,
      'status': status,
      'created_by_id': createdById,
      'email_verified_at': emailVerifiedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'orders_count': ordersCount,
      'role': role != null ? (role as RoleModel).toJson() : null,
      'profile_image': profileImage,
    };
  }

  CreatedByEntity toEntity() {
    return CreatedByEntity(
      id: id,
      name: name,
      email: email,
      countryCode: countryCode,
      phone: phone,
      profileImageId: profileImageId,
      systemReserve: systemReserve,
      status: status,
      createdById: createdById,
      emailVerifiedAt: emailVerifiedAt,
      createdAt: createdAt,
      ordersCount: ordersCount,
      role: role,
      profileImage: profileImage,
    );
  }
}

/// Model for role data serialization
class RoleModel extends RoleEntity {
  const RoleModel({
    required super.id,
    required super.name,
    required super.guardName,
    required super.systemReserve,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int,
      name: json['name'] as String,
      guardName: json['guard_name'] as String,
      systemReserve: json['system_reserve'] as int,
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

  RoleEntity toEntity() {
    return RoleEntity(
      id: id,
      name: name,
      guardName: guardName,
      systemReserve: systemReserve,
    );
  }
}

/// Model for legal documents response data serialization
class LegalDocumentsResponseModel extends LegalDocumentsResponseEntity {
  const LegalDocumentsResponseModel({
    required super.currentPage,
    required super.data,
    required super.firstPageUrl,
    required super.from,
    required super.lastPage,
    required super.lastPageUrl,
    required super.links,
    super.nextPageUrl,
    required super.path,
    required super.perPage,
    super.prevPageUrl,
    required super.to,
    required super.total,
  });

  factory LegalDocumentsResponseModel.fromJson(Map<String, dynamic> json) {
    return LegalDocumentsResponseModel(
      currentPage: json['current_page'] as int,
      data:
          (json['data'] as List<dynamic>)
              .map(
                (item) =>
                    LegalDocumentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      firstPageUrl: json['first_page_url'] as String,
      from: json['from'] as int,
      lastPage: json['last_page'] as int,
      lastPageUrl: json['last_page_url'] as String,
      links:
          (json['links'] as List<dynamic>)
              .map((item) => LinkModel.fromJson(item as Map<String, dynamic>))
              .toList(),
      nextPageUrl: json['next_page_url'] as String?,
      path: json['path'] as String,
      perPage: json['per_page'] as int,
      prevPageUrl: json['prev_page_url'] as String?,
      to: json['to'] as int,
      total: json['total'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data':
          data.map((item) => (item as LegalDocumentModel).toJson()).toList(),
      'first_page_url': firstPageUrl,
      'from': from,
      'last_page': lastPage,
      'last_page_url': lastPageUrl,
      'links': links.map((item) => (item as LinkModel).toJson()).toList(),
      'next_page_url': nextPageUrl,
      'path': path,
      'per_page': perPage,
      'prev_page_url': prevPageUrl,
      'to': to,
      'total': total,
    };
  }

  LegalDocumentsResponseEntity toEntity() {
    return LegalDocumentsResponseEntity(
      currentPage: currentPage,
      data:
          data.map((item) => (item as LegalDocumentModel).toEntity()).toList(),
      firstPageUrl: firstPageUrl,
      from: from,
      lastPage: lastPage,
      lastPageUrl: lastPageUrl,
      links: links.map((item) => (item as LinkModel).toEntity()).toList(),
      nextPageUrl: nextPageUrl,
      path: path,
      perPage: perPage,
      prevPageUrl: prevPageUrl,
      to: to,
      total: total,
    );
  }
}

/// Model for link data serialization
class LinkModel extends LinkEntity {
  const LinkModel({super.url, required super.label, required super.active});

  factory LinkModel.fromJson(Map<String, dynamic> json) {
    return LinkModel(
      url: json['url'] as String?,
      label: json['label'] as String,
      active: json['active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'label': label, 'active': active};
  }

  LinkEntity toEntity() {
    return LinkEntity(url: url, label: label, active: active);
  }
}
