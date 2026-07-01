import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _selectedDay = 24;
  int? _savedPeriodStartDay;
  String? _feedbackMessage;
  DateTime? _selectedPeriodStart;
  final TextEditingController _noteController = TextEditingController();
  final Map<int, String> _dateNotes = {};

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
  };

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectPeriodStartDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
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
        _selectedPeriodStart = picked;
        _selectedDay = picked.day;
        _noteController.text = _dateNotes[_selectedDay] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1732),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1024),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth > 720;
                final double dayCellWidth = isWide ? 52.0 : 44.0;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                        decoration: const BoxDecoration(
                          color: Color(0xFFB43772),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(28),
                            bottomRight: Radius.circular(28),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'CALENDAR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.notifications_none,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8C58A5),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  _buildToggleButton(
                                    label: 'Jun',
                                    selected: true,
                                  ),
                                  _buildToggleButton(
                                    label: 'Year',
                                    selected: false,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            _DayLabel('S'),
                            _DayLabel('M'),
                            _DayLabel('T'),
                            _DayLabel('W'),
                            _DayLabel('T'),
                            _DayLabel('F'),
                            _DayLabel('S'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            _buildCalendarRow([
                              30,
                              31,
                              1,
                              2,
                              3,
                              4,
                              5,
                            ], dayCellWidth),
                            const SizedBox(height: 8),
                            _buildCalendarRow([
                              6,
                              7,
                              8,
                              9,
                              10,
                              11,
                              12,
                            ], dayCellWidth),
                            const SizedBox(height: 8),
                            _buildCalendarRow([
                              13,
                              14,
                              15,
                              16,
                              17,
                              18,
                              19,
                            ], dayCellWidth),
                            const SizedBox(height: 8),
                            _buildCalendarRow([
                              20,
                              21,
                              22,
                              23,
                              24,
                              25,
                              26,
                            ], dayCellWidth),
                            const SizedBox(height: 8),
                            _buildCalendarRow([
                              27,
                              28,
                              29,
                              30,
                              1,
                              2,
                              3,
                            ], dayCellWidth),
                          ],
                        ),
                      ),
                      if (_feedbackMessage != null) ...[
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFED8E8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _feedbackMessage!,
                              style: const TextStyle(
                                color: Color(0xFF6F3A52),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _cancelSelectedDate,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFFB43772),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Color(0xFFB43772),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _saveSelectedDate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB43772),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text(
                                  'Save Date',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 22,
                        ),
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
                            Text(
                              'Last period start: ${_selectedPeriodStart != null ? '${_selectedPeriodStart!.year}-${_selectedPeriodStart!.month.toString().padLeft(2, '0')}-${_selectedPeriodStart!.day.toString().padLeft(2, '0')}' : '2026-05-03'}',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _selectPeriodStartDate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE29AC9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text(
                                  'Select period start date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB43772),
                                borderRadius: BorderRadius.circular(20),
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
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _noteController,
                                    onChanged: (value) {
                                      _dateNotes[_selectedDay] = value;
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'Add note for this date',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                    ),
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _feedbackMessage =
                                            'Note saved for day $_selectedDay';
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFFB43772),
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
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({required String label, required bool selected}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFF8C58A5) : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarRow(List<int> days, double dayCellWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) => _buildDayCell(day, dayCellWidth)).toList(),
    );
  }

  Widget _buildDayCell(int day, double dayCellWidth) {
    final event = _dateEvents[day];
    final bool isSelected = day == _selectedDay;
    final bool inMonth = day >= 1 && day <= 30;
    final bool isPeriod = event == 'period';
    final bool isFertile = event == 'fertile';
    final bool isOvulation = event == 'ovulation';

    final Color fillColor = isSelected
        ? const Color(0xFF7C5AE0)
        : isPeriod
        ? const Color(0xFFD6629F)
        : inMonth
        ? const Color(0xFF2C2546)
        : Colors.transparent;

    return GestureDetector(
      onTap: () {
        if (inMonth) {
          setState(() {
            _selectedDay = day;
            _feedbackMessage = null;
            _noteController.text = _dateNotes[_selectedDay] ?? '';
          });
        }
      },
      child: Container(
        width: dayCellWidth,
        height: 58,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF3F3560), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.toString(),
              style: TextStyle(
                color: inMonth ? Colors.white : Colors.white38,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            if (isFertile || isOvulation)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9DD0),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getSelectedDayTitle() {
    final event = _dateEvents[_selectedDay];
    if (event == 'ovulation') {
      return 'Ovulation Day';
    }
    if (event == 'fertile') {
      return 'Fertile Window';
    }
    if (event == 'period') {
      return 'Period Day';
    }
    return 'No event selected';
  }

  String _getSelectedDaySubtitle() {
    if (_dateEvents[_selectedDay] == 'ovulation') {
      return 'High chance of getting pregnant.';
    }
    if (_dateEvents[_selectedDay] == 'fertile') {
      return 'Medium chance of fertility.';
    }
    if (_dateEvents[_selectedDay] == 'period') {
      return 'Period tracking day.';
    }
    return 'Tap to add a note or select a date.';
  }

  void _saveSelectedDate() {
    setState(() {
      _savedPeriodStartDay = _selectedDay;
      _dateEvents[_selectedDay] = 'period';
      _feedbackMessage = 'Period date updated successfully.';
    });
  }

  void _cancelSelectedDate() {
    setState(() {
      if (_savedPeriodStartDay != null) {
        _selectedDay = _savedPeriodStartDay!;
      }
      _feedbackMessage = null;
    });
  }
}

class _DayLabel extends StatelessWidget {
  final String label;

  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
