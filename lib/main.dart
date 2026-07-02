import 'package:bloom_menstrual_health_wellness_tracker/screens/homepage.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/login_screen.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/privacy_policy_screen.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/registration_screen.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/terms_of_service_screen.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        '/privacy-policy': (context) => const PrivacyPolicyScreen(),
        '/terms-of-service': (context) => const TermsOfServiceScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
