import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/verify_response.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<VerifyResponse> verifyPhone(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.loginEndpoint,
        data: request.toJson(),
      );

      print('Verify API Response: ${response.data}');
      print('Response type: ${response.data.runtimeType}');

      if (response.data is Map<String, dynamic>) {
        return VerifyResponse.fromJson(response.data);
      } else {
        return VerifyResponse(
          success: false,
          message: 'Invalid response format: ${response.data.runtimeType}',
        );
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('Response data: ${e.response?.data}');
      
      if (e.response != null) {
        if (e.response!.data is Map<String, dynamic>) {
          return VerifyResponse.fromJson(e.response!.data);
        } else {
          return VerifyResponse(
            success: false,
            message: 'Server error: ${e.response!.statusCode} - ${e.response!.data}',
          );
        }
      } else {
        return VerifyResponse(
          success: false,
          message: 'Network error: ${e.message}',
        );
      }
    } catch (e) {
      print('Unexpected error: $e');
      return VerifyResponse(success: false, message: 'Unexpected error: $e');
    }
  }

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.resgisterEndpoint,
        data: request.toJson(),
      );

      print('Register API Response: ${response.data}');
      print('Response type: ${response.data.runtimeType}');

      if (response.data is Map<String, dynamic>) {
        return RegisterResponse.fromJson(response.data);
      } else {
        return RegisterResponse(
          success: false,
          message: 'Invalid response format: ${response.data.runtimeType}',
        );
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('Response data: ${e.response?.data}');
      
      if (e.response != null) {
        if (e.response!.data is Map<String, dynamic>) {
          return RegisterResponse.fromJson(e.response!.data);
        } else {
          return RegisterResponse(
            success: false,
            message: 'Server error: ${e.response!.statusCode} - ${e.response!.data}',
          );
        }
      } else {
        return RegisterResponse(
          success: false,
          message: 'Network error: ${e.message}',
        );
      }
    } catch (e) {
      print('Unexpected error: $e');
      return RegisterResponse(success: false, message: 'Unexpected error: $e');
    }
  }

  // Keep the old login method for backward compatibility
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.loginEndpoint,
        data: request.toJson(),
      );

      // Handle different response types
      if (response.data is Map<String, dynamic>) {
        return LoginResponse.fromJson(response.data);
      } else if (response.data is String) {
        // If response is a string, try to parse it
        return LoginResponse.fromString(response.data);
      } else {
        return LoginResponse(
          success: false,
          message: 'Invalid response format: ${response.data.runtimeType}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Server responded with error status
        if (e.response!.data is Map<String, dynamic>) {
          return LoginResponse.fromJson(e.response!.data);
        } else if (e.response!.data is String) {
          return LoginResponse.fromString(e.response!.data);
        } else {
          return LoginResponse(
            success: false,
            message: 'Server error: ${e.response!.statusCode} - ${e.response!.data}',
          );
        }
      } else {
        // Network or other error
        return LoginResponse(
          success: false,
          message: 'Network error: ${e.message}',
        );
      }
    } catch (e) {
      return LoginResponse(success: false, message: 'Unexpected error: $e');
    }
  }
}
