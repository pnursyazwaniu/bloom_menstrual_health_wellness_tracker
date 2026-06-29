import 'package:bloom_menstrual_health_wellness_tracker/screens/forgot_password_screen.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/homepage.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/login_screen.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/registration_screen.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloom Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
