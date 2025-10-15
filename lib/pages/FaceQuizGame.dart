import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bioappdr/pages/Home.dart';

class FaceQuizGame extends StatefulWidget {
  const FaceQuizGame({Key? key}) : super(key: key);

  @override
  _FaceQuizGameState createState() => _FaceQuizGameState();
}

class _FaceQuizGameState extends State<FaceQuizGame> with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpanish = false;
  int _currentQuestion = 0;
  int _attempts = 0;
  double _sessionScore = 0.0;
  List<int> _questionOrder = [];
  bool _showFeedback = false;
  bool _isCorrect = false;
  String _feedbackMessage = '';
  List<Map<String, String>> _lessons = [];
  List<String> _options = [];
  String _correctAnswer = '';

  // Animation controllers
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _setupLessons();
    _initAnimations();
    _startQuiz();
  }

  void _setupLessons() {
    _lessons = [
      {'title_en': 'Eyes', 'image': 'assets/eyes.jpeg', 'desc_en': 'Allow vision.'},
      {'title_en': 'Ears', 'image': 'assets/ears.jpeg', 'desc_en': 'Enable hearing.'},
      {'title_en': 'Nose', 'image': 'assets/nose.jpeg', 'desc_en': 'Sense smell.'},
      {'title_en': 'Mouth', 'image': 'assets/mouth.png', 'desc_en': 'Enable speech.'},
      {'title_en': 'Teeth', 'image': 'assets/teeth.jpeg', 'desc_en': 'Chew food.'},
      {'title_en': 'Tongue', 'image': 'assets/tongue.jpeg', 'desc_en': 'Taste and speak.'},
    ];
  }

  void _initAnimations() {
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  void _startQuiz() {
    _sessionScore = 0.0;
    _currentQuestion = 0;
    _attempts = 0;
    _questionOrder = List.generate(_lessons.length, (i) => i)..shuffle();
    _prepareQuestion();
  }

  void _prepareQuestion() {
    setState(() {
      _showFeedback = false;
      _isCorrect = false;
      if (_currentQuestion < _lessons.length) {
        final lesson = _lessons[_questionOrder[_currentQuestion]];
        _correctAnswer = lesson['desc_en']!;
        // Create options list with correct answer and 2 random different answers
        _options = [];
        _options.add(_correctAnswer);
        while (_options.length < 3) {
          int randomIndex = Random().nextInt(_lessons.length);
          String randomAnswer = _lessons[randomIndex]['desc_en']!;
          if (!_options.contains(randomAnswer)) {
            _options.add(randomAnswer);
          }
        }
        _options.shuffle();
        _attempts = 0;
      }
    });
  }

  void _checkAnswer(String choice) async {
    if (_showFeedback) return;
    setState(() {
      _showFeedback = true;
      _isCorrect = choice == _correctAnswer;
      if (_isCorrect) {
        if (_attempts == 0) {
          _sessionScore += 1.0;
        } else if (_attempts == 1) {
          _sessionScore += 0.5;
        }
        _feedbackMessage = 'Correct!';
      } else {
        _feedbackMessage = _attempts == 1 ? 'Try one more time!' : 'Wrong! Try again.';
      }
    });

    if (_isCorrect) {
      await Future.delayed(const Duration(seconds: 2));
      _updateProgress(_currentQuestion + 1); // Update progress for each correct answer
      if (_currentQuestion < _lessons.length - 1) {
        setState(() {
          _currentQuestion++;
          _showFeedback = false;
          _attempts = 0;
        });
        _prepareQuestion();
      } else {
        // Quiz is complete - show completion dialog, then add score and exit
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Quiz Complete!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _sessionScore >= _lessons.length * 0.7 ? Icons.stars : Icons.star,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 50,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Final Score: ${_sessionScore.toStringAsFixed(1)}/${_lessons.length}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _sessionScore >= _lessons.length * 0.7
                        ? 'Great job!'
                        : 'Keep practicing!',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.pushReplacementNamed(context, '/');
                    // Refresh home data after navigation
                    Future.delayed(const Duration(milliseconds: 100), () {
                      Home.refreshHomeData();
                    });
                  },
                  child: const Text('Return to Home'),
                ),
              ],
            ),
          );
          // After dialog, add score to total and exit to homepage
          await _addToTotalScore(_sessionScore);
          Navigator.pushReplacementNamed(context, '/');
        }
      }
    } else {
      setState(() {
        _attempts++;
        if (_attempts > 1) {
          _feedbackMessage = 'Keep trying until you get it right!';
        }
      });
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _showFeedback = false;
      });
    }
  }

  Future<void> _addToTotalScore(double sessionScore) async {
    final prefs = await SharedPreferences.getInstance();
    double total = prefs.getDouble('totalScore') ?? 0.0;
    total += sessionScore;
    await prefs.setDouble('totalScore', total);
  }

  Future<void> _updateProgress(int questionsCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('facequiz_progress', questionsCompleted);
  }

  void _toggleLanguage() {
    setState(() => _isSpanish = !_isSpanish);
  }

  void _speakQuestion(String text) async {
    await _flutterTts.setLanguage(_isSpanish ? 'es-ES' : 'en-US');
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final lesson = _lessons[_questionOrder[_currentQuestion]];
    final questionText = _isSpanish
        ? '¿Para qué sirven los ${lesson['title_en']?.toLowerCase()}?'
        : 'What does the ${lesson['title_en']?.toLowerCase()} do?';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSpanish ? 'Juego Facial' : 'Face Quiz'),
        // No hardcoded colors, will use the theme
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: _toggleLanguage,
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => _speakQuestion(questionText),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Score display
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Theme.of(context).colorScheme.tertiary),
                  const SizedBox(width: 10),
                  Text(
                    'Score: ${_sessionScore.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Animated image
            GestureDetector(
              onTap: () {
                // Add extra animation or interaction when tapped
                _bounceController.forward(from: 0);
              },
              child: AnimatedBuilder(
                animation: _bounceAnim,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_bounceAnim.value),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          lesson['image']!,
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Question text
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Text(
                questionText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Answer options or feedback
            if (!_showFeedback)
              ..._options.map((opt) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: () => _checkAnswer(opt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    minimumSize: const Size(double.infinity, 65),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: primaryColor.withOpacity(0.5), width: 2),
                    ),
                    elevation: 5,
                    shadowColor: Theme.of(context).shadowColor.withOpacity(0.3),
                  ),
                  child: Text(
                    opt,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
            if (_showFeedback)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isCorrect ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(
                    color: _isCorrect ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error,
                    width: 2.0,
                  ),
                ),
                child: Text(
                  _feedbackMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isCorrect ? Theme.of(context).colorScheme.onSecondaryContainer : Theme.of(context).colorScheme.onErrorContainer,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
