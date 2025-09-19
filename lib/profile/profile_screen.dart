import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../shared/bottom_navigation.dart';
import '../core/services/preferences_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 2; // Profile is index 2

  @override
  void initState() {
    super.initState();
    // Fetch profile data on screen load
    context.read<ProfileBloc>().add(FetchProfile());
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
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileLoaded) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _ProfileField(label: 'Name', value: state.name),
                    const SizedBox(height: 24),
                    _ProfileField(label: 'Phone', value: '+91 ${state.phone}'),
                    const SizedBox(height: 186),
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5B5BEA),
                        foregroundColor: Colors.white,
                        minimumSize: Size(356, 48),
                      ),
                      child: const Text('Logout'),
                    ),
                    const Spacer(),
                  ],
                );
              }
              else if (state is ProfileError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              // Initial state
              return const Center(child: Text('No profile data'));
            },
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
