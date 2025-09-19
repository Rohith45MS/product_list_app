class ApiConstants {
  static const String baseUrl = 'https://skilltestflutter.zybotechlab.com/api';
  static const String loginEndpoint = '/verify/';
  static const String resgisterEndpoint = '/login-register/';
  static const String bannersEndpoint = '/banners/';
  static const String productsEndpoint = '/products/';
  static const String userDataEndpoint = '/user-data/';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
