class RegisterRequest {
  final String phone;
  final String firstName;

  RegisterRequest({required this.phone, required this.firstName});

  Map<String, dynamic> toJson() {
    return {'phone_number': phone, 'first_name': firstName};
  }
}
