import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../home/home_models.dart';

class BannerApi {
  static Future<List<Banner>> fetchBanners() async {
    final response = await http.get(
      Uri.parse('http://skilltestflutter.zybotechlab.com/api/banners/'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Banner.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load banners');
    }
  }
}
