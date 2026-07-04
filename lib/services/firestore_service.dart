import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    required String dob,
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'dob': dob,
      'createdAt': FieldValue.serverTimestamp(),
      'calendarData': {
        'selectedPeriodStart': null,
        'periodLength': 5,
        'dateEvents': {},
        'dateNotes': {},
      },
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? email,
    String? dob,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (dob != null) data['dob'] = dob;
    if (data.isEmpty) return;
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserCalendarData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return null;
    return data['calendarData'] as Map<String, dynamic>?;
  }

  Future<void> updateUserCalendarData({
    required String uid,
    DateTime? selectedPeriodStart,
    int? periodLength,
    Map<int, String>? dateEvents,
    Map<int, String>? dateNotes,
  }) async {
    final Map<String, dynamic> calendarData = {};
    if (selectedPeriodStart != null) {
      calendarData['selectedPeriodStart'] = selectedPeriodStart.toIso8601String();
    }
    if (periodLength != null) {
      calendarData['periodLength'] = periodLength;
    }
    if (dateEvents != null) {
      calendarData['dateEvents'] = dateEvents.map((key, value) => MapEntry(key.toString(), value));
    }
    if (dateNotes != null) {
      calendarData['dateNotes'] = dateNotes.map((key, value) => MapEntry(key.toString(), value));
    }
    if (calendarData.isEmpty) return;
    await _db.collection('users').doc(uid).set(
      {
        'calendarData': calendarData,
      },
      SetOptions(merge: true),
    );
  }
}
