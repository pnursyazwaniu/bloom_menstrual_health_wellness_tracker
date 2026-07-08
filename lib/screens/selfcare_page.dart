import 'dart:async';

import 'package:flutter/material.dart';

class _SelfCareItem {
  const _SelfCareItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.detail,
    this.isRelaxation = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String detail;
  final bool isRelaxation;
}

const List<_SelfCareItem> _selfCareItems = [
  _SelfCareItem(
    title: 'Relaxation',
    subtitle: 'Meditation & Breathing',
    icon: Icons.spa,
    detail:
        'Take a few deep breaths, try a short guided meditation, or listen to calming sounds to help release tension and slow your heart rate.',
    isRelaxation: true,
  ),
  _SelfCareItem(
    title: 'Healthy Habits',
    subtitle: 'Nutrition & Exercise',
    icon: Icons.local_dining,
    detail:
        'Keep your body nourished with balanced meals, hydrate often, and do gentle movement like walking or stretching to support your energy and mood.',
  ),
  _SelfCareItem(
    title: 'Mood Boosters',
    subtitle: 'Uplifting Activities',
    icon: Icons.music_note,
    detail:
        'Try a feel-good activity like listening to uplifting music, journaling your gratitude, or spending a few minutes in sunlight to lift your spirits.',
  ),
  _SelfCareItem(
    title: 'Self Love Tips',
    subtitle: 'Positive Affirmations',
    icon: Icons.favorite_border,
    detail:
        'Repeat a kind affirmation to yourself, write down something you appreciate about you, and remember it is okay to prioritize your own needs.',
  ),
];

void _showSelfCareDetail(BuildContext context, _SelfCareItem item) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.subtitle,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Text(
              item.detail,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF4B3A4F),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB43772),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showRelaxationOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Relaxation',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Pilih satu aktiviti untuk mula relaksasi anda.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB43772),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const _RelaxationMeditationPage(),
                  ),
                );
              },
              child: const Text('Meditation'),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFE4F0),
                foregroundColor: const Color(0xFFB43772),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const _RelaxationBreathingPage(),
                  ),
                );
              },
              child: const Text('Breathing Exercise'),
            ),
          ],
        ),
      );
    },
  );
}

class _RelaxationMeditationPage extends StatefulWidget {
  const _RelaxationMeditationPage({super.key});

  @override
  State<_RelaxationMeditationPage> createState() =>
      _RelaxationMeditationPageState();
}

class _RelaxationMeditationPageState extends State<_RelaxationMeditationPage>
    with SingleTickerProviderStateMixin {
  static const int _totalSeconds = 120;
  late final AnimationController _pulseController;
  Timer? _timer;
  int _remainingSeconds = _totalSeconds;
  bool _sessionComplete = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.8,
      upperBound: 1.2,
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        setState(() {
          _remainingSeconds = 0;
          _sessionComplete = true;
        });
        _pulseController.stop();
        _timer?.cancel();
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation'),
        backgroundColor: const Color(0xFFB43772),
      ),
      backgroundColor: const Color(0xFFF6D7EB),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Audio Relaxation 2 Minit',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D3A52),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Dengar audio berehat sambil melihat animasi bulatan kembang-kuncup.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseController.value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFFE4F0), Color(0xFFB43772)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(180, 55, 114, 0.2),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.music_note,
                            size: 36,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '$minutes:$seconds',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_sessionComplete) ...[
              const SizedBox(height: 20),
              const Text(
                'Well done! You’ve completed your relaxation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5D3A52),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Icon(
                      Icons.play_circle_fill,
                      size: 48,
                      color: Color(0xFFB43772),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Relaxation Video',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tonton video ringkas untuk akhir sesi dan teruskan suasana tenang.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4B3A4F),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Text(
                  'Audio sedang dimainkan. Fokus kepada pernafasan dan rasakan badan lebih tenang setiap saat.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF4B3A4F),
                    height: 1.5,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB43772),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RelaxationBreathingPage extends StatefulWidget {
  const _RelaxationBreathingPage({super.key});

  @override
  State<_RelaxationBreathingPage> createState() =>
      _RelaxationBreathingPageState();
}

class _RelaxationBreathingPageState extends State<_RelaxationBreathingPage>
    with SingleTickerProviderStateMixin {
  static const List<String> _stages = [
    'Tarik nafas 4 saat',
    'Tahan 7 saat',
    'Hembus 8 saat',
  ];
  static const List<int> _durations = [4, 7, 8];
  late final AnimationController _breathController;
  int _stageIndex = 0;
  int _stageRemaining = _durations[0];
  bool _sessionComplete = false;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.75,
      upperBound: 1.2,
    )..repeat(reverse: true);

    _nextStep();
  }

  void _nextStep() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _sessionComplete) return;
      if (_stageRemaining > 1) {
        setState(() {
          _stageRemaining -= 1;
        });
        _nextStep();
        return;
      }

      if (_stageIndex < _stages.length - 1) {
        setState(() {
          _stageIndex += 1;
          _stageRemaining = _durations[_stageIndex];
        });
        _nextStep();
        return;
      }

      setState(() {
        _sessionComplete = true;
      });
      _breathController.stop();
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathing Exercise'),
        backgroundColor: const Color(0xFFB43772),
      ),
      backgroundColor: const Color(0xFFF6D7EB),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Panduan Pernafasan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D3A52),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ikuti irama dan visual ini untuk membantu anda bernafas dengan lebih tenang.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _breathController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _breathController.value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFFECB5D6), Color(0xFFB43772)],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _sessionComplete ? 'Selesai!' : _stages[_stageIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D3A52),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _sessionComplete
                        ? 'Well done! You’ve completed your relaxation.'
                        : 'Sisa masa: ${_stageRemaining}s',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (_sessionComplete) ...[
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Icon(
                      Icons.play_circle_fill,
                      size: 48,
                      color: Color(0xFFB43772),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Video Penutup',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tonton video ringkas untuk mengakhiri sesi dengan lebih tenang dan bahagia.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4B3A4F),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB43772),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }
}

class SelfCarePage extends StatelessWidget {
  const SelfCarePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6D7EB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4F0),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bloom',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB43772),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Self Care',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B1E4F),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Daily wellness tips to help you relax, stay balanced, and feel loved.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4D3A4E),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECB5D6),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.self_improvement,
                            size: 84,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.95,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: _selfCareItems.map((item) {
                  return _SelfCareCard(
                    title: item.title,
                    subtitle: item.subtitle,
                    icon: item.icon,
                    onTap: () {
                      if (item.isRelaxation) {
                        _showRelaxationOptions(context);
                      } else {
                        _showSelfCareDetail(context, item);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4F0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Color(0xFFB43772),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Daily Affirmation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5D3A52),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'I am worthy of love and care.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF68505B),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelfCareCard extends StatelessWidget {
  const _SelfCareCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              const BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFFB43772)),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D3A52),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Color(0xFF8B6B7D)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
