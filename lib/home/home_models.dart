class Product {
  Product({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.price,
    required this.rating,
    this.isFavorite = false,
    this.strikePrice,
  });

  final String id;
  final String name;
  final String imageAsset;
  final int price;
  final double rating;
  final bool isFavorite;
  final int? strikePrice;

  Product copyWith({
    String? id,
    String? name,
    String? imageAsset,
    int? price,
    double? rating,
    bool? isFavorite,
    int? strikePrice,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      imageAsset: imageAsset ?? this.imageAsset,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      strikePrice: strikePrice ?? this.strikePrice,
    );
  }

  static Future<void> fromJson(item) async {}
}

class HomeSection {
  HomeSection({required this.title, required this.products});
  final String title;
  final List<Product> products;
}

class Banner {
  Banner({
    required this.id,
    required this.name,
    required this.image,
    required this.showingOrder,
    this.product,
    this.category,
    this.hexcode1,
    this.hexcode2,
  });

  final int id;
  final String name;
  final String image;
  final int showingOrder;
  final Product? product;
  final Category? category;
  final String? hexcode1;
  final String? hexcode2;
}

class Category {
  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.isActive,
    required this.showingOrder,
    required this.slug,
    required this.products,
  });

  final int id;
  final String name;
  final String image;
  final bool isActive;
  final int showingOrder;
  final String slug;
  final List<Product> products;
}
