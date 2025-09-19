class VerifyResponse {
  final bool success;
  final String message;
  final String? token;
  final bool? user;
  final String? otp;

  VerifyResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.otp,
  });

  factory VerifyResponse.fromJson(Map<String, dynamic> json) {
    // Extract token from nested structure
    String? accessToken;
    if (json['token'] != null) {
      if (json['token'] is Map<String, dynamic>) {
        accessToken = json['token']['access']?.toString();
      } else {
        accessToken = json['token']?.toString();
      }
    }

    return VerifyResponse(
      success:
          json['success'] ??
          true, // Default to true since API doesn't always send success field
      message: json['message']?.toString() ?? 'Success',
      token: accessToken,
      user:
          json['user'] is bool
              ? json['user']
              : (json['user']?.toString().toLowerCase() == 'true'),
      otp: json['otp']?.toString(),
    );
  }
}
