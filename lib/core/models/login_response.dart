import 'dart:convert';

class LoginResponse {
  final bool success;
  final String message;
  final String? otp;
  final String? token;

  LoginResponse({
    required this.success,
    required this.message,
    this.otp,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      otp: json['otp']?.toString(),
      token: json['token']?.toString(),
    );
  }

  factory LoginResponse.fromString(String response) {
    // Try to parse as JSON first
    try {
      final json = jsonDecode(response);
      return LoginResponse.fromJson(json);
    } catch (e) {
      // If not JSON, treat as a simple message
      return LoginResponse(
        success: true, // Assume success if it's just a message
        message: response,
      );
    }
  }
}
