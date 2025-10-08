import 'dart:math';
import 'dart:math' as math show sin, pi;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bioappdr/pages/Home.dart';

class WordScrambleGameV2 extends StatefulWidget {
  const WordScrambleGameV2({super.key});
  @override
  State<WordScrambleGameV2> createState() => _WordScrambleGameV2State();
}

class _WordScrambleGameV2State extends State<WordScrambleGameV2>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> _items = [
    {
      'en': 'HEART',
      'es': 'CORAZÓN',
      'hint_en': 'It pumps blood.',
      'hint_es': 'Bombea la sangre.',
      'img': 'assets/heart.jpeg'
    },
    {
      'en': 'LUNGS',
      'es': 'PULMONES',
      'hint_en': 'They help you breathe.',
      'hint_es': 'Te ayudan a respirar.',
      'img': 'assets/lungs.jpeg'
    },
    {
      'en': 'BRAIN',
      'es': 'CEREBRO',
      'hint_en': 'Body control centre.',
      'hint_es': 'Centro de control del cuerpo.',
      'img': 'assets/brain.jpg'
    },
    {
      'en': 'LIVER',
      'es': 'HÍGADO',
      'hint_en': 'Filters your blood.',
      'hint_es': 'Filtra tu sangre.',
      'img': 'assets/liver.jpeg'
    },
    {
      'en': 'STOMACH',
      'es': 'ESTÓMAGO',
      'hint_en': 'Digests food.',
      'hint_es': 'Digiere la comida.',
      'img': 'assets/stomach.jpeg'
    },
  ];

  late List<int> _wordOrder; // shuffled order of indices
  int _currentWord = 0; // index in _wordOrder
  int _attempts = 0; // attempts for current word
  double _sessionScore = 0.0;
  double _totalScore = 0.0;
  bool _gameOver = false;
  bool _spanish = false; // master translation toggle
  late List<String> _pool;
  final List<String> _typed = [];
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _initGame();
    _loadTotalScore();
  }

  void _initGame() {
    _wordOrder = List.generate(_items.length, (i) => i)..shuffle(Random());
    _currentWord = 0;
    _sessionScore = 0.0;
    _gameOver = false;
    _reset();
  }

  Future<void> _loadTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalScore = prefs.getDouble('totalScore') ?? 0.0;
    });
  }

  Future<void> _addToTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    _totalScore += _sessionScore;
    await prefs.setDouble('totalScore', _totalScore);
    setState(() {});
  }

  Future<void> _updateProgress(int wordsCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('wordscramble_progress', wordsCompleted);
  }

  void _reset() {
    _typed.clear();
    _attempts = 0;
    final word = _items[_wordOrder[_currentWord]]['en'] ?? '';
    _pool = word.split('')..shuffle(Random());
  }

  void _tap(int i) {
    setState(() {
      _typed.add(_pool[i]);
      _pool[i] = '';
    });
    _verify();
  }

  void _verify() {
    final answer = _items[_wordOrder[_currentWord]]['en'] ?? '';
    if (_typed.length < answer.length) return;
    _attempts++;
    final correct = _typed.join() == answer;
    if (correct) {
      double earned = 0.0;
      if (_attempts == 1) {
        earned = 1.0;
      } else if (_attempts == 2) {
        earned = 0.5;
      }
      _sessionScore += earned;
      _updateProgress(_currentWord + 1); // Update progress for each completed word
      _showSnack(true, earned);
      Future.delayed(const Duration(milliseconds: 600), _next);
    } else {
      _showSnack(false, 0);
      _shake.forward(from: 0);
      HapticFeedback.vibrate();
      Future.delayed(const Duration(milliseconds: 600), () => setState(_reset));
    }
  }

  void _next() {
    if (_currentWord + 1 >= _wordOrder.length) {
      setState(() {
        _gameOver = true;
      });
      _onGameComplete();
    } else {
      setState(() {
        _currentWord++;
        _reset();
      });
    }
  }

  void _shuffleUnused() => setState(() => _pool.shuffle(Random()));

  void _showSnack(bool good, double earned) {
    String msg;
    if (good) {
      msg = (_spanish ? '¡Correcto!' : 'Correct!') + (earned > 0 ? ' (+$earned)' : '');
    } else {
      msg = _spanish ? 'Inténtalo de nuevo' : 'Try again';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg + (_gameOver ? '' : '  Score: ${_sessionScore.toStringAsFixed(1)}')),
        backgroundColor: good ? Colors.green : Colors.red,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  Future<void> _onGameComplete() async {
    await _addToTotalScore(); // Ensure score is saved before showing dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_spanish ? 'Juego terminado' : 'Game Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text((_spanish ? 'Puntuación de la sesión: ' : 'Session Score: ') + _sessionScore.toStringAsFixed(1)),
            const SizedBox(height: 8),
            Text((_spanish ? 'Puntuación total: ' : 'Total Score: ') + _totalScore.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/');
              // Refresh home data after navigation
              Future.delayed(const Duration(milliseconds: 100), () {
                Home.refreshHomeData();
              });
            },
            child: Text(_spanish ? 'Volver a inicio' : 'Return to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_gameOver) {
      // Show a summary screen instead of a blank screen
      return Scaffold(
        appBar: AppBar(
          title: Text(_spanish ? 'Juego terminado' : 'Game Complete'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                (_spanish ? 'Puntuación de la sesión: ' : 'Session Score: ') + _sessionScore.toStringAsFixed(1),
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                (_spanish ? 'Puntuación total: ' : 'Total Score: ') + _totalScore.toStringAsFixed(1),
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Refresh home data after navigation
                  Future.delayed(const Duration(milliseconds: 100), () {
                    Home.refreshHomeData();
                  });
                },
                child: Text(_spanish ? 'Volver a inicio' : 'Return to Home'),
              ),
            ],
          ),
        ),
      );
    }
    final item = _items[_wordOrder[_currentWord]];
    final progress = (_currentWord + 1) / _wordOrder.length;
    final wordEn = item['en'] ?? '';
    final wordEs = item['es'] ?? '';
    final hint = _spanish ? (item['hint_es'] ?? '') : (item['hint_en'] ?? '');
    final imagePath = item['img'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(_spanish ? 'Anagrama' : 'Word Scramble'),
        actions: [
          IconButton(
            tooltip: _spanish ? 'Traducir' : 'Translate',
            icon: const Icon(Icons.translate),
            onPressed: () => setState(() => _spanish = !_spanish),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text('${_currentWord + 1}/${_wordOrder.length}', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress, color: theme.colorScheme.onPrimary),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: _spanish ? 'Barajar' : 'Shuffle',
        onPressed: _shuffleUnused,
        child: const Icon(Icons.shuffle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (imagePath.isNotEmpty) Image.asset(imagePath, height: 160),
              const SizedBox(height: 12),
              Text('${_spanish ? 'Pista' : 'Hint'}: $hint', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 6),
              Text(
                _spanish ? 'English: $wordEn' : 'Spanish: $wordEs',
                style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Wrap(
                children: List.generate(wordEn.length, (i) {
                  final char = i < _typed.length ? _typed[i] : '_';
                  return AnimatedBuilder(
                    animation: _shake,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(math.sin(_shake.value * math.pi * 4) * 6, 0),
                      child: child,
                    ),
                    child: _slot(char, filled: i < _typed.length, theme: theme),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                children: List.generate(_pool.length, (i) {
                  final l = _pool[i];
                  return l.isEmpty
                      ? const SizedBox(width: 0)
                      : Padding(
                    padding: const EdgeInsets.all(4),
                    child: ElevatedButton(
                      onPressed: () => _tap(i),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Text(l, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Text(
                (_spanish ? 'Puntuación de la sesión: ' : 'Session Score: ') + _sessionScore.toStringAsFixed(1),
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.blueGrey, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slot(String letter, {required bool filled, required ThemeData theme}) => Container(
    margin: const EdgeInsets.all(4),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: filled ? Colors.green.shade100 : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(letter, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
  );

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }
}
