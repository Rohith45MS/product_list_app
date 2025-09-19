class BannerModel {
  final int id;
  final String name;
  final String image;
  final int showingOrder;
  final Product? product;
  final Category? category;
  final String? hexcode1;
  final String? hexcode2;

  BannerModel({
    required this.id,
    required this.name,
    required this.image,
    required this.showingOrder,
    this.product,
    this.category,
    this.hexcode1,
    this.hexcode2,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      showingOrder: json['showing_order'] ?? 0,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      hexcode1: json['hexcode_1'],
      hexcode2: json['hexcode_2'],
    );
  }
}

class Product {
  final int id;
  final String name;
  final String description;
  final String caption;
  final String featuredImage;
  final double salePrice;
  final double mrp;
  final String discount;
  final int stock;
  final bool isActive;
  final String productType;
  final String variationName;
  final int category;
  final int taxRate;
  final bool inWishlist;
  final double avgRating;
  final bool variationExists;
  final List<String> images;
  final List<dynamic> variations;
  final String createdDate;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.caption,
    required this.featuredImage,
    required this.salePrice,
    required this.mrp,
    required this.discount,
    required this.stock,
    required this.isActive,
    required this.productType,
    required this.variationName,
    required this.category,
    required this.taxRate,
    required this.inWishlist,
    required this.avgRating,
    required this.variationExists,
    required this.images,
    required this.variations,
    required this.createdDate,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      caption: json['caption'] ?? '',
      featuredImage: json['featured_image'] ?? '',
      salePrice: (json['sale_price'] ?? 0).toDouble(),
      mrp: (json['mrp'] ?? 0).toDouble(),
      discount: json['discount'] ?? '0',
      stock: json['stock'] ?? 0,
      isActive: json['is_active'] ?? false,
      productType: json['product_type'] ?? '',
      variationName: json['variation_name'] ?? '',
      category: json['category'] ?? 0,
      taxRate: json['tax_rate'] ?? 0,
      inWishlist: json['in_wishlist'] ?? false,
      avgRating: (json['avg_rating'] ?? 0).toDouble(),
      variationExists: json['variation_exists'] ?? false,
      images: List<String>.from(json['images'] ?? []),
      variations: json['variations'] ?? [],
      createdDate: json['created_date'] ?? '',
    );
  }
}

class Category {
  final int id;
  final String name;
  final String image;
  final bool isActive;
  final int showingOrder;
  final String slug;
  final List<Product> products;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.isActive,
    required this.showingOrder,
    required this.slug,
    required this.products,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      isActive: json['is_active'] ?? false,
      showingOrder: json['showing_order'] ?? 0,
      slug: json['slug'] ?? '',
      products: (json['products'] as List<dynamic>?)
          ?.map((product) => Product.fromJson(product))
          .toList() ?? [],
    );
  }
}
