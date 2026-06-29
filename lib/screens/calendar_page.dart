import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _selectedDay = 24;

  final Map<int, String> _dateEvents = {
    1: 'period',
    2: 'period',
    3: 'period',
    4: 'period',
    5: 'period',
    10: 'fertile',
    11: 'fertile',
    12: 'fertile',
    13: 'fertile',
    14: 'fertile',
    24: 'ovulation',
    28: 'period',
    29: 'period',
    30: 'period',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1732),
      child: Column(
        children: [
          Container(
            height: 110,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFB43772),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Calendar Page',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 140,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8C58A5),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: Text(
                            'Jun   Year',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('S', style: TextStyle(color: Colors.white70)),
                Text('M', style: TextStyle(color: Colors.white70)),
                Text('T', style: TextStyle(color: Colors.white70)),
                Text('W', style: TextStyle(color: Colors.white70)),
                Text('T', style: TextStyle(color: Colors.white70)),
                Text('F', style: TextStyle(color: Colors.white70)),
                Text('S', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _buildCalendarRow([30, 31, 1, 2, 3, 4, 5]),
                  const SizedBox(height: 8),
                  _buildCalendarRow([6, 7, 8, 9, 10, 11, 12]),
                  const SizedBox(height: 8),
                  _buildCalendarRow([13, 14, 15, 16, 17, 18, 19]),
                  const SizedBox(height: 8),
                  _buildCalendarRow([20, 21, 22, 23, 24, 25, 26]),
                  const SizedBox(height: 8),
                  _buildCalendarRow([27, 28, 29, 30, 1, 2, 3]),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: const BoxDecoration(
              color: Color(0xFFF8D9F1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Last period start: 2026-05-03',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE29AC9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Select period start date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5F4A7B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected date details',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _getSelectedDayTitle(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getSelectedDaySubtitle(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: TextEditingController(
                          text: _dateNotes[_selectedDay] ?? '',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _dateNotes[_selectedDay] = value;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Add note for this date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB43772),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Save date note'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSelectedDayTitle() {
    final event = _dateEvents[_selectedDay];
    if (event == 'ovulation') {
      return 'Ovulation Day, High chance of getting pregnant';
    }
    if (event == 'fertile') {
      return 'Fertile Window, Medium chance of getting pregnant';
    }
    if (event == 'period') {
      return 'Period day';
    }
    return 'No event for selected day';
  }

  String _getSelectedDaySubtitle() {
    if (_dateEvents[_selectedDay] == 'ovulation') {
      return 'Tap to add note or update period details.';
    }
    if (_dateEvents[_selectedDay] == 'fertile') {
      return 'Day carries moderate fertility chances.';
    }
    if (_dateEvents[_selectedDay] == 'period') {
      return 'Period tracking day. Edit notes as needed.';
    }
    return 'Set a note or period status for this date.';
  }

  final Map<int, String> _dateNotes = {};

  Widget _buildCalendarRow(List<int> days) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) => _buildDayCell(day)).toList(),
    );
  }

  Widget _buildDayCell(int day) {
    final event = _dateEvents[day];
    final bool isSelected = day == _selectedDay;
    final bool inMonth = day >= 1 && day <= 30;
    Color bgColor = Colors.transparent;
    Widget? marker;

    if (event == 'period') {
      bgColor = const Color(0xFFCC86AB);
      marker = const Icon(Icons.bubble_chart, color: Colors.white70, size: 12);
    } else if (event == 'fertile') {
      bgColor = const Color(0xFF8A6EE6);
      marker = const Icon(Icons.local_florist, color: Colors.white, size: 14);
    } else if (event == 'ovulation') {
      bgColor = const Color(0xFF5B48BE);
      marker = const Icon(Icons.local_florist, color: Colors.white, size: 14);
    }

    return GestureDetector(
      onTap: () {
        if (inMonth) {
          setState(() {
            _selectedDay = day;
          });
        }
      },
      child: Container(
        width: 42,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6F58A8) : bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    day.toString(),
                    style: TextStyle(
                      color: inMonth ? Colors.white : Colors.white38,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (marker != null && !isSelected) ...[
                    const SizedBox(height: 4),
                    marker,
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Positioned(
                top: 6,
                right: 6,
                child: Icon(Icons.check_circle, color: Colors.white, size: 12),
              ),
          ],
        ),
      ),
    );
  }
}
