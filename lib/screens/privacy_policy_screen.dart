import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: const Color(0xFFB43772),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Text(
          'Privacy Policy\n\n'
          'Your privacy is important to us. This policy explains what information is collected and how it is used within the app.\n\n'
          '1. Information Collection\n'
          'We collect basic account details, menstrual cycle entries, and preferences to provide a personalized experience.\n\n'
          '2. Data Usage\n'
          'Collected data is used to improve your tracking experience, save your cycle history, and support wellness reminders.\n\n'
          '3. Data Security\n'
          'We protect your data with standard security practices and do not share personal information with unauthorized parties.\n\n'
          '4. Questions\n'
          'If you have questions about privacy, please reach out through the app support options.',
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Color(0xFF4F3A4E),
          ),
        ),
      ),
    );
  }
}
