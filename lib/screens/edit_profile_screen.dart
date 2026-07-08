import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:bloom_menstrual_health_wellness_tracker/services/auth_service.dart';
import 'package:bloom_menstrual_health_wellness_tracker/services/firestore_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  bool _loading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _dobController.addListener(_validateForm);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final snap = await FirestoreService().getUserProfile(uid);
      final data = snap.data();
      if (data != null) {
        _nameController.text = data['name'] ?? '';
        _dobController.text = data['dob'] ?? '';
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _loading = false);
      _validateForm();
    }
  }

  bool _isValidName(String name) {
    final trimmed = name.trim();
    return trimmed.length >= 3;
  }

  bool _isValidDate(String date) {
    if (date.trim().isEmpty) return false;
    final parts = date.split('/');
    if (parts.length != 3) return false;
    
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    
    if (day == null || month == null || year == null) return false;
    if (day < 1 || day > 31 || month < 1 || month > 12) return false;
    
    try {
      final dob = DateTime(year, month, day);
      final now = DateTime.now();
      
      // Pastikan tanggal tidak di masa depan
      if (dob.isAfter(now)) return false;
      
      // Check umur reasonable (5-120 tahun)
      final age = now.year - dob.year - (now.month < dob.month || (now.month == dob.month && now.day < dob.day) ? 1 : 0);
      if (age < 5 || age > 120) return false;
      
      return true;
    } catch (_) {
      return false;
    }
  }

  void _validateForm() {
    // Form validation is now done when user tries to save
    // Button is always enabled for better UX
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dobController.text.isNotEmpty
          ? DateTime.tryParse(_formatDateForPicker(_dobController.text)) ?? DateTime.now()
          : DateTime.now(),
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
    if (picked != null && mounted) {
      setState(() {
        _dobController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  String _formatDateForPicker(String dob) {
    final parts = dob.split('/');
    if (parts.length != 3) return DateTime.now().toIso8601String();
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return DateTime.now().toIso8601String();
    return DateTime(year, month, day).toIso8601String();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final dob = _dobController.text.trim();
    
    // Validation - at least one field must be filled
    if (name.isEmpty && dob.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sila isi nama atau tarikh lahir.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Validate name if provided
    if (name.isNotEmpty && !_isValidName(name)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama mestilah sekurang-kurangnya 3 aksara.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Validate date if provided
    if (dob.isNotEmpty && !_isValidDate(dob)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarikh lahir tidak sah. Sila gunakan format yang betul.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final authService = AuthService();
    final user = authService.currentUser;
    
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sila log masuk semula.')),
      );
      return;
    }

    final uid = user.uid;

    setState(() => _isSaving = true);

    try {
      await FirestoreService().updateUserProfile(
        uid: uid,
        name: name.isEmpty ? null : name,
        dob: dob.isEmpty ? null : dob,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berjaya dikemaskini!'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      String errorMessage = e.message ?? e.code;
      
      // Handle common Firebase errors
      if (e.code == 'permission-denied') {
        errorMessage = 'Anda tidak mempunyai kebenaran untuk mengemas kini profil.';
      } else if (e.code == 'unauthenticated') {
        errorMessage = 'Sila log masuk semula.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $errorMessage')),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _dobController.removeListener(_validateForm);
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFFB43772),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Color(0xFF2B1B2B)),
                    decoration: InputDecoration(
                      labelText: 'Full name',
                      labelStyle: const TextStyle(color: Color(0xFF5D3A52)),
                      floatingLabelStyle: const TextStyle(color: Color(0xFF5D3A52)),
                      filled: true,
                      fillColor: const Color(0xFFFFFFFF),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFD4C4D3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFB43772), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    style: const TextStyle(color: Color(0xFF2B1B2B)),
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      labelStyle: const TextStyle(color: Color(0xFF5D3A52)),
                      floatingLabelStyle: const TextStyle(color: Color(0xFF5D3A52)),
                      filled: true,
                      fillColor: const Color(0xFFFFFFFF),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFD4C4D3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFB43772), width: 2),
                      ),
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFFB43772),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: !_isSaving ? _save : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isSaving
                          ? const Color(0xFFB43772)
                          : const Color(0xFFD4C4D3),
                        disabledBackgroundColor: const Color(0xFFD4C4D3),
                        foregroundColor: !_isSaving
                          ? Colors.white
                          : const Color(0xFFAA9AAA),
                        disabledForegroundColor: const Color(0xFFAA9AAA),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB43772)),
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
