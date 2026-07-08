import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bloom_menstrual_health_wellness_tracker/models/selfcare_model.dart';
import 'package:bloom_menstrual_health_wellness_tracker/services/auth_service.dart';
import 'package:bloom_menstrual_health_wellness_tracker/services/firestore_service.dart';

class SelfCarePage extends StatefulWidget {
  const SelfCarePage({super.key});

  @override
  State<SelfCarePage> createState() => _SelfCarePageState();
}

class _SelfCarePageState extends State<SelfCarePage> {
  late FirestoreService _firestoreService;
  SelfCareWellness? _todayWellness;
  StreamSubscription<SelfCareWellness?>? _wellnessSubscription;
  String _selectedDate = _getToday();

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _subscribeToTodayWellness();
  }

  @override
  void dispose() {
    _wellnessSubscription?.cancel();
    super.dispose();
  }

  static String _getToday() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _subscribeToTodayWellness() {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) return;

    _wellnessSubscription =
        _firestoreService.getSelfCareWellnessStream(uid: uid, date: _selectedDate).listen(
      (wellness) {
        if (mounted) {
          setState(() {
            _todayWellness = wellness ?? SelfCareWellness(date: _selectedDate);
          });
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('Error loading wellness data: $error');
        }
      },
    );
  }

  Future<void> _updateWellness(SelfCareWellness updated) async {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestoreService.saveSelfCareWellness(uid: uid, wellness: updated);
      setState(() {
        _todayWellness = updated;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wellness data saved successfully!')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving wellness: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6D7EB),
      appBar: AppBar(
        title: const Text('Self-Care Wellness'),
        backgroundColor: const Color(0xFFB43772),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Date selector
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date: $_selectedDate',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate =
                                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                          });
                          _wellnessSubscription?.cancel();
                          _subscribeToTodayWellness();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6629F),
                      ),
                      child: const Text('Change Date'),
                    ),
                  ],
                ),
              ),
              // Main content
              if (_todayWellness != null) ...[
                // Pain Level Tracker
                _PainLevelTracker(
                  painLevel: _todayWellness!.painLevel,
                  onChanged: (value) {
                    _updateWellness(_todayWellness!.copyWith(painLevel: value));
                  },
                ),
                // Cramp Relief Tips
                _CrampReliefSection(painLevel: _todayWellness!.painLevel),
                // Hydration Tracker
                _HydrationTracker(
                  waterIntake: _todayWellness!.waterIntake,
                  onChanged: (value) {
                    _updateWellness(_todayWellness!.copyWith(waterIntake: value));
                  },
                ),
                // Sleep Tracker
                _SleepTracker(
                  sleepHours: _todayWellness!.sleepHours,
                  onChanged: (value) {
                    _updateWellness(_todayWellness!.copyWith(sleepHours: value));
                  },
                ),
                // Symptom Tracker
                _SymptomTracker(
                  selectedSymptoms: _todayWellness!.symptoms,
                  onChanged: (symptoms) {
                    _updateWellness(_todayWellness!.copyWith(symptoms: symptoms));
                  },
                ),
                // Mood Tracker
                _MoodTracker(
                  selectedMood: _todayWellness!.mood,
                  onChanged: (mood) {
                    _updateWellness(_todayWellness!.copyWith(mood: mood));
                  },
                ),
                // Exercise Tracker
                _ExerciseTracker(
                  selectedExercises: _todayWellness!.exercises,
                  onChanged: (exercises) {
                    _updateWellness(_todayWellness!.copyWith(exercises: exercises));
                  },
                ),
                // Food Tracker
                _FoodTracker(
                  selectedFoods: _todayWellness!.foodsEaten,
                  onChanged: (foods) {
                    _updateWellness(_todayWellness!.copyWith(foodsEaten: foods));
                  },
                ),
                // Journal Entry
                _JournalEntry(
                  journalText: _todayWellness!.journalEntry ?? '',
                  onChanged: (text) {
                    _updateWellness(_todayWellness!.copyWith(journalEntry: text));
                  },
                ),
                const SizedBox(height: 20),
                // Save Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () async {
                      final uid = AuthService().currentUser?.uid;
                      if (uid != null && _todayWellness != null) {
                        await _updateWellness(_todayWellness!);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6629F),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Wellness Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Pain Level Tracker Widget
class _PainLevelTracker extends StatelessWidget {
  final int painLevel;
  final ValueChanged<int> onChanged;

  const _PainLevelTracker({
    required this.painLevel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pain Level',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('No Pain'),
              Text(
                '$painLevel / 10',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB43772),
                ),
              ),
              const Text('Severe'),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: painLevel.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: '$painLevel',
            activeColor: const Color(0xFFB43772),
            onChanged: (value) => onChanged(value.toInt()),
          ),
        ],
      ),
    );
  }
}

// Cramp Relief Section
class _CrampReliefSection extends StatelessWidget {
  final int painLevel;

  const _CrampReliefSection({required this.painLevel});

  @override
  Widget build(BuildContext context) {
    final relevantTips = crampReliefTips
        .where((tip) =>
            painLevel >= tip.painLevelMin && painLevel <= tip.painLevelMax)
        .toList();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6629F), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Relief Tips for Your Pain Level',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB43772),
            ),
          ),
          const SizedBox(height: 12),
          ...relevantTips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            tip.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// Hydration Tracker
class _HydrationTracker extends StatelessWidget {
  final int waterIntake;
  final ValueChanged<int> onChanged;

  const _HydrationTracker({
    required this.waterIntake,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final goalMl = 2000; // 2 liters daily goal
    final percentage = (waterIntake / goalMl * 100).clamp(0, 100).toInt();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💧 Hydration Goal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$waterIntake ml / ${goalMl}ml'),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB43772),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (waterIntake / goalMl).clamp(0, 1),
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB43772)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => onChanged((waterIntake + 250).clamp(0, 5000)),
                icon: const Icon(Icons.add),
                label: const Text('+ 250ml'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8A0C4),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => onChanged((waterIntake + 500).clamp(0, 5000)),
                icon: const Icon(Icons.add),
                label: const Text('+ 500ml'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8A0C4),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => onChanged((waterIntake - 250).clamp(0, 5000)),
                icon: const Icon(Icons.remove),
                label: const Text('- 250ml'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8A0C4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Sleep Tracker
class _SleepTracker extends StatelessWidget {
  final double sleepHours;
  final ValueChanged<double> onChanged;

  const _SleepTracker({
    required this.sleepHours,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '😴 Sleep Hours',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${sleepHours.toStringAsFixed(1)} hours'),
              Text(
                sleepHours < 7
                    ? 'Need more rest'
                    : sleepHours > 9
                        ? 'Well rested!'
                        : 'Good sleep',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB43772),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: sleepHours,
            min: 0,
            max: 12,
            divisions: 24,
            label: '${sleepHours.toStringAsFixed(1)}h',
            activeColor: const Color(0xFFB43772),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// Symptom Tracker
class _SymptomTracker extends StatelessWidget {
  final List<String> selectedSymptoms;
  final ValueChanged<List<String>> onChanged;

  const _SymptomTracker({
    required this.selectedSymptoms,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Symptoms',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SelfCareOptions.symptoms
                .map((symptom) => FilterChip(
                      label: Text(symptom),
                      selected: selectedSymptoms.contains(symptom),
                      onSelected: (selected) {
                        final updated = List<String>.from(selectedSymptoms);
                        if (selected) {
                          updated.add(symptom);
                        } else {
                          updated.remove(symptom);
                        }
                        onChanged(updated);
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: const Color(0xFFB43772),
                      labelStyle: TextStyle(
                        color: selectedSymptoms.contains(symptom)
                            ? Colors.white
                            : Colors.black,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// Mood Tracker
class _MoodTracker extends StatelessWidget {
  final String? selectedMood;
  final ValueChanged<String?> onChanged;

  const _MoodTracker({
    required this.selectedMood,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you feeling?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SelfCareOptions.moods
                .map((mood) => FilterChip(
                      label: Text(mood),
                      selected: selectedMood == mood,
                      onSelected: (selected) {
                        onChanged(selected ? mood : null);
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: const Color(0xFFB43772),
                      labelStyle: TextStyle(
                        color: selectedMood == mood
                            ? Colors.white
                            : Colors.black,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// Exercise Tracker
class _ExerciseTracker extends StatelessWidget {
  final List<String> selectedExercises;
  final ValueChanged<List<String>> onChanged;

  const _ExerciseTracker({
    required this.selectedExercises,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏃 Physical Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...SelfCareOptions.exercises
              .map((exercise) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: CheckboxListTile(
                      title: Text(exercise),
                      subtitle: Text(
                        SelfCareOptions.exerciseDescriptions[exercise] ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: selectedExercises.contains(exercise),
                      onChanged: (checked) {
                        final updated = List<String>.from(selectedExercises);
                        if (checked ?? false) {
                          updated.add(exercise);
                        } else {
                          updated.remove(exercise);
                        }
                        onChanged(updated);
                      },
                      activeColor: const Color(0xFFB43772),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}

// Food Tracker
class _FoodTracker extends StatelessWidget {
  final List<String> selectedFoods;
  final ValueChanged<List<String>> onChanged;

  const _FoodTracker({
    required this.selectedFoods,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🥗 Nutritional Intake',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...SelfCareOptions.foods
              .map((food) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: CheckboxListTile(
                      title: Text(food),
                      subtitle: Text(
                        SelfCareOptions.foodDescriptions[food] ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: selectedFoods.contains(food),
                      onChanged: (checked) {
                        final updated = List<String>.from(selectedFoods);
                        if (checked ?? false) {
                          updated.add(food);
                        } else {
                          updated.remove(food);
                        }
                        onChanged(updated);
                      },
                      activeColor: const Color(0xFFB43772),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}

// Journal Entry
class _JournalEntry extends StatefulWidget {
  final String journalText;
  final ValueChanged<String> onChanged;

  const _JournalEntry({
    required this.journalText,
    required this.onChanged,
  });

  @override
  State<_JournalEntry> createState() => _JournalEntryState();
}

class _JournalEntryState extends State<_JournalEntry> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.journalText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📝 Journal Entry',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'How are you feeling today? Write your thoughts...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}
