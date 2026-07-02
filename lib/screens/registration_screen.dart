import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bloom_menstrual_health_wellness_tracker/services/auth_service.dart';
import 'package:bloom_menstrual_health_wellness_tracker/services/firestore_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _isPasswordVisible = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFB43772),
              onPrimary: Colors.white,
              onSurface: Color(0xFF5D3A52),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFB43772),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7E4F1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/images/logo.png', height: 80),
                    const SizedBox(height: 16),
                    const Text(
                      'Create Your Account',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D3A52),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Fill in your details to start tracking your menstrual wellness.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7B5C7A),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField('Full Name', _nameController),
                    _buildTextField('Email', _emailController),
                    _buildTextField(
                      'Password',
                      _passwordController,
                      isPassword: true,
                    ),
                    _buildTextField(
                      'Confirm Password',
                      _confirmPasswordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Date of Birth',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D3A52),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _dobController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF5F1F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFFB43772),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final name = _nameController.text.trim();
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();
                          final confirmPassword =
                              _confirmPasswordController.text.trim();
                          final dob = _dobController.text.trim();

                          if (name.isEmpty ||
                              email.isEmpty ||
                              password.isEmpty ||
                              confirmPassword.isEmpty ||
                              dob.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Sila lengkapkan semua medan.'),
                              ),
                            );
                            return;
                          }
                          if (password != confirmPassword) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Password tidak sepadan!'),
                              ),
                            );
                            return;
                          }

                          try {
                            final credential =
                                await AuthService().register(email, password);
                            final uid = credential.user?.uid;
                            if (uid != null) {
                              await FirestoreService().createUserProfile(
                                uid: uid,
                                name: name,
                                email: email,
                                dob: dob,
                              );
                            }
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Pendaftaran berjaya. Sila log masuk.',
                                ),
                              ),
                            );
                            Navigator.pushReplacementNamed(context, '/login');
                          } on FirebaseAuthException catch (e) {
                            final message = e.code == 'email-already-in-use'
                                ? 'Email telah digunakan. Sila log masuk.'
                                : e.message ?? 'Pendaftaran gagal.';
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(message),
                              ),
                            );
                          } catch (_) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Pendaftaran gagal. Sila cuba lagi.'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1A9C4),
                          foregroundColor: const Color(0xFF2B1B2B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(color: Color(0xFF7B5C7A)),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Color(0xFFB43772),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D3A52),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: isPassword ? !_isPasswordVisible : false,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF5F1F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFFB43772),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
