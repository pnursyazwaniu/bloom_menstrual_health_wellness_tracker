import 'package:flutter/material.dart';
import 'package:bloom_menstrual_health_wellness_tracker/services/auth_service.dart';
import 'package:bloom_menstrual_health_wellness_tracker/services/firestore_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _selectedDay = DateTime.now().day;
  int? _savedPeriodStartDay;
  String? _feedbackMessage;
  DateTime? _selectedPeriodStart;
  final TextEditingController _noteController = TextEditingController();
  final Map<int, String> _dateNotes = {};
  final Map<int, String> _dateEvents = {};
  int _periodLength = 5;
  int _monthOffset = 0;
  bool _isYearView = false;
  bool _notifyNextPeriodAssumption = false;
  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCalendarData();
  }

  Future<void> _loadCalendarData() async {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) {
      return;
    }

    try {
      final data = await FirestoreService().getUserCalendarData(uid);
      if (data != null) {
        if (data['selectedPeriodStart'] != null) {
          _selectedPeriodStart = DateTime.tryParse(data['selectedPeriodStart']);
        }
        _periodLength = (data['periodLength'] as int?) ?? 5;

        final dateEvents = data['dateEvents'] as Map<String, dynamic>?;
        if (dateEvents != null) {
          _dateEvents.clear();
          _dateEvents.addEntries(dateEvents.entries.map((entry) {
            final day = int.tryParse(entry.key) ?? 0;
            return MapEntry(day, entry.value as String);
          }).where((entry) => entry.key != 0));
        }

        final dateNotes = data['dateNotes'] as Map<String, dynamic>?;
        if (dateNotes != null) {
          _dateNotes.clear();
          _dateNotes.addEntries(dateNotes.entries.map((entry) {
            final day = int.tryParse(entry.key) ?? 0;
            return MapEntry(day, entry.value as String);
          }).where((entry) => entry.key != 0));
        }
      }
    } catch (_) {
      // ignore
    }

    setState(() {
      if (_selectedPeriodStart != null) {
        _selectedDay = _selectedPeriodStart!.day;
        _savedPeriodStartDay = _selectedPeriodStart!.day;
      }
      _noteController.text = _dateNotes[_selectedDay] ?? '';
    });
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
                                  onPressed: () {
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                    } else {
                                      Navigator.of(context)
                                          .pushReplacementNamed('/home');
                                    }
                                  },
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
                                  onPressed: () {
                                    setState(() {
                                      _notifyNextPeriodAssumption =
                                          !_notifyNextPeriodAssumption;
                                    });
                                    _saveNotificationSetting(
                                      _notifyNextPeriodAssumption,
                                    );
                                  },
                                  icon: Icon(
                                    _notifyNextPeriodAssumption
                                        ? Icons.notifications_active
                                        : Icons.notifications_none,
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
                                    label: _displayedMonthName,
                                    selected: !_isYearView,
                                    onTap: () {
                                      setState(() {
                                        _isYearView = false;
                                      });
                                    },
                                  ),
                                  _buildToggleButton(
                                    label: 'Year',
                                    selected: _isYearView,
                                    onTap: () {
                                      setState(() {
                                        _isYearView = true;
                                      });
                                    },
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
                      if (_isYearView)
                        _buildYearView()
                      else
                        GestureDetector(
                          onHorizontalDragEnd: _handleMonthSwipe,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: _buildMonthView(dayCellWidth),
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
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFFB43772),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text(
                                  'Save Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFB43772),
                                  ),
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
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Period length',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '$_periodLength days',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Slider(
                                    activeColor: Colors.white,
                                    inactiveColor: Colors.white38,
                                    value: _periodLength.toDouble(),
                                    min: 3,
                                    max: 15,
                                    divisions: 12,
                                    label: '$_periodLength',
                                    onChanged: (value) {
                                      setState(() {
                                        _periodLength = value.toInt();
                                        _prepareDisplayedMonthEvents();
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10),
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
                                    onPressed: _saveNote,
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

  Widget _buildToggleButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
      ),
    );
  }

  Widget _buildCalendarRow(List<int> days, double dayCellWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) => _buildDayCell(day, dayCellWidth)).toList(),
    );
  }

  String get _displayedMonthName {
    final current = DateTime.now();
    final displayed = DateTime(current.year, current.month + _monthOffset);
    return '${_monthNames[displayed.month - 1]} ${displayed.year}';
  }

  Widget _buildMonthView(double dayCellWidth) {
    final days = _currentMonthDays();
    return Column(
      children: List.generate(
        (days.length / 7).ceil(),
        (index) => _buildCalendarRow(
          days.skip(index * 7).take(7).toList(),
          dayCellWidth,
        ),
      ),
    );
  }

  List<int> _currentMonthDays() {
    final now = DateTime.now();
    final shownMonth = DateTime(now.year, now.month + _monthOffset);
    final firstDayOfMonth = DateTime(shownMonth.year, shownMonth.month, 1);
    final int weekdayOffset = firstDayOfMonth.weekday % 7;
    final List<int> days = [];
    int dayNumber = 1 - weekdayOffset;
    while (days.length < 42) {
      days.add(dayNumber);
      dayNumber++;
    }
    return days;
  }

  void _prepareDisplayedMonthEvents() {
    if (_selectedPeriodStart != null) {
      _generatePeriodEvents();
    }
  }

  Widget _buildYearView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: List.generate(6, (rowIndex) {
          return Row(
            children: List.generate(2, (colIndex) {
              final monthIndex = rowIndex * 2 + colIndex;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2546),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _monthNames[monthIndex],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: List.generate(7, (dayIndex) {
                          return Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF42365B),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${dayIndex + 1}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  void _handleMonthSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;
    setState(() {
      if (details.primaryVelocity! < 0) {
        _monthOffset++;
      } else if (details.primaryVelocity! > 0) {
        _monthOffset--;
      }
    });
  }

  Future<void> _saveNotificationSetting(bool enabled) async {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) return;
    try {
      await FirestoreService().updateUserCalendarData(
        uid: uid,
        notifyNextPeriodAssumption: enabled,
      );
    } catch (_) {
      // ignore
    }
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

  Future<void> _saveCalendarData() async {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) return;

    if (_selectedPeriodStart != null) {
      _generatePeriodEvents();
    } else if (_savedPeriodStartDay != null) {
      _selectedPeriodStart = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        _savedPeriodStartDay!,
      );
      _generatePeriodEvents();
    }

    try {
      await FirestoreService().updateUserCalendarData(
        uid: uid,
        selectedPeriodStart: _selectedPeriodStart,
        periodLength: _periodLength,
        dateEvents: Map<int, String>.from(_dateEvents),
        dateNotes: Map<int, String>.from(_dateNotes),
        notifyNextPeriodAssumption: _notifyNextPeriodAssumption,
      );
    } catch (_) {
      // ignore for now
    }
  }

  void _generatePeriodEvents() {
    if (_selectedPeriodStart == null) return;

    _dateEvents.clear();
    final startDay = _selectedPeriodStart!.day;
    for (int day = startDay; day < startDay + _periodLength; day++) {
      if (day >= 1 && day <= 30) {
        _dateEvents[day] = 'period';
      }
    }

    final int ovulationDay = startDay + 14;
    if (ovulationDay >= 1 && ovulationDay <= 30) {
      _dateEvents[ovulationDay] = 'ovulation';
    }

    for (int fertileDay = ovulationDay - 4; fertileDay < ovulationDay; fertileDay++) {
      if (fertileDay >= 1 && fertileDay <= 30 && _dateEvents[fertileDay] != 'period') {
        _dateEvents[fertileDay] = 'fertile';
      }
    }
  }

  Future<void> _saveSelectedDate() async {
    setState(() {
      _savedPeriodStartDay = _selectedDay;
      if (_selectedPeriodStart == null || _selectedPeriodStart!.day != _selectedDay) {
        _selectedPeriodStart = DateTime(DateTime.now().year, DateTime.now().month, _selectedDay);
      }
      _generatePeriodEvents();
      _feedbackMessage = 'Period date updated successfully.';
    });
    await _saveCalendarData();
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    }
  }

  void _saveNote() {
    final note = _noteController.text.trim();
    setState(() {
      if (note.isEmpty) {
        _dateNotes.remove(_selectedDay);
        _feedbackMessage = 'Note removed for day $_selectedDay.';
      } else {
        _dateNotes[_selectedDay] = note;
        _feedbackMessage = 'Note saved for day $_selectedDay.';
      }
    });
    _saveCalendarData();
  }

  void _cancelSelectedDate() {
    setState(() {
      if (_savedPeriodStartDay != null) {
        _selectedDay = _savedPeriodStartDay!;
      }
      _noteController.text = _dateNotes[_selectedDay] ?? '';
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
