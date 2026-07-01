import 'package:flutter/material.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({Key? key}) : super(key: key);

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  bool _periodOngoing = false;
  DateTime? _periodStartDate;
  bool _notificationsEnabled = false;
  final List<String> _symptomOptions = ['Cramps', 'Mood Swings', 'Fatigue'];
  final Set<String> _selectedSymptoms = {};
  final int _periodLengthDays = 5;
  final int _nextPeriodDays = 9;

  void _onPeriodStarts() {
    setState(() {
      _periodOngoing = true;
      _periodStartDate = DateTime.now();
      _selectedSymptoms.clear();
    });
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
      return '${_remainingPeriodDays} days left in cycle';
    }
    return '$_nextPeriodDays Days Left';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: const Color(0xFFF6D7EB),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _periodStatusText,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Text(
                  _statusValueText,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _periodDetailText,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 170,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _periodOngoing ? null : _onPeriodStarts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _periodOngoing
                          ? Colors.grey
                          : const Color(0xFF5BA6E6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _periodOngoing ? 'Period Started' : 'Period Starts',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          title: 'Cycle Day',
                          subtitle: _periodOngoing && _periodStartDate != null
                              ? 'Day ${DateTime.now().difference(_periodStartDate!).inDays + 1}'
                              : 'Next cycle',
                          color: const Color(0xFFF9B9D9),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoCard(
                          title: 'Status',
                          subtitle: _periodOngoing ? 'Ongoing' : 'Upcoming',
                          color: const Color(0xFFF9B9D9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Symptoms Tracker',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _symptomOptions.map((symptom) {
                        final selected = _selectedSymptoms.contains(symptom);
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
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Self-care Tips',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _TipLine(text: 'Drink warm water throughout the day.'),
                        _TipLine(text: 'Get enough rest and nap if needed.'),
                        _TipLine(text: 'Use a heating pad to ease cramps.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'Daily Notifications',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Remind me daily to log symptoms.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4B3A4F),
                            ),
                          ),
                        ),
                        Switch(
                          value: _notificationsEnabled,
                          activeColor: const Color(0xFFB43772),
                          onChanged: (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
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
          Expanded(
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
