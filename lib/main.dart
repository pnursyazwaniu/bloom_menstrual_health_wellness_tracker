import 'package:bloom_menstrual_health_wellness_tracker/screens/homepage.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/login_screen.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/registration_screen.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // to ensure flutter engine ready before calling Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  //  activate firebase connection
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
      home: const LoginScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
