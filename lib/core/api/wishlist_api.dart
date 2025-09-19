import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../home/home_models.dart';
import '../services/preferences_service.dart';

class WishlistApi {
  static const String _url =
      'https://skilltestflutter.zybotechlab.com/api/add-remove-wishlist/';

  static Future<bool> toggleWishlist(String productId) async {
    final token = await PreferencesService.getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse(_url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'product_id': productId}),
    );
    return response.statusCode == 200;
  }

  static const String baseUrl =
      'https://skilltestflutter.zybotechlab.com/api/wishlist/';

  static Future<List<Product>> fetchWishlist() async {
    final token = await PreferencesService.getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson({
        'id': json['id'].toString(),
        'name': json['name'] ?? '',
        'featured_image': json['featured_image'] ?? '',
        'images': json['images'] ?? [],
        'sale_price': json['sale_price'] ?? 0,
        'mrp': json['mrp'],
        'avg_rating': json['avg_rating'] ?? 0,
        'in_wishlist': json['in_wishlist'] ?? false,
      })).toList();
    } else {
      throw Exception('Failed to load wishlist');
    }
  }
}
