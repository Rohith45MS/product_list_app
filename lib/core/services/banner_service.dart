import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/banner_model.dart';

class BannerService {
  static final BannerService _instance = BannerService._internal();
  factory BannerService() => _instance;
  BannerService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.bannersEndpoint);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BannerModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load banners: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load banners: $e');
    }
  }
}
