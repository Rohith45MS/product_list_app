import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_list_app/profile/profile_bloc.dart';
import 'package:product_list_app/profile/profile_screen.dart';
import 'package:product_list_app/wishlist/wishlist_screen.dart';
import 'core/services/preferences_service.dart';
import 'home/home_screen.dart';
import 'login_screen.dart';
import 'otp/otp_screen.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize preferences service
  await PreferencesService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/wishlist': (context) => const WishlistScreen(),
        '/profile': (context) => BlocProvider(
          create: (_) => ProfileBloc(),
          child: ProfileScreen(),
        ),
        '/login': (context) => const LoginScreen(),
        '/otp': (context) => const OtpScreen(phone: '', otp: '',),
      },
    );
  }
}

// Removed default MyHomePage scaffold; using HomeScreen instead
