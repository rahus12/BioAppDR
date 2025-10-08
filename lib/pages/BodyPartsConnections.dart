import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bioappdr/pages/Home.dart';

class BodyPartsConnections extends StatefulWidget {
  const BodyPartsConnections({Key? key}) : super(key: key);

  @override
  _BodyPartsConnectionsState createState() => _BodyPartsConnectionsState();
}

class _BodyPartsConnectionsState extends State<BodyPartsConnections> with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpanish = false;
  int _score = 0;
  int _level = 1;
  bool _showFeedback = false;
  bool _isCorrect = false;
  String _feedbackMessage = '';
  bool _gameOver = false;

  // Animation controllers
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  // Selected items
  int? _selectedLeftIndex;
  int? _selectedRightIndex;

  // Track completed pairs
  List<bool> _leftCompleted = [];
  List<bool> _rightCompleted = [];

  // Game data
  List _levels = [];
  late List<Map<String, dynamic>> _currentLevel;
  late List<int> _leftOrder;
  late List<int> _rightOrder;

  @override
  void initState() {
    super.initState();
    _setupLevels();
    _initAnimations();
    _setupCurrentLevel();
  }

  void _setupLevels() {
    _levels = [
      // Level 1 - Matching body parts with their functions
      [
        {'left_en': 'Eyes', 'left_es': 'Ojos', 'right_en': 'Allow vision', 'right_es': 'Permiten ver'},
        {'left_en': 'Ears', 'left_es': 'Oídos', 'right_en': 'Enable hearing', 'right_es': 'Permiten oír'},
        {'left_en': 'Nose', 'left_es': 'Nariz', 'right_en': 'Helps smell', 'right_es': 'Ayuda a oler'},
        {'left_en': 'Heart', 'left_es': 'Corazón', 'right_en': 'Pumps blood', 'right_es': 'Bombea sangre'},
      ],
      // Level 2 - Matching body systems
      [
        {'left_en': 'Brain', 'left_es': 'Cerebro', 'right_en': 'Nervous system', 'right_es': 'Sistema nervioso'},
        {'left_en': 'Lungs', 'left_es': 'Pulmones', 'right_en': 'Respiratory system', 'right_es': 'Sistema respiratorio'},
        {'left_en': 'Stomach', 'left_es': 'Estómago', 'right_en': 'Digestive system', 'right_es': 'Sistema digestivo'},
        {'left_en': 'Heart', 'left_es': 'Corazón', 'right_en': 'Circulatory system', 'right_es': 'Sistema circulatorio'},
        {'left_en': 'Kidneys', 'left_es': 'Riñones', 'right_en': 'Excretory system', 'right_es': 'Sistema excretor'},
      ],
      // Level 3 - Matching body parts with locations
      [
        {'left_en': 'Brain', 'left_es': 'Cerebro', 'right_en': 'In the skull', 'right_es': 'En el cráneo'},
        {'left_en': 'Liver', 'left_es': 'Hígado', 'right_en': 'Upper right abdomen', 'right_es': 'Abdomen superior derecho'},
        {'left_en': 'Kidneys', 'left_es': 'Riñones', 'right_en': 'Lower back', 'right_es': 'Espalda baja'},
        {'left_en': 'Lungs', 'left_es': 'Pulmones', 'right_en': 'Chest cavity', 'right_es': 'Cavidad torácica'},
        {'left_en': 'Heart', 'left_es': 'Corazón', 'right_en': 'Center of chest', 'right_es': 'Centro del pecho'},
        {'left_en': 'Stomach', 'left_es': 'Estómago', 'right_en': 'Upper abdomen', 'right_es': 'Abdomen superior'},
      ],
    ];
  }

  void _initAnimations() {
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceAnim = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticIn),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  void _setupCurrentLevel() {
    setState(() {
      _gameOver = false;
      _showFeedback = false;
      _selectedLeftIndex = null;
      _selectedRightIndex = null;

      // Get current level data (clamped to available levels)
      int levelIndex = min(_level - 1, _levels.length - 1);
      _currentLevel = List.from(_levels[levelIndex] as Iterable);

      // Reset completed tracking
      _leftCompleted = List.generate(_currentLevel.length, (_) => false);
      _rightCompleted = List.generate(_currentLevel.length, (_) => false);

      // Randomize order of right-side items
      _leftOrder = List.generate(_currentLevel.length, (index) => index);
      _rightOrder = List.generate(_currentLevel.length, (index) => index);
      _rightOrder.shuffle();
    });
  }

  // Handle selection of a left item
  void _selectLeft(int index) {
    if (_leftCompleted[index]) return;

    setState(() {
      // If already selected, deselect
      if (_selectedLeftIndex == index) {
        _selectedLeftIndex = null;
      } else {
        _selectedLeftIndex = index;
        _bounceController.forward(from: 0);

        // Check if we have a pair selected
        if (_selectedRightIndex != null) {
          _checkMatch();
        }
      }
    });
  }

  // Handle selection of a right item
  void _selectRight(int index) {
    if (_rightCompleted[_rightOrder[index]]) return;

    setState(() {
      // If already selected, deselect
      if (_selectedRightIndex == index) {
        _selectedRightIndex = null;
      } else {
        _selectedRightIndex = index;
        _bounceController.forward(from: 0);

        // Check if we have a pair selected
        if (_selectedLeftIndex != null) {
          _checkMatch();
        }
      }
    });
  }

  // Check if selected pair matches
  void _checkMatch() {
    if (_selectedLeftIndex == null || _selectedRightIndex == null) return;

    final leftIndex = _selectedLeftIndex!;
    final rightValue = _rightOrder[_selectedRightIndex!];

    final isMatch = leftIndex == rightValue;

    setState(() {
      _showFeedback = true;
      _isCorrect = isMatch;

      if (isMatch) {
        // Correct match
        _score += 10;
        _leftCompleted[leftIndex] = true;
        _rightCompleted[rightValue] = true;
        _feedbackMessage = _isSpanish ? '¡Correcto!' : 'Correct!';

        // Check if level completed
        if (_leftCompleted.every((complete) => complete)) {
          _updateProgress(_level); // Update progress for each completed level
          if (_level >= _levels.length) {
            // Game completed
            _gameOver = true;
            _feedbackMessage = _isSpanish ? '¡Juego completado!' : 'Game completed!';
            // Add score to total
            _addToTotalScore(_score.toDouble());
          } else {
            _feedbackMessage = _isSpanish ? '¡Nivel completado!' : 'Level completed!';
            Future.delayed(const Duration(seconds: 2), () {
              setState(() {
                _level++;
                _setupCurrentLevel();
              });
            });
          }
        } else {
          // Continue with next pair
          Future.delayed(const Duration(milliseconds: 800), () {
            setState(() {
              _showFeedback = false;
              _selectedLeftIndex = null;
              _selectedRightIndex = null;
            });
          });
        }
      } else {
        // Incorrect match
        _feedbackMessage = _isSpanish ? 'Incorrecto, intenta de nuevo' : 'Incorrect, try again';
        _shakeController.forward(from: 0);

        // Reset selection after delay
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            _showFeedback = false;
            _selectedLeftIndex = null;
            _selectedRightIndex = null;
          });
        });
      }
    });
  }

  void _toggleLanguage() {
    setState(() => _isSpanish = !_isSpanish);
  }

  void _speakText(String text) async {
    await _flutterTts.setLanguage(_isSpanish ? 'es-ES' : 'en-US');
    await _flutterTts.speak(text);
  }

  Future<void> _addToTotalScore(double sessionScore) async {
    final prefs = await SharedPreferences.getInstance();
    double total = prefs.getDouble('totalScore') ?? 0.0;
    total += sessionScore;
    await prefs.setDouble('totalScore', total);
  }

  Future<void> _updateProgress(int levelsCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('connections_progress', levelsCompleted);
  }

  void _restartGame() {
    setState(() {
      _score = 0;
      _level = 1;
      _gameOver = false;
      _setupCurrentLevel();
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shakeController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSpanish ? 'Conexiones del Cuerpo' : 'Body Parts Connections'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: _toggleLanguage,
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            // Score and level indicator
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.purple.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Score display
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        '${_isSpanish ? 'Puntuación' : 'Score'}: $_score',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  // Level indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_isSpanish ? 'Nivel' : 'Level'} $_level',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Game over message
            if (_gameOver)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSpanish ? '¡Felicidades!' : 'Congratulations!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isSpanish
                            ? '¡Has completado todos los niveles!'
                            : 'You have completed all levels!',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_isSpanish ? 'Puntuación final' : 'Final score'}: $_score',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _restartGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                            child: Text(
                              _isSpanish ? 'Jugar de nuevo' : 'Play Again',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/');
                              // Refresh home data after navigation
                              Future.delayed(const Duration(milliseconds: 100), () {
                                Home.refreshHomeData();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                            child: Text(
                              _isSpanish ? 'Volver al inicio' : 'Return to Home',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    // Instructions
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _isSpanish
                            ? 'Conecta cada parte del cuerpo con su pareja correcta'
                            : 'Connect each body part with its correct match',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Feedback message
                    if (_showFeedback)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isCorrect
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isCorrect ? Colors.green : Colors.red,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isCorrect ? Icons.check_circle : Icons.cancel,
                              color: _isCorrect ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _feedbackMessage,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _isCorrect ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Game board
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Left column
                            Expanded(
                              child: Column(
                                children: List.generate(
                                  _currentLevel.length,
                                      (index) => _buildCardItem(
                                    index,
                                    true,
                                    _leftOrder[index],
                                    _leftCompleted[index],
                                    _selectedLeftIndex == index,
                                  ),
                                ),
                              ),
                            ),

                            // Connection lines
                            const SizedBox(width: 20),

                            // Right column
                            Expanded(
                              child: Column(
                                children: List.generate(
                                  _currentLevel.length,
                                      (index) => _buildCardItem(
                                    index,
                                    false,
                                    _rightOrder[index],
                                    _rightCompleted[_rightOrder[index]],
                                    _selectedRightIndex == index,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(int index, bool isLeft, int valueIndex, bool completed, bool selected) {
    // Get correct data based on language and side
    final String text = _isSpanish
        ? (isLeft
        ? _currentLevel[valueIndex]['left_es']
        : _currentLevel[valueIndex]['right_es'])
        : (isLeft
        ? _currentLevel[valueIndex]['left_en']
        : _currentLevel[valueIndex]['right_en']);

    // Determine colors and styles
    final Color baseColor = isLeft ? Colors.blue : Colors.green;
    final Color bgColor = completed
        ? Colors.grey.withOpacity(0.3)
        : selected
        ? baseColor.withOpacity(0.3)
        : baseColor.withOpacity(0.1);
    final Color borderColor = completed
        ? Colors.grey
        : selected
        ? baseColor
        : baseColor.withOpacity(0.5);

    Widget card = Expanded(
      child: GestureDetector(
        onTap: () {
          if (!completed) {
            if (isLeft) {
              _selectLeft(index);
            } else {
              _selectRight(index);
            }
          }

          // Speak the text when tapped
          _speakText(text);
        },
        child: AnimatedBuilder(
          animation: selected ? _bounceAnim : const AlwaysStoppedAnimation(0),
          builder: (context, child) {
            double offset = 0;
            if (selected) {
              offset = sin(_bounceController.value * 3 * 3.14159) * 5;
            } else if (!completed && _shakeController.isAnimating && ((isLeft && _selectedLeftIndex == index) || (!isLeft && _selectedRightIndex == index))) {
              offset = sin(_shakeController.value * 10 * 3.14159) * 8;
            }

            return Transform.translate(
              offset: Offset(isLeft ? offset : -offset, 0),
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                if (selected)
                  BoxShadow(
                    color: baseColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: completed ? Colors.grey : Colors.black87,
                  decoration: completed ? TextDecoration.lineThrough : null,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    return card;
  }
}