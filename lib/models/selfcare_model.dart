class SelfCareWellness {
  final String date; // ISO format: YYYY-MM-DD
  final int waterIntake; // in ml, tracked throughout the day
  final double sleepHours; // hours slept
  final List<String> symptoms; // e.g., ['Cramps', 'Mood Swings', 'Fatigue']
  final int painLevel; // 0-10 scale for cramps/pain
  final String? journalEntry; // optional mood journal
  final String? mood; // e.g., 'Happy', 'Sad', 'Tired', 'Energetic'
  final List<String> exercises; // e.g., ['Yoga', 'Walking', 'Stretching']
  final List<String> foodsEaten; // e.g., ['Iron-rich', 'Leafy Greens', 'Water']

  SelfCareWellness({
    required this.date,
    this.waterIntake = 0,
    this.sleepHours = 0.0,
    this.symptoms = const [],
    this.painLevel = 0,
    this.journalEntry,
    this.mood,
    this.exercises = const [],
    this.foodsEaten = const [],
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'waterIntake': waterIntake,
      'sleepHours': sleepHours,
      'symptoms': symptoms,
      'painLevel': painLevel,
      'journalEntry': journalEntry,
      'mood': mood,
      'exercises': exercises,
      'foodsEaten': foodsEaten,
    };
  }

  // Create from Firestore document
  factory SelfCareWellness.fromMap(Map<String, dynamic> map) {
    return SelfCareWellness(
      date: map['date'] ?? '',
      waterIntake: map['waterIntake'] ?? 0,
      sleepHours: (map['sleepHours'] ?? 0.0).toDouble(),
      symptoms: List<String>.from(map['symptoms'] ?? []),
      painLevel: map['painLevel'] ?? 0,
      journalEntry: map['journalEntry'],
      mood: map['mood'],
      exercises: List<String>.from(map['exercises'] ?? []),
      foodsEaten: List<String>.from(map['foodsEaten'] ?? []),
    );
  }

  SelfCareWellness copyWith({
    String? date,
    int? waterIntake,
    double? sleepHours,
    List<String>? symptoms,
    int? painLevel,
    String? journalEntry,
    String? mood,
    List<String>? exercises,
    List<String>? foodsEaten,
  }) {
    return SelfCareWellness(
      date: date ?? this.date,
      waterIntake: waterIntake ?? this.waterIntake,
      sleepHours: sleepHours ?? this.sleepHours,
      symptoms: symptoms ?? this.symptoms,
      painLevel: painLevel ?? this.painLevel,
      journalEntry: journalEntry ?? this.journalEntry,
      mood: mood ?? this.mood,
      exercises: exercises ?? this.exercises,
      foodsEaten: foodsEaten ?? this.foodsEaten,
    );
  }
}

// Predefined options for self-care tracking
class SelfCareOptions {
  static const List<String> symptoms = [
    'Cramps',
    'Headache',
    'Mood Swings',
    'Fatigue',
    'Bloating',
    'Nausea',
    'Acne',
  ];

  static const List<String> moods = [
    'Happy',
    'Sad',
    'Anxious',
    'Tired',
    'Energetic',
    'Calm',
    'Irritable',
  ];

  static const List<String> exercises = [
    'Gentle Yoga',
    'Walking',
    'Stretching',
    'Light Cardio',
    'Pilates',
    'Swimming',
    'Dancing',
  ];

  static const List<String> foods = [
    'Iron-rich Foods',
    'Leafy Greens',
    'Calcium Sources',
    'Protein',
    'Magnesium-rich Foods',
    'Omega-3 Fatty Acids',
    'Antioxidants',
  ];

  static const Map<String, String> foodDescriptions = {
    'Iron-rich Foods': 'Red meat, beans, lentils, spinach',
    'Leafy Greens': 'Spinach, kale, broccoli - rich in vitamins',
    'Calcium Sources': 'Milk, yogurt, cheese, sardines',
    'Protein': 'Chicken, fish, eggs, tofu',
    'Magnesium-rich Foods': 'Almonds, dark chocolate, pumpkin seeds',
    'Omega-3 Fatty Acids': 'Salmon, chia seeds, walnuts',
    'Antioxidants': 'Berries, dark chocolate, green tea',
  };

  static const Map<String, String> exerciseDescriptions = {
    'Gentle Yoga': 'Slow, relaxing poses to ease tension and cramps',
    'Walking': '20-30 min walk to boost mood and circulation',
    'Stretching': 'Focus on hips, lower back, and legs',
    'Light Cardio': 'Low-impact activities like cycling or elliptical',
    'Pilates': 'Core-strengthening, gentle on joints',
    'Swimming': 'Full-body, low-impact movement',
    'Dancing': 'Fun way to stay active and boost mood',
  };
}

// Cramp relief strategies
class CrampReliefTip {
  final String title;
  final String description;
  final String emoji;
  final int painLevelMin; // applicable for pain level >= this
  final int painLevelMax; // applicable for pain level <= this

  CrampReliefTip({
    required this.title,
    required this.description,
    required this.emoji,
    this.painLevelMin = 0,
    this.painLevelMax = 10,
  });
}

final List<CrampReliefTip> crampReliefTips = [
  CrampReliefTip(
    title: 'Heat Therapy',
    description:
        'Apply a heating pad or hot water bottle to your lower abdomen for 15-20 minutes. Heat relaxes muscles and reduces pain.',
    emoji: '🌡️',
    painLevelMin: 4,
  ),
  CrampReliefTip(
    title: 'Hydration',
    description:
        'Drink plenty of water and warm liquids like herbal tea. Dehydration can worsen cramps.',
    emoji: '💧',
    painLevelMin: 0,
  ),
  CrampReliefTip(
    title: 'Gentle Stretching',
    description:
        'Try child\'s pose, cat-cow stretch, or knee hugs to relieve tension in your lower back and abdomen.',
    emoji: '🧘',
    painLevelMin: 2,
  ),
  CrampReliefTip(
    title: 'Massage',
    description:
        'Gently massage your lower abdomen, lower back, or apply pressure to acupressure points.',
    emoji: '💆',
    painLevelMin: 3,
  ),
  CrampReliefTip(
    title: 'Magnesium-Rich Foods',
    description:
        'Eat almonds, dark chocolate, pumpkin seeds, or take a magnesium supplement to relax muscles.',
    emoji: '🍫',
    painLevelMin: 2,
  ),
  CrampReliefTip(
    title: 'Light Exercise',
    description:
        'A short walk or light yoga can increase blood flow and help reduce cramping pain.',
    emoji: '🚶',
    painLevelMin: 1,
  ),
  CrampReliefTip(
    title: 'Rest',
    description:
        'Give yourself permission to rest. Lie down and take slow, deep breaths to calm your body.',
    emoji: '😴',
    painLevelMin: 6,
  ),
  CrampReliefTip(
    title: 'Anti-Inflammatory Foods',
    description:
        'Consume foods with omega-3 fatty acids like salmon, berries, and ginger to reduce inflammation.',
    emoji: '🍇',
    painLevelMin: 3,
  ),
];
