import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bloom_menstrual_health_wellness_tracker/services/auth_service.dart';
import 'package:bloom_menstrual_health_wellness_tracker/services/firestore_service.dart';
import 'package:bloom_menstrual_health_wellness_tracker/services/notification_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();
  DateTime? _savedPeriodStartDate;
  String? _feedbackMessage;
  DateTime? _selectedPeriodStart;
  final TextEditingController _noteController = TextEditingController();
  final Map<String, String> _dateNotes = {};
  final Map<String, String> _dateEvents = {};
  StreamSubscription<Map<String, dynamic>?>? _calendarSubscription;
  int _periodLength = 5;
  int _monthOffset = 0;
  bool _isYearView = false;
  bool _notifyNextPeriodAssumption = false;
  int _daysUntilNextPeriod = 0;
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
  void initState() {
    super.initState();
    _loadCalendarData();
    _subscribeToCalendarStream();
  }

  Future<String?> _getCurrentUid() async {
    final currentUser = AuthService().currentUser;
    if (currentUser?.uid != null) {
      return currentUser!.uid;
    }
    final user = await AuthService().authStateChanges().firstWhere(
      (user) => user != null,
      orElse: () => null,
    );
    return user?.uid;
  }

  @override
  void dispose() {
    _calendarSubscription?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  void _subscribeToCalendarStream() async {
    final uid = await _getCurrentUid();
    if (uid == null) return;
    _calendarSubscription = FirestoreService().getUserCalendarDataStream(uid).listen(
      (data) {
        if (!mounted) return;
        if (data == null) return;

        final selectedPeriodStart = data['selectedPeriodStart'] != null
            ? DateTime.tryParse(data['selectedPeriodStart'])
            : null;
        final periodLength = (data['periodLength'] as int?) ?? 5;
        final dateNotes = data['dateNotes'] as Map<String, dynamic>?;

        setState(() {
          _selectedPeriodStart = selectedPeriodStart;
          _periodLength = periodLength;
          _dateNotes.clear();
          if (dateNotes != null) {
            _dateNotes.addEntries(dateNotes.entries.map((entry) {
              return MapEntry(entry.key, entry.value as String);
            }));
          }
          if (_selectedPeriodStart != null) {
            _selectedDate = _selectedPeriodStart!;
            _daysUntilNextPeriod = NotificationService()
                .calculateDaysUntilNextPeriod(periodStartDate: _selectedPeriodStart!);
          }
          _noteController.text = _dateNotes[_iso(_selectedDate)] ?? '';
          _prepareDisplayedMonthEvents();
        });
      },
      onError: (error) {
        if (kDebugMode) {
          print('Calendar stream error: $error');
        }
      },
    );
  }

  Future<void> _loadCalendarData() async {
    final uid = await _getCurrentUid();
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
            return MapEntry(entry.key, entry.value as String);
          }));
        }

        final dateNotes = data['dateNotes'] as Map<String, dynamic>?;
        if (dateNotes != null) {
          _dateNotes.clear();
          _dateNotes.addEntries(dateNotes.entries.map((entry) {
            return MapEntry(entry.key, entry.value as String);
          }));
        }
      }
    } catch (_) {
      // ignore
    }

    setState(() {
      if (_selectedPeriodStart != null) {
        _selectedDate = _selectedPeriodStart!;
        _savedPeriodStartDate = _selectedPeriodStart;
        _monthOffset = _monthOffsetForDate(_selectedPeriodStart!);
        _daysUntilNextPeriod = NotificationService()
            .calculateDaysUntilNextPeriod(periodStartDate: _selectedPeriodStart!);
      }
      _noteController.text = _dateNotes[_iso(_selectedDate)] ?? '';
      _prepareDisplayedMonthEvents();
    });
  }

  Future<void> _selectPeriodStartDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedPeriodStart ?? now,
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
    if (picked != null && mounted) {
      setState(() {
        _selectedPeriodStart = picked;
        _savedPeriodStartDate = picked;
        _selectedDate = picked;
        _monthOffset = _monthOffsetForDate(picked);
        _noteController.text = _dateNotes[_iso(_selectedDate)] ?? '';
        _generatePeriodEvents();
        _feedbackMessage = 'Period start date updated: ${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
      
      // Save to Firestore and show feedback
      final saveError = await _saveCalendarData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(saveError == null ? 'Saved period start' : saveError),
          ),
        );
      }
    }
  }

  String _iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime _shownMonthDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + _monthOffset);
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
                                    _handleNotificationToggle(
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
                            const SizedBox(height: 8),
                            if (_selectedPeriodStart != null)
                              Text(
                                'Days until next period: $_daysUntilNextPeriod days',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
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
                                    min: 5,
                                    max: 15,
                                    divisions: 10,
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
                                      _dateNotes[_iso(_selectedDate)] = value;
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
      _prepareDisplayedMonthEvents();
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

  Future<void> _handleNotificationToggle(bool enabled) async {
    await _saveNotificationSetting(enabled);

    if (enabled && _selectedPeriodStart != null) {
      // Schedule notification when enabled
      try {
        await NotificationService().scheduleNextPeriodReminder(
          periodStartDate: _selectedPeriodStart!,
          periodLength: _periodLength,
          daysBeforeNotification: 1,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Period reminder notification enabled'),
            ),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error scheduling notification: $e');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error enabling notifications: ${e.toString()}'),
            ),
          );
        }
      }
    } else if (!enabled) {
      // Cancel notifications when disabled
      try {
        await NotificationService().cancelAllNotifications();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Period reminder notifications disabled'),
            ),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error canceling notifications: $e');
        }
      }
    }
  }

  Widget _buildDayCell(int day, double dayCellWidth) {
    final shownMonth = _shownMonthDate();
    final date = DateTime(shownMonth.year, shownMonth.month, day);
    final iso = _iso(date);
    final event = _dateEvents[iso];
    final bool isSelected = _iso(_selectedDate) == iso;
    final int daysInMonth = DateTime(shownMonth.year, shownMonth.month + 1, 0).day;
    final bool inMonth = date.month == shownMonth.month && day >= 1 && day <= daysInMonth;
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
            _selectedDate = date;
            _feedbackMessage = null;
            _noteController.text = _dateNotes[iso] ?? ''; 
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
              date.day.toString(),
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
    final event = _dateEvents[_iso(_selectedDate)];
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
    if (_dateEvents[_iso(_selectedDate)] == 'ovulation') {
      return 'High chance of getting pregnant.';
    }
    if (_dateEvents[_iso(_selectedDate)] == 'fertile') {
      return 'Medium chance of fertility.';
    }
    if (_dateEvents[_iso(_selectedDate)] == 'period') {
      return 'Period tracking day.';
    }
    return 'Tap to add a note or select a date.';
  }

  Future<String?> _saveCalendarData() async {
    final uid = await _getCurrentUid();
    if (uid == null) {
      const message = 'Tidak dapat menyimpan: pengguna belum masuk.';
      if (kDebugMode) {
        print(message);
      }
      return message;
    }

    if (_selectedPeriodStart == null) {
      if (_savedPeriodStartDate != null) {
        _selectedPeriodStart = _savedPeriodStartDate;
      } else {
        _selectedPeriodStart = _selectedDate;
      }
    }

    if (_selectedPeriodStart != null) {
      _monthOffset = _monthOffsetForDate(_selectedPeriodStart!);
    }

    if (_dateEvents.isEmpty && _selectedPeriodStart != null) {
      _generatePeriodEvents();
    }

    try {
      await FirestoreService().updateUserCalendarData(
        uid: uid,
        selectedPeriodStart: _selectedPeriodStart,
        periodLength: _periodLength,
        dateEvents: Map<String, String>.from(_dateEvents),
        dateNotes: Map<String, String>.from(_dateNotes),
        notifyNextPeriodAssumption: _notifyNextPeriodAssumption,
      );
      return null;
    } catch (e, stack) {
      final message = 'Gagal menyimpan: ${e.toString()}';
      if (kDebugMode) {
        print(message);
        print(stack);
      }
      return message;
    }
  }

  void _generatePeriodEvents() {
    if (_selectedPeriodStart == null) return;

    _dateEvents.clear();
    final shownMonth = _shownMonthDate();
    final monthStart = DateTime(shownMonth.year, shownMonth.month, 1);
    final monthEnd = DateTime(shownMonth.year, shownMonth.month + 1, 0);

    // cycle length default 28 days
    const int cycleLength = 28;

    // Find cycles that could affect the shown month: compute cyclesPassed for a range
    final firstPossible = monthStart.subtract(const Duration(days: cycleLength));
    final lastPossible = monthEnd.add(const Duration(days: cycleLength));

    // Start from the nearest cycle start before or equal to firstPossible
    final baseStart = DateTime(_selectedPeriodStart!.year, _selectedPeriodStart!.month, _selectedPeriodStart!.day);
    int cyclesBefore = ((firstPossible.difference(baseStart).inDays) / cycleLength).floor();
    // ensure we include a few cycles before
    cyclesBefore = cyclesBefore - 1;

    for (int c = 0; c < 6; c++) {
      final cycleStart = baseStart.add(Duration(days: (cyclesBefore + c) * cycleLength));
      // if cycleStart is beyond lastPossible by a cycle, break
      if (cycleStart.isAfter(lastPossible)) break;

      // mark period days
      for (int i = 0; i < _periodLength; i++) {
        final d = cycleStart.add(Duration(days: i));
        if (!d.isBefore(monthStart) && !d.isAfter(monthEnd)) {
          _dateEvents[_iso(d)] = 'period';
        }
      }

      final ovulation = cycleStart.add(const Duration(days: 14));
      if (!ovulation.isBefore(monthStart) && !ovulation.isAfter(monthEnd)) {
        _dateEvents[_iso(ovulation)] = 'ovulation';
      }

      for (int f = -4; f < 0; f++) {
        final fd = ovulation.add(Duration(days: f));
        if (!fd.isBefore(monthStart) && !fd.isAfter(monthEnd)) {
          if (_dateEvents[_iso(fd)] != 'period') {
            _dateEvents[_iso(fd)] = 'fertile';
          }
        }
      }
    }
  }

  Future<void> _saveSelectedDate() async {
    setState(() {
      _savedPeriodStartDate = _selectedDate;
      if (_selectedPeriodStart == null || !_isSameDate(_selectedPeriodStart!, _selectedDate)) {
        _selectedPeriodStart = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      }
      _monthOffset = _monthOffsetForDate(_selectedPeriodStart!);
      _daysUntilNextPeriod = NotificationService()
          .calculateDaysUntilNextPeriod(periodStartDate: _selectedPeriodStart!);
      _generatePeriodEvents();
      _feedbackMessage = 'Period date updated successfully.';
    });
    final saveError = await _saveCalendarData();
    
    // Schedule notification if enabled
    if (saveError == null && _notifyNextPeriodAssumption && _selectedPeriodStart != null) {
      try {
        await NotificationService().scheduleNextPeriodReminder(
          periodStartDate: _selectedPeriodStart!,
          periodLength: _periodLength,
          daysBeforeNotification: 1,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error scheduling notification: $e');
        }
      }
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(saveError == null ? 'Saved period date' : saveError),
        ),
      );
      if (saveError == null && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    }
  }

  void _saveNote() {
    final note = _noteController.text.trim();
    setState(() {
      final key = _iso(_selectedDate);
      if (note.isEmpty) {
        _dateNotes.remove(key);
        _feedbackMessage = 'Note removed for $key.';
      } else {
        _dateNotes[key] = note;
        _feedbackMessage = 'Note saved for $key.';
      }
    });
    _saveCalendarData().then((saveError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(saveError == null ? 'Saved note' : saveError),
          ),
        );
      }
    });
  }

  void _cancelSelectedDate() {
    setState(() {
      if (_savedPeriodStartDate != null) {
        _selectedDate = _savedPeriodStartDate!;
      }
      _noteController.text = _dateNotes[_iso(_selectedDate)] ?? '';
      _feedbackMessage = null;
    });
  }

  int _monthOffsetForDate(DateTime date) {
    final now = DateTime.now();
    return (date.year - now.year) * 12 + date.month - now.month;
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
