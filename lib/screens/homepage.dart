import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Index untuk simpan page mana yang aktif

  // Senarai Page (Nanti awak boleh buat fail berasingan untuk setiap page)
  static const List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('Today Page')),     // Index 0
    Center(child: Text('Calendar Page')),  // Index 1
    Center(child: Text('Self-care Page')), // Index 2
    Center(child: Text('History Page')),   // Index 3
    Center(child: Text('Profile Page')),   // Index 4
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFAC5D87),
        title: const Row(
          children: [
            Icon(Icons.settings, color: Colors.white),
            SizedBox(width: 10),
            Text("Bloom - Menstrual Tracker", style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
      // Body akan berubah mengikut index yang dipilih
      body: _selectedIndex == 0 
          ? _buildTodayContent() // Papar UI Today kalau index 0
          : _widgetOptions.elementAt(_selectedIndex),
      
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFC48CB3), // Warna pink bawah
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sunny), label: 'Today'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Self-care'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Ini UI asal yang awak nak tadi (untuk page Today)
  Widget _buildTodayContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Welcome to Bloom", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF8BBD0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Current Cycle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Started Apr 23, 2026"),
                Text("Day 1"),
                Text("Flow Level :"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF48FB1),
            child: const Text("Next Period Prediction\nLog at least 2 cycles to see predictions"),
          ),
          const SizedBox(height: 30),
          const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFAC5D87)),
                  child: const Text("Log Period", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  child: const Text("View History", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}