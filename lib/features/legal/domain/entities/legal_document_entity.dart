/// Entity representing a legal document
class LegalDocumentEntity {
  final int id;
  final String title;
  final String slug;
  final String content;
  final String? metaTitle;
  final String? metaDescription;
  final int? pageMetaImageId;
  final int status;
  final int createdById;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? pageMetaImage;
  final CreatedByEntity? createdBy;

  const LegalDocumentEntity({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    this.metaTitle,
    this.metaDescription,
    this.pageMetaImageId,
    required this.status,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.pageMetaImage,
    this.createdBy,
  });
}

/// Entity representing the creator of a legal document
class CreatedByEntity {
  final int id;
  final String name;
  final String email;
  final String countryCode;
  final int phone;
  final int? profileImageId;
  final int systemReserve;
  final int status;
  final int createdById;
  final DateTime emailVerifiedAt;
  final DateTime createdAt;
  final int ordersCount;
  final RoleEntity? role;
  final String? profileImage;

  const CreatedByEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.countryCode,
    required this.phone,
    this.profileImageId,
    required this.systemReserve,
    required this.status,
    required this.createdById,
    required this.emailVerifiedAt,
    required this.createdAt,
    required this.ordersCount,
    this.role,
    this.profileImage,
  });
}

/// Entity representing a user role
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
}

/// Entity representing paginated legal documents response
class LegalDocumentsResponseEntity {
  final int currentPage;
  final List<LegalDocumentEntity> data;
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

  const LegalDocumentsResponseEntity({
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
}

/// Entity representing pagination links
class LinkEntity {
  final String? url;
  final String label;
  final bool active;

  const LinkEntity({this.url, required this.label, required this.active});
}
