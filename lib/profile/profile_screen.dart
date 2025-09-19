import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../shared/bottom_navigation.dart';
import '../core/services/preferences_service.dart';
import 'dart:convert';
import '../core/api/api_constants.dart';
import 'package:dio/dio.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 2; // Profile is index 2
  String? _userName;
  String? _userPhone;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final token = PreferencesService.getToken();
    if (token == null) return;

    try {
      final dio = Dio();
      dio.options.headers.addAll({
        ...ApiConstants.defaultHeaders,
        'Authorization': 'Bearer $token',
      });

      final response = await dio.get(
        ApiConstants.baseUrl + ApiConstants.userDataEndpoint,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _userName = data['name'];
          _userPhone = data['phone_number'];
        });
      } else {
        setState(() {
          _userName = null;
          _userPhone = null;
        });
      }
    } catch (e) {
      setState(() {
        _userName = null;
        _userPhone = null;
      });
    }
  }

  Future<void> _logout() async {
    await PreferencesService.clearToken(); // This removes the token
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/wishlist');
          }
          // Profile is already active, no need to navigate
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _ProfileField(label: 'Name', value: _userName ?? 'No Name'),
              const SizedBox(height: 24),
              _ProfileField(
                label: 'Phone',
                value: _userPhone != null ? '+91 $_userPhone' : 'No Number',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
