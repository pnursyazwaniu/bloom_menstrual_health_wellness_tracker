import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: const Color(0xFFB43772),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Text(
          'Terms of Service\n\n'
          'Welcome to Bloom Tracker. These terms describe how you may use the app and what is expected from both parties.\n\n'
          '1. Acceptance\n'
          'By using the app, you agree to these terms and our privacy practices.\n\n'
          '2. Use of the App\n'
          'You may use the app for personal menstrual health tracking and wellness planning.\n\n'
          '3. Responsibility\n'
          'The app is intended to support awareness and does not replace professional medical advice.\n\n'
          '4. Changes\n'
          'We may update these terms. Continued use means you accept any changes.\n\n'
          '5. Contact\n'
          'If you have questions about these terms, please contact support through the app.',
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
