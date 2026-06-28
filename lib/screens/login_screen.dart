import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;

  Future<void> _ensureFirebaseInitialized() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9A8D4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/bunga.png', height: 100),
              const SizedBox(height: 20),
              const Text("Welcome to Bloom", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text("Your personal wellness companion", style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 40),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible, 
                decoration: InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await _ensureFirebaseInitialized();

                      if (_emailController.text.isNotEmpty) {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
                        if (!mounted) return;
                        messenger.showSnackBar(const SnackBar(content: Text("Link reset telah dihantar ke email anda!")));
                      } else {
                        if (!mounted) return;
                        messenger.showSnackBar(const SnackBar(content: Text("Sila masukkan email terlebih dahulu")));
                      }
                    } on FirebaseAuthException catch (e) {
                      if (!mounted) return;
                      messenger.showSnackBar(SnackBar(content: Text("Error: ${e.code} - ${e.message ?? 'Unknown error'}")));
                    } catch (e) {
                      if (!mounted) return;
                      messenger.showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
                    }
                  },
                  child: const Text("Forgot Password?", style: TextStyle(color: Colors.black87)),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await _ensureFirebaseInitialized();

                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );

                      if (!mounted) return;
                      messenger.showSnackBar(const SnackBar(content: Text("Login berjaya!")));
                      // Navigasi ke Home jika perlu
                    } on FirebaseAuthException catch (e) {
                      if (!mounted) return;
                      messenger.showSnackBar(SnackBar(content: Text("Error: ${e.code} - ${e.message ?? 'Unknown error'}")));
                    } catch (e) {
                      if (!mounted) return;
                      messenger.showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}