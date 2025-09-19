import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../home/home_models.dart';

class Product {
  final int id;
  final String name;
  final String? description;
  final String? featuredImage;
  final List<String> images;
  final double salePrice;
  final double? mrp;
  final double avgRating;
  final bool inWishlist;
  final String? productType; // Add field declaration
  final int? stock; // Add field declaration
  final String? discount; // Add field declaration

  Product({
    required this.id,
    required this.name,
    this.description,
    this.featuredImage,
    this.images = const [],
    required this.salePrice,
    this.mrp,
    this.avgRating = 0,
    this.inWishlist = false,
    this.productType, // Add to constructor
    this.stock, // Add to constructor
    this.discount, // Add to constructor
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      description: json['description'],
      featuredImage: json['featured_image'],
      images: List<String>.from(json['images'] ?? []),
      salePrice: double.parse((json['sale_price'] ?? 0).toString()),
      mrp: json['mrp'] != null ? double.parse(json['mrp'].toString()) : null,
      avgRating: double.parse((json['avg_rating'] ?? 0).toString()),
      inWishlist: json['in_wishlist'] ?? false,
      productType: json['product_type'],
      stock: json['stock'],
      discount: json['discount'],
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    String? featuredImage,
    List<String>? images,
    double? salePrice,
    double? mrp,
    double? avgRating,
    bool? inWishlist,
    String? productType,
    int? stock,
    String? discount,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      featuredImage: featuredImage ?? this.featuredImage,
      images: images ?? this.images,
      salePrice: salePrice ?? this.salePrice,
      mrp: mrp ?? this.mrp,
      avgRating: avgRating ?? this.avgRating,
      inWishlist: inWishlist ?? this.inWishlist,
      productType: productType ?? this.productType,
      stock: stock ?? this.stock,
      discount: discount ?? this.discount,
    );
  }
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

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      showingOrder: json['showing_order'] ?? 0,
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      hexcode1: json['hexcode_1'],
      hexcode2: json['hexcode_2'],
    );
  }
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

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      isActive: json['is_active'] ?? false,
      showingOrder: json['showing_order'] ?? 0,
      slug: json['slug'] ?? '',
      products:
          (json['products'] as List<dynamic>? ?? [])
              .map((e) => Product.fromJson(e))
              .toList(),
    );
  }
}
