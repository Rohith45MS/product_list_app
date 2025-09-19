import 'dart:convert';

class RegisterResponse {
  final bool success;
  final String message;
  final String? token;

  RegisterResponse({required this.success, required this.message, this.token});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      token: json['token']?.toString(),
    );
  }
}
