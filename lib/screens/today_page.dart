import 'package:flutter/material.dart';
import 'package:bloom_menstrual_health_wellness_tracker/screens/calendar_page.dart';
import 'package:bloom_menstrual_health_wellness_tracker/services/auth_service.dart';
import 'package:bloom_menstrual_health_wellness_tracker/services/firestore_service.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  bool _periodOngoing = false;
  DateTime? _periodStartDate;
  final List<String> _symptomOptions = ['Cramps', 'Mood Swings', 'Fatigue'];
  final Set<String> _selectedSymptoms = {};
  final int _periodLengthDays = 5;
  final int _nextPeriodDays = 0;
  String _userName = '';
  

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        setState(() {});
      }
      return;
    }

    try {
      final snap = await FirestoreService().getUserProfile(uid);
      final data = snap.data();
      if (data != null && mounted) {
        setState(() {
          _userName = data['name'] ?? '';
        });
      } else if (mounted) {
        setState(() {});
      }
    } catch (_) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  int get _remainingPeriodDays {
    if (!_periodOngoing || _periodStartDate == null) return _nextPeriodDays;
    final daysPassed = DateTime.now().difference(_periodStartDate!).inDays + 1;
    final remaining = _periodLengthDays - daysPassed;
    return remaining < 0 ? 0 : remaining;
  }

  String get _periodStatusText =>
      _periodOngoing ? 'Period Ongoing' : 'Next Period';

  String get _periodDetailText {
    if (_periodOngoing && _periodStartDate != null) {
      final formattedDate =
          '${_periodStartDate!.year}-${_periodStartDate!.month.toString().padLeft(2, '0')}-${_periodStartDate!.day.toString().padLeft(2, '0')}';
      return 'Started: $formattedDate';
    }
    return 'Starts in $_nextPeriodDays days';
  }

  String get _statusValueText {
    if (_periodOngoing) {
      return '$_remainingPeriodDays days left in cycle';
    }
    return '$_nextPeriodDays Days Left';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6D7EB),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 720;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hi, ${_userName.isNotEmpty ? _userName : 'there'}',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF5D3A52),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Your cycle summary',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF7B5C7A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Hi, ${_userName.isNotEmpty ? _userName : 'there'}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5D3A52),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Your cycle summary',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF7B5C7A),
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB43772),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _periodStatusText,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _statusValueText,
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _periodDetailText,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CalendarPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFFB43772),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _InfoCard(
                            title: 'Cycle Day',
                            subtitle: _periodOngoing && _periodStartDate != null
                                ? 'Day ${DateTime.now().difference(_periodStartDate!).inDays + 1}'
                                : 'Next cycle',
                            color: const Color(0xFFF9B9D9),
                          ),
                          const SizedBox(height: 14),
                          _InfoCard(
                            title: 'Status',
                            subtitle: _periodOngoing ? 'Ongoing' : 'Upcoming',
                            color: const Color(0xFFF9B9D9),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _SectionCard(
                        title: 'Symptoms Tracker',
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _symptomOptions.map((symptom) {
                            final selected = _selectedSymptoms.contains(
                              symptom,
                            );
                            return ChoiceChip(
                              label: Text(symptom),
                              selected: selected,
                              onSelected: (_) {
                                setState(() {
                                  if (selected) {
                                    _selectedSymptoms.remove(symptom);
                                  } else {
                                    _selectedSymptoms.add(symptom);
                                  }
                                });
                              },
                              selectedColor: const Color(0xFFB43772),
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF5D3A52),
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _SectionCard(
                        title: 'Self-care Tips',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            _TipLine(
                              text: 'Drink warm water throughout the day.',
                            ),
                            _TipLine(
                              text: 'Get enough rest and nap if needed.',
                            ),
                            _TipLine(text: 'Use a heating pad to ease cramps.'),
                          ],
                        ),
                      ),
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
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D3A52),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TipLine extends StatelessWidget {
  const _TipLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFB43772), size: 18),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF4B3A4F)),
            ),
          ),
        ],
      ),
    );
  }
}
