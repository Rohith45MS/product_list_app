
class Product {
  final int id;
  final String name;
  final String? description;
  final String? featuredImage;
  final List<String>? images;
  final double? avgRating;
  final double salePrice;
  final double? mrp;
  final bool inWishlist;
  // Add other fields as needed

  Product({
    required this.id,
    required this.name,
    this.description,
    this.featuredImage,
    this.images,
    this.avgRating,
    required this.salePrice,
    this.mrp,
    this.inWishlist = false,
    // Add other fields as needed
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      featuredImage: json['featured_image'],
      images: (json['images'] as List?)?.map((e) => e as String).toList(),
      avgRating: (json['avg_rating'] as num?)?.toDouble(),
      salePrice: (json['sale_price'] as num).toDouble(),
      mrp: (json['mrp'] as num?)?.toDouble(),
      inWishlist: json['in_wishlist'] ?? false,
      // Add other fields as needed
    );
  }
}