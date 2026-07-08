import 'package:bloom_menstrual_health_wellness_tracker/screens/homepage.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/login_screen.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/privacy_policy_screen.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/registration_screen.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/terms_of_service_screen.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/welcome_screen.dart';
import 'package:bloom_menstrual_health_wellness_tracker/services/auth_service.dart';
import 'package:bloom_menstrual_health_wellness_tracker/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notifications (with error handling so app doesn't crash)
  try {
    await NotificationService().initializeNotifications();
  } catch (e) {
    print('Warning: Failed to initialize notifications: $e');
    // Continue app even if notifications fail
  }

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
      home: const AuthGate(),
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

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomePage();
        }

        return const WelcomeScreen();
      },
    );
  }
}
