class HomeConfigModel {
  final int id;
  final String slug;
  final HomeContent content;

  HomeConfigModel({
    required this.id,
    required this.slug,
    required this.content,
  });

  factory HomeConfigModel.fromJson(Map<String, dynamic> json) {
    return HomeConfigModel(
      id: (json['id'] as num).toInt(),
      slug: json['slug'] as String,
      content: HomeContent.fromJson(json['content'] as Map<String, dynamic>),
    );
  }
}

class HomeContent {
  final HomeBanner homeBanner;
  final NewsLetter newsLetter;
  final MainContent mainContent;
  final List<int?> productsIds;
  final FeaturedBanners featuredBanners;

  HomeContent({
    required this.homeBanner,
    required this.newsLetter,
    required this.mainContent,
    required this.productsIds,
    required this.featuredBanners,
  });

  factory HomeContent.fromJson(Map<String, dynamic> json) {
    return HomeContent(
      homeBanner: HomeBanner.fromJson(
        json['home_banner'] as Map<String, dynamic>,
      ),
      newsLetter: NewsLetter.fromJson(
        json['news_letter'] as Map<String, dynamic>,
      ),
      mainContent: MainContent.fromJson(
        json['main_content'] as Map<String, dynamic>,
      ),
      productsIds:
          (json['products_ids'] as List<dynamic>)
              .map((e) => e == null ? null : (e as num).toInt())
              .toList(),
      featuredBanners: FeaturedBanners.fromJson(
        json['featured_banners'] as Map<String, dynamic>,
      ),
    );
  }
}

class HomeBanner {
  final bool status;
  final BannerItem mainBanner;
  final BannerItem subBanner1;
  final BannerItem subBanner2;

  HomeBanner({
    required this.status,
    required this.mainBanner,
    required this.subBanner1,
    required this.subBanner2,
  });

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(
      status: json['status'] as bool,
      mainBanner: BannerItem.fromJson(
        json['main_banner'] as Map<String, dynamic>,
      ),
      subBanner1: BannerItem.fromJson(
        json['sub_banner_1'] as Map<String, dynamic>,
      ),
      subBanner2: BannerItem.fromJson(
        json['sub_banner_2'] as Map<String, dynamic>,
      ),
    );
  }
}

class RedirectLink {
  final String? link;
  final String linkType;
  final List<int>? productIds;

  RedirectLink({this.link, required this.linkType, this.productIds});

  // Accepts either a String or an object for the `link` field and
  // attempts to extract a usable URL/string safely.
  static String? _parseLink(dynamic linkJson) {
    if (linkJson == null) return null;
    if (linkJson is String) return linkJson;
    if (linkJson is Map<String, dynamic>) {
      const candidates = [
        'url',
        'link',
        'external_url',
        'original_url',
        'path',
        'value',
        'to',
      ];
      for (final key in candidates) {
        if (linkJson.containsKey(key) && linkJson[key] != null) {
          return linkJson[key].toString();
        }
      }
      // Check nested common attribute maps
      if (linkJson['attributes'] is Map &&
          (linkJson['attributes'] as Map).containsKey('url')) {
        final v = (linkJson['attributes'] as Map)['url'];
        if (v != null) return v.toString();
      }
      // Fallback: return the first string value found in the map
      for (final v in linkJson.values) {
        if (v is String) return v;
      }
      return null;
    }
    // Last resort: stringify whatever was provided
    return linkJson.toString();
  }

  factory RedirectLink.fromJson(Map<String, dynamic> json) {
    return RedirectLink(
      link: _parseLink(json['link']),
      linkType: json['link_type'] as String,
      productIds:
          json['product_ids'] == null
              ? null
              : (json['product_ids'] as List<dynamic>)
                  .map((e) => (e as num).toInt())
                  .toList(),
    );
  }
}

class BannerItem {
  final bool? status; // Some banners include status, others do not
  final String imageUrl;
  final RedirectLink redirectLink;

  BannerItem({this.status, required this.imageUrl, required this.redirectLink});

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      status: json['status'] as bool?,
      imageUrl: json['image_url'] as String,
      redirectLink: RedirectLink.fromJson(
        json['redirect_link'] as Map<String, dynamic>,
      ),
    );
  }
}

class NewsLetter {
  final String title;
  final bool status;
  final String imageUrl;
  final String subTitle;

  NewsLetter({
    required this.title,
    required this.status,
    required this.imageUrl,
    required this.subTitle,
  });

  factory NewsLetter.fromJson(Map<String, dynamic> json) {
    return NewsLetter(
      title: json['title'] as String,
      status: json['status'] as bool,
      imageUrl: json['image_url'] as String,
      subTitle: json['sub_title'] as String,
    );
  }
}

class MainContent {
  final bool status;
  final Sidebar sidebar;
  final SectionProducts homeAppliances;
  final SectionBanner section5Coupons;
  final SectionProducts section1Products;
  final SectionProducts section4Products;
  final SectionProducts section7Products;
  final SectionBlogs section9FeaturedBlogs;
  final SectionCategories section2CategoriesList;
  final SectionBanner section8FullWidthBanner;
  final TwoColumnBanners section3TwoColumnBanners;
  final TwoColumnBanners section6TwoColumnBanners;

  MainContent({
    required this.status,
    required this.sidebar,
    required this.homeAppliances,
    required this.section5Coupons,
    required this.section1Products,
    required this.section4Products,
    required this.section7Products,
    required this.section9FeaturedBlogs,
    required this.section2CategoriesList,
    required this.section8FullWidthBanner,
    required this.section3TwoColumnBanners,
    required this.section6TwoColumnBanners,
  });

  factory MainContent.fromJson(Map<String, dynamic> json) {
    return MainContent(
      status: json['status'] as bool,
      sidebar: Sidebar.fromJson(json['sidebar'] as Map<String, dynamic>),
      homeAppliances:
          json['home_appliances'] != null
              ? SectionProducts.fromJson(
                json['home_appliances'] as Map<String, dynamic>,
              )
              : SectionProducts(
                title: 'Home Appliances',
                status: false,
                productIds: [],
              ),
      section5Coupons: SectionBanner.fromJson(
        json['section5_coupons'] as Map<String, dynamic>,
      ),
      section1Products: SectionProducts.fromJson(
        json['section1_products'] as Map<String, dynamic>,
      ),
      section4Products: SectionProducts.fromJson(
        json['section4_products'] as Map<String, dynamic>,
      ),
      section7Products: SectionProducts.fromJson(
        json['section7_products'] as Map<String, dynamic>,
      ),
      section9FeaturedBlogs: SectionBlogs.fromJson(
        json['section9_featured_blogs'] as Map<String, dynamic>,
      ),
      section2CategoriesList: SectionCategories.fromJson(
        json['section2_categories_list'] as Map<String, dynamic>,
      ),
      section8FullWidthBanner: SectionBanner.fromJson(
        json['section8_full_width_banner'] as Map<String, dynamic>,
      ),
      section3TwoColumnBanners: TwoColumnBanners.fromJson(
        json['section3_two_column_banners'] as Map<String, dynamic>,
      ),
      section6TwoColumnBanners: TwoColumnBanners.fromJson(
        json['section6_two_column_banners'] as Map<String, dynamic>,
      ),
    );
  }
}

class Sidebar {
  final bool status;
  final SidebarProducts sidebarProducts;
  final LeftSideBanners leftSideBanners;
  final CategoriesIconList categoriesIconList;

  Sidebar({
    required this.status,
    required this.sidebarProducts,
    required this.leftSideBanners,
    required this.categoriesIconList,
  });

  factory Sidebar.fromJson(Map<String, dynamic> json) {
    return Sidebar(
      status: json['status'] as bool,
      sidebarProducts: SidebarProducts.fromJson(
        json['sidebar_products'] as Map<String, dynamic>,
      ),
      leftSideBanners: LeftSideBanners.fromJson(
        json['left_side_banners'] as Map<String, dynamic>,
      ),
      categoriesIconList: CategoriesIconList.fromJson(
        json['categories_icon_list'] as Map<String, dynamic>,
      ),
    );
  }
}

class SidebarProducts {
  final String title;
  final bool status;
  final List<int> productIds;

  SidebarProducts({
    required this.title,
    required this.status,
    required this.productIds,
  });

  factory SidebarProducts.fromJson(Map<String, dynamic> json) {
    return SidebarProducts(
      title: json['title'] as String,
      status: json['status'] as bool,
      productIds:
          (json['product_ids'] as List<dynamic>)
              .map((e) => (e as num).toInt())
              .toList(),
    );
  }
}

class LeftSideBanners {
  final bool status;
  final BannerItem banner1;
  final BannerItem banner2;

  LeftSideBanners({
    required this.status,
    required this.banner1,
    required this.banner2,
  });

  factory LeftSideBanners.fromJson(Map<String, dynamic> json) {
    return LeftSideBanners(
      status: json['status'] as bool,
      banner1: BannerItem.fromJson(json['banner_1'] as Map<String, dynamic>),
      banner2: BannerItem.fromJson(json['banner_2'] as Map<String, dynamic>),
    );
  }
}

class CategoriesIconList {
  final String title;
  final bool status;
  final List<int> categoryIds;

  CategoriesIconList({
    required this.title,
    required this.status,
    required this.categoryIds,
  });

  factory CategoriesIconList.fromJson(Map<String, dynamic> json) {
    return CategoriesIconList(
      title: json['title'] as String,
      status: json['status'] as bool,
      categoryIds:
          (json['category_ids'] as List<dynamic>)
              .map((e) => (e as num).toInt())
              .toList(),
    );
  }
}

class SectionBanner {
  final bool status;
  final String imageUrl;
  final RedirectLink redirectLink;

  SectionBanner({
    required this.status,
    required this.imageUrl,
    required this.redirectLink,
  });

  factory SectionBanner.fromJson(Map<String, dynamic> json) {
    return SectionBanner(
      status: json['status'] as bool,
      imageUrl: json['image_url'] as String,
      redirectLink: RedirectLink.fromJson(
        json['redirect_link'] as Map<String, dynamic>,
      ),
    );
  }
}

class SectionProducts {
  final String title;
  final bool status;
  final String? description;
  final List<int> productIds;

  SectionProducts({
    required this.title,
    required this.status,
    this.description,
    required this.productIds,
  });

  factory SectionProducts.fromJson(Map<String, dynamic> json) {
    return SectionProducts(
      title: json['title'] as String,
      status: json['status'] as bool,
      description: json['description'] as String?,
      productIds:
          (json['product_ids'] as List<dynamic>)
              .map((e) => (e as num).toInt())
              .toList(),
    );
  }
}

class SectionBlogs {
  final String title;
  final bool status;
  final List<int> blogIds;
  final String? description;

  SectionBlogs({
    required this.title,
    required this.status,
    required this.blogIds,
    this.description,
  });

  factory SectionBlogs.fromJson(Map<String, dynamic> json) {
    return SectionBlogs(
      title: json['title'] as String,
      status: json['status'] as bool,
      blogIds:
          (json['blog_ids'] as List<dynamic>)
              .map((e) => (e as num).toInt())
              .toList(),
      description: json['description'] as String?,
    );
  }
}

class SectionCategories {
  final String title;
  final bool status;
  final String? imageUrl;
  final String? description;
  final List<int> categoryIds;

  SectionCategories({
    required this.title,
    required this.status,
    this.imageUrl,
    this.description,
    required this.categoryIds,
  });

  factory SectionCategories.fromJson(Map<String, dynamic> json) {
    return SectionCategories(
      title: json["title"] as String,
      status: json["status"] as bool,
      imageUrl: json["image_url"] as String?,
      description: json["description"] as String?,
      categoryIds:
          (json["category_ids"] as List<dynamic>)
              .map((e) => (e as num).toInt())
              .toList(),
    );
  }
}

class TwoColumnBanners {
  final bool status;
  final BannerItem banner1;
  final BannerItem banner2;

  TwoColumnBanners({
    required this.status,
    required this.banner1,
    required this.banner2,
  });

  factory TwoColumnBanners.fromJson(Map<String, dynamic> json) {
    return TwoColumnBanners(
      status: json['status'] as bool,
      banner1: BannerItem.fromJson(json['banner_1'] as Map<String, dynamic>),
      banner2: BannerItem.fromJson(json['banner_2'] as Map<String, dynamic>),
    );
  }
}

class FeaturedBanners {
  final bool status;
  final List<BannerItem> banners;

  FeaturedBanners({required this.status, required this.banners});

  factory FeaturedBanners.fromJson(Map<String, dynamic> json) {
    return FeaturedBanners(
      status: json['status'] as bool,
      banners:
          (json['banners'] as List<dynamic>)
              .map((e) => BannerItem.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}
