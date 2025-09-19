import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../home/home_models.dart';

class ProductApi {
  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('http://skilltestflutter.zybotechlab.com/api/products/'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
  
  // Add this method to your ProductApi class
  static Future<List<Product>> searchProducts(String query) async {
    final response = await http.get(
      Uri.parse('http://skilltestflutter.zybotechlab.com/api/search/?query=$query'),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Failed to search products');
  }
}
