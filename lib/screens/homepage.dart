import 'package:flutter/material.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/calendar_page.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/profile_page.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/selfcare_page_enhanced.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/today_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Index untuk simpan page mana yang aktif
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

  late final List<Widget> _pages = <Widget>[
    TodayPage(tabNotifier: _selectedIndexNotifier),
    const CalendarPage(),
    const SelfCarePage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedIndexNotifier.value = index;
    });
  }

  @override
  void dispose() {
    _selectedIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6D7EB),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFB43772),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sunny), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Self-care',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
