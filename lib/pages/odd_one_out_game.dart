import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bioappdr/pages/Home.dart';

class _OddRound {
  final String promptEn;
  final String promptEs;
  final List<String> itemsEn;
  final List<String> itemsEs;
  final int oddIndex;

  const _OddRound({
    required this.promptEn,
    required this.promptEs,
    required this.itemsEn,
    required this.itemsEs,
    required this.oddIndex,
  });
}

class OddOneOutGame extends StatefulWidget {
  const OddOneOutGame({super.key});

  @override
  State<OddOneOutGame> createState() => _OddOneOutGameState();
}

class _OddOneOutGameState extends State<OddOneOutGame> {
  static const int _totalRounds = 6;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpanish = false;
  int _currentIndex = 0;
  List<int> _displayOrder = [0, 1, 2, 3];

  int? _selectedDisplaySlot;
  bool? _isCorrect;
  double _sessionScore = 0;
  int _attempts = 0;
  String? _feedbackText;
  bool _feedbackIsError = false;
  bool _gameComplete = false;

  final List<_OddRound> _rounds = const [
    _OddRound(
      promptEn: 'Which one is NOT part of the nervous system?',
      promptEs: '¿Cuál NO es parte del sistema nervioso?',
      itemsEn: ['Brain', 'Heart', 'Spinal Cord', 'Nerve'],
      itemsEs: ['Cerebro', 'Corazón', 'Médula espinal', 'Nervio'],
      oddIndex: 1,
    ),
    _OddRound(
      promptEn: 'Which one does NOT help digest food?',
      promptEs: '¿Cuál NO ayuda a digerir los alimentos?',
      itemsEn: ['Brain', 'Stomach', 'Intestine', 'Liver'],
      itemsEs: ['Cerebro', 'Estómago', 'Intestino', 'Hígado'],
      oddIndex: 0,
    ),
    _OddRound(
      promptEn: 'Which one is NOT part of your face?',
      promptEs: '¿Cuál NO es parte de tu cara?',
      itemsEn: ['Eye', 'Nose', 'Kidney', 'Mouth'],
      itemsEs: ['Ojo', 'Nariz', 'Riñón', 'Boca'],
      oddIndex: 2,
    ),
    _OddRound(
      promptEn: 'Which one does NOT pump or carry blood?',
      promptEs: '¿Cuál NO bombea ni transporta sangre?',
      itemsEn: ['Heart', 'Vein', 'Artery', 'Stomach'],
      itemsEs: ['Corazón', 'Vena', 'Arteria', 'Estómago'],
      oddIndex: 3,
    ),
    _OddRound(
      promptEn: 'Which one is NOT a job of the brain?',
      promptEs: '¿Cuál NO es una función del cerebro?',
      itemsEn: ['Thinking', 'Digesting food', 'Memory', 'Controlling movement'],
      itemsEs: ['Pensar', 'Digerir alimentos', 'Memoria', 'Controlar el movimiento'],
      oddIndex: 1,
    ),
    _OddRound(
      promptEn: 'Which organ is NOT found in the chest?',
      promptEs: '¿Cuál órgano NO se encuentra en el pecho?',
      itemsEn: ['Kidneys', 'Heart', 'Lungs', 'Trachea'],
      itemsEs: ['Riñones', 'Corazón', 'Pulmones', 'Tráquea'],
      oddIndex: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _displayOrder = [0, 1, 2, 3]..shuffle(Random());
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  void _toggleLanguage() {
    setState(() {
      _isSpanish = !_isSpanish;
    });
  }

  Future<void> _speakRound() async {
    final r = _rounds[_currentIndex];
    final prompt = _isSpanish ? r.promptEs : r.promptEn;
    final items = _isSpanish ? r.itemsEs : r.itemsEn;
    final ordered = _displayOrder.map((i) => items[i]).join(', ');
    final text = _isSpanish
        ? '$prompt Opciones: $ordered.'
        : '$prompt Choices: $ordered.';
    try {
      await _flutterTts.stop();
      await _flutterTts.setLanguage(_isSpanish ? 'es-ES' : 'en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  Future<void> _addToTotalScore(double sessionScore) async {
    final prefs = await SharedPreferences.getInstance();
    double total = prefs.getDouble('totalScore') ?? 0.0;
    total += sessionScore;
    await prefs.setDouble('totalScore', total);
  }

  Future<void> _updateProgress(int roundsCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('oddoneout_progress', roundsCompleted);
  }

  void _onChoiceTapped(int displaySlot) {
    if (_gameComplete) return;
    if (_selectedDisplaySlot != null && _isCorrect == true) return;

    final r = _rounds[_currentIndex];
    final int actualIndex = _displayOrder[displaySlot];
    final bool correct = actualIndex == r.oddIndex;

    if (correct) {
      setState(() {
        _selectedDisplaySlot = displaySlot;
        _isCorrect = true;
        _feedbackIsError = false;
        _feedbackText =
            _isSpanish ? '¡Correcto! 🎉' : 'Correct! 🎉';
      });
      if (_attempts == 0) {
        _sessionScore += 1.0;
      } else if (_attempts == 1) {
        _sessionScore += 0.5;
      }
      _updateProgress(_currentIndex + 1);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        if (_currentIndex < _rounds.length - 1) {
          final nextOrder = [0, 1, 2, 3]..shuffle(Random());
          setState(() {
            _currentIndex++;
            _selectedDisplaySlot = null;
            _isCorrect = null;
            _attempts = 0;
            _feedbackText = null;
            _displayOrder = nextOrder;
          });
        } else {
          _addToTotalScore(_sessionScore);
          _updateProgress(_totalRounds);
          setState(() {
            _gameComplete = true;
            _feedbackIsError = false;
            _feedbackText = _isSpanish
                ? '¡Terminaste! Puntuación: $_sessionScore de $_totalRounds.'
                : 'All rounds done! You scored $_sessionScore out of $_totalRounds.';
          });
        }
      });
    } else {
      _attempts++;
      final String scoreLine = _isSpanish
          ? 'Puntuación: $_sessionScore'
          : 'Score: $_sessionScore';
      setState(() {
        _selectedDisplaySlot = displaySlot;
        _isCorrect = false;
        _feedbackIsError = true;
        if (_attempts < 2) {
          _feedbackText = _isSpanish
              ? 'Casi — prueba otra opción. ($scoreLine)'
              : 'Not quite — try another. ($scoreLine)';
        } else {
          _feedbackText = _isSpanish
              ? 'Sin puntos extra tras dos intentos; sigue hasta acertar. ($scoreLine)'
              : 'No extra points after two tries — keep tapping until you find it. ($scoreLine)';
        }
      });
    }
  }

  void _returnToHome() {
    Navigator.pushReplacementNamed(context, '/');
    Future.delayed(const Duration(milliseconds: 100), () {
      Home.refreshHomeData();
    });
  }

  Future<void> _restartGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('oddoneout_progress', 0);
    setState(() {
      _currentIndex = 0;
      _sessionScore = 0;
      _attempts = 0;
      _selectedDisplaySlot = null;
      _isCorrect = null;
      _feedbackText = null;
      _feedbackIsError = false;
      _gameComplete = false;
      _displayOrder = [0, 1, 2, 3]..shuffle(Random());
    });
    Home.refreshHomeData();
  }

  Color _cardColor(int displaySlot) {
    if (_selectedDisplaySlot == null) {
      return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
    if (displaySlot != _selectedDisplaySlot) {
      return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
    if (_isCorrect == true) {
      return Colors.green.shade100;
    }
    return Colors.red.shade100;
  }

  @override
  Widget build(BuildContext context) {
    final r = _rounds[_currentIndex];
    final prompt = _isSpanish ? r.promptEs : r.promptEn;
    final items = _isSpanish ? r.itemsEs : r.itemsEn;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: Text(
          _isSpanish ? 'Impar / Clasificar' : 'Odd One Out',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 28,
            letterSpacing: 0.5,
            fontFamily: 'LuckiestGuy',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: _isSpanish ? 'English' : 'Español',
            onPressed: _toggleLanguage,
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            tooltip: _isSpanish ? 'Leer' : 'Speak',
            onPressed: _speakRound,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${_currentIndex + 1} / $_totalRounds',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_isSpanish ? 'Puntuación' : 'Score'}: $_sessionScore',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              prompt,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isSpanish ? 'Toca el que no encaja.' : 'Tap the one that doesn\'t belong.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (displaySlot) {
                    final int itemIndex = _displayOrder[displaySlot];
                    final String label = items[itemIndex];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: displaySlot < 3 ? 12 : 0,
                      ),
                      child: Material(
                        color: _cardColor(displaySlot),
                        borderRadius: BorderRadius.circular(28),
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: _gameComplete
                              ? null
                              : () => _onChoiceTapped(displaySlot),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 16,
                            ),
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                                fontFamily: 'LuckiestGuy',
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            if (_feedbackText != null) ...[
              const SizedBox(height: 20),
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    key: ValueKey(_feedbackText),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width - 48,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: _gameComplete
                          ? Colors.green.shade50
                          : (_feedbackIsError
                              ? Colors.deepOrange.shade50
                              : Colors.green.shade50),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _gameComplete
                            ? Colors.green.shade300
                            : (_feedbackIsError
                                ? Colors.deepOrange.shade200
                                : Colors.green.shade300),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _feedbackText!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                            fontFamily: 'LuckiestGuy',
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (_gameComplete) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _restartGame,
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(
                              _isSpanish
                                  ? 'Jugar de nuevo'
                                  : 'Play again',
                            ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: _returnToHome,
                            icon: const Icon(Icons.home_rounded),
                            label: Text(
                              _isSpanish
                                  ? 'Volver al inicio'
                                  : 'Return to Home',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
