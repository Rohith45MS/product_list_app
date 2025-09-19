class RegisterResponse {
  final String? token;
  final String? userId;
  final String message;

  RegisterResponse({
    this.token,
    this.userId,
    required this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    String? accessToken;
    if (json['token'] != null && json['token'] is Map) {
      accessToken = json['token']['access']?.toString();
    }

    return RegisterResponse(
      token: accessToken,
      userId: json['user_id']?.toString(),
      message: json['message']?.toString() ?? '',
    );
  }
}
