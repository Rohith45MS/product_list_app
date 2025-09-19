import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _phoneKey = 'user_phone_number';
  static const String _loginTimeKey = 'login_time';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _tokenKey = 'auth_token';
  static const String _firstNameKey = 'first_name';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('PreferencesService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Save phone number
  static Future<bool> savePhoneNumber(String phone) async {
    return await prefs.setString(_phoneKey, phone);
  }

  // Get phone number
  static String? getPhoneNumber() {
    return prefs.getString(_phoneKey);
  }

  // Save login time
  static Future<bool> saveLoginTime(DateTime loginTime) async {
    return await prefs.setString(_loginTimeKey, loginTime.toIso8601String());
  }

  // Get login time
  static DateTime? getLoginTime() {
    final timeString = prefs.getString(_loginTimeKey);
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }

  // Set login status
  static Future<bool> setLoggedIn(bool isLoggedIn) async {
    return await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  // Get login status
  static bool isLoggedIn() {
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Save auth token
  static Future<bool> saveToken(String token) async {
    return await prefs.setString(_tokenKey, token);
  }

  // Get auth token
  static String? getToken() {
    return prefs.getString(_tokenKey);
  }

  // Save first name
  static Future<bool> saveFirstName(String firstName) async {
    return await prefs.setString(_firstNameKey, firstName);
  }

  // Get first name
  static String? getFirstName() {
    return prefs.getString(_firstNameKey);
  }

  // Clear all user data
  static Future<bool> clearUserData() async {
    return await prefs.clear();
  }

  // Save user session data
  static Future<bool> saveUserSession(String phone) async {
    final now = DateTime.now();
    final results = await Future.wait([
      savePhoneNumber(phone),
      saveLoginTime(now),
      setLoggedIn(true),
    ]);
    return results.every((result) => result);
  }

  // Save complete user data with token
  static Future<bool> saveUserData({
    required String phone,
    required String token,
    String? firstName,
  }) async {
    final now = DateTime.now();
    final results = await Future.wait([
      savePhoneNumber(phone),
      saveToken(token),
      saveLoginTime(now),
      setLoggedIn(true),
      if (firstName != null) saveFirstName(firstName),
    ]);
    return results.every((result) => result);
  }

  static clearToken() {}
  


}
