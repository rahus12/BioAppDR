import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

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

  // AI State Variables
  final Gemini _gemini = Gemini.instance;
  final TextEditingController _chatController = TextEditingController();
  String _aiResponse = '';
  bool _isLoading = false;

  // Animation controllers
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  // Selected items (stores the position in the list)
  int? _selectedLeftIndex;
  int? _selectedRightIndex;

  // Track completed pairs by their original index
  List<bool> _leftCompleted = [];
  List<bool> _rightCompleted = [];

  // Game data
  final List<List<Map<String, dynamic>>> _levels = [];
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

  // Define all game levels and their data
  void _setupLevels() {
    _levels.addAll([
      [
        {'left_en': 'Eyes', 'left_es': 'Ojos', 'right_en': 'Allow vision', 'right_es': 'Permiten ver', 'image': 'assets/eyes.jpeg'},
        {'left_en': 'Ears', 'left_es': 'Oídos', 'right_en': 'Enable hearing', 'right_es': 'Permiten oír', 'image': 'assets/ears.jpeg'},
        {'left_en': 'Nose', 'left_es': 'Nariz', 'right_en': 'Helps smell', 'right_es': 'Ayuda a oler', 'image': 'assets/nose.jpeg'},
        {'left_en': 'Heart', 'left_es': 'Corazón', 'right_en': 'Pumps blood', 'right_es': 'Bombea sangre', 'image': 'assets/Heart.png'},
      ],
      [
        {'left_en': 'Brain', 'left_es': 'Cerebro', 'right_en': 'Nervous system', 'right_es': 'Sistema nervioso', 'image': 'assets/Brain.png'},
        {'left_en': 'Lungs', 'left_es': 'Pulmones', 'right_en': 'Respiratory system', 'right_es': 'Sistema respiratorio', 'image': 'assets/Lungs.png'},
        {'left_en': 'Stomach', 'left_es': 'Estómago', 'right_en': 'Digestive system', 'right_es': 'Sistema digestivo', 'image': 'assets/Stomach.png'},
        {'left_en': 'Heart', 'left_es': 'Corazón', 'right_en': 'Circulatory system', 'right_es': 'Sistema circulatorio', 'image': 'assets/Heart.png'},
        {'left_en': 'Kidneys', 'left_es': 'Riñones', 'right_en': 'Excretory system', 'right_es': 'Sistema excretor', 'image': 'assets/kidney.png'},
      ],
      [
        {'left_en': 'Brain', 'left_es': 'Cerebro', 'right_en': 'In the skull', 'right_es': 'En el cráneo', 'image': 'assets/Brain.png'},
        {'left_en': 'Liver', 'left_es': 'Hígado', 'right_en': 'Upper right abdomen', 'right_es': 'Abdomen superior derecho', 'image': 'assets/liver.jpeg'},
        {'left_en': 'Kidneys', 'left_es': 'Riñones', 'right_en': 'Lower back', 'right_es': 'Espalda baja', 'image': 'assets/Kidney.png'},
        {'left_en': 'Lungs', 'left_es': 'Pulmones', 'right_en': 'Chest cavity', 'right_es': 'Cavidad torácica', 'image': 'assets/Lungs.png'},
        {'left_en': 'Heart', 'left_es': 'Corazón', 'right_en': 'Center of chest', 'right_es': 'Centro del pecho', 'image': 'assets/Heart.png'},
        {'left_en': 'Stomach', 'left_es': 'Estómago', 'right_en': 'Upper abdomen', 'right_es': 'Abdomen superior', 'image': 'assets/Stomach.png'},
      ],
    ]);
  }

  void _initAnimations() {
    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut));

    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  void _setupCurrentLevel() {
    setState(() {
      _gameOver = false;
      _showFeedback = false;
      _selectedLeftIndex = null;
      _selectedRightIndex = null;

      int levelIndex = min(_level - 1, _levels.length - 1);
      _currentLevel = List.from(_levels[levelIndex]);

      _leftCompleted = List.generate(_currentLevel.length, (_) => false);
      _rightCompleted = List.generate(_currentLevel.length, (_) => false);

      _leftOrder = List.generate(_currentLevel.length, (index) => index)..shuffle();
      _rightOrder = List.generate(_currentLevel.length, (index) => index)..shuffle();
    });
  }

  // --- Game Logic Methods ---
  void _selectLeft(int position) {
    if (_leftCompleted[_leftOrder[position]]) return;

    setState(() {
      if (_selectedLeftIndex == position) {
        _selectedLeftIndex = null;
      } else {
        _selectedLeftIndex = position;
        _bounceController.forward(from: 0).then((_) => _bounceController.reverse());
        if (_selectedRightIndex != null) {
          _checkMatch();
        }
      }
    });
  }

  void _selectRight(int position) {
    if (_rightCompleted[_rightOrder[position]]) return;

    setState(() {
      if (_selectedRightIndex == position) {
        _selectedRightIndex = null;
      } else {
        _selectedRightIndex = position;
        _bounceController.forward(from: 0).then((_) => _bounceController.reverse());
        if (_selectedLeftIndex != null) {
          _checkMatch();
        }
      }
    });
  }

  void _checkMatch() {
    if (_selectedLeftIndex == null || _selectedRightIndex == null) return;

    final leftOriginalIndex = _leftOrder[_selectedLeftIndex!];
    final rightOriginalIndex = _rightOrder[_selectedRightIndex!];
    final isMatch = leftOriginalIndex == rightOriginalIndex;

    setState(() {
      _showFeedback = true;
      _isCorrect = isMatch;

      if (isMatch) {
        _score += 10;
        _leftCompleted[leftOriginalIndex] = true;
        _rightCompleted[rightOriginalIndex] = true;
        _feedbackMessage = _isSpanish ? '¡Correcto!' : 'Correct!';

        if (_leftCompleted.every((c) => c)) {
          if (_level >= _levels.length) {
            _gameOver = true;
            _feedbackMessage = _isSpanish ? '¡Juego completado!' : 'Game completed!';
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
          Future.delayed(const Duration(milliseconds: 800), () {
            setState(() {
              _showFeedback = false;
              _selectedLeftIndex = null;
              _selectedRightIndex = null;
            });
          });
        }
      } else {
        _feedbackMessage = _isSpanish ? 'Incorrecto, intenta de nuevo' : 'Incorrect, try again';
        _shakeController.forward(from: 0);
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

  void _toggleLanguage() => setState(() => _isSpanish = !_isSpanish);

  void _speakText(String text) async {
    await _flutterTts.setLanguage(_isSpanish ? 'es-ES' : 'en-US');
    await _flutterTts.speak(text);
  }

  void _restartGame() {
    setState(() {
      _score = 0;
      _level = 1;
      _gameOver = false;
      _setupCurrentLevel();
    });
  }

  // --- AI Assistant Methods (Corrected) ---
  void _getAiResponse(String userQuery, StateSetter setSheetState) {
    setSheetState(() {
      _isLoading = true;
      _aiResponse = '';
    });

    String context = "You are a helpful assistant for a kids' anatomy game. "
        "The user is currently on Level $_level with a score of $_score. "
        "Keep your answers short, encouraging, and suitable for a child.";

    _gemini.text("$context\n\nThe user asks: $userQuery").then((response) {
      if (mounted) {
        setSheetState(() {
          _aiResponse = response?.output ?? "Sorry, I couldn't think of anything.";
          _isLoading = false;
        });
      }
    }).catchError((e) {
      if (mounted) {
        setSheetState(() {
          _aiResponse = "An error occurred. Please try again.";
          _isLoading = false;
        });
      }
    });
  }

  void _showAiAssistant() {
    _chatController.clear();
    _aiResponse = '';
    _isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('AI Assistant', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Container(
                    height: 120,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(child: Text(_aiResponse)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          decoration: const InputDecoration(
                            hintText: 'Ask for a hint or a fun fact!',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              _getAiResponse(value, setSheetState);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (_chatController.text.isNotEmpty) {
                            _getAiResponse(_chatController.text, setSheetState);
                          }
                        },
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shakeController.dispose();
    _chatController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSpanish ? 'Conexiones del Cuerpo' : 'Body Parts Connections'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.translate), onPressed: _toggleLanguage)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAiAssistant,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.assistant),
        tooltip: 'AI Assistant',
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEDE7F6), Color(0xFFE1F5FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.deepPurple.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        '${_isSpanish ? 'Puntuación' : 'Score'}: $_score',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(16)),
                    child: Text(
                      '${_isSpanish ? 'Nivel' : 'Level'} $_level',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            if (_gameOver)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 20),
                      Text(
                        _isSpanish ? '¡Felicidades!' : 'Congratulations!',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isSpanish ? '¡Has completado todos los niveles!' : 'You have completed all levels!',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_isSpanish ? 'Puntuación final' : 'Final score'}: $_score',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: Text(_isSpanish ? 'Jugar de nuevo' : 'Play Again', style: const TextStyle(fontSize: 18)),
                        onPressed: _restartGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _isSpanish ? 'Conecta la imagen con su pareja correcta' : 'Connect the image with its correct match',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (_showFeedback)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isCorrect ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _isCorrect ? Colors.green : Colors.red, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isCorrect ? Icons.check_circle : Icons.cancel, color: _isCorrect ? Colors.green : Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              _feedbackMessage,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _isCorrect ? Colors.green : Colors.red),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                  _currentLevel.length,
                                      (index) => _buildCardItem(
                                    position: index,
                                    isLeft: true,
                                    originalIndex: _leftOrder[index],
                                    isCompleted: _leftCompleted[_leftOrder[index]],
                                    isSelected: _selectedLeftIndex == index,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                  _currentLevel.length,
                                      (index) => _buildCardItem(
                                    position: index,
                                    isLeft: false,
                                    originalIndex: _rightOrder[index],
                                    isCompleted: _rightCompleted[_rightOrder[index]],
                                    isSelected: _selectedRightIndex == index,
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

  Widget _buildCardItem({required int position, required bool isLeft, required int originalIndex, required bool isCompleted, required bool isSelected}) {
    final data = _currentLevel[originalIndex];
    final text = _isSpanish ? (isLeft ? data['left_es'] : data['right_es']) : (isLeft ? data['left_en'] : data['right_en']);
    final imagePath = isLeft ? data['image'] : null;

    final Color baseColor = isLeft ? Colors.blue : Colors.green;
    final Color bgColor = isCompleted ? Colors.grey.shade300 : isSelected ? baseColor.withOpacity(0.3) : Colors.white;
    final Color borderColor = isCompleted ? Colors.grey.shade400 : isSelected ? baseColor : baseColor.withOpacity(0.5);

    Widget cardContent;
    if (isLeft && imagePath != null) {
      cardContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(imagePath, fit: BoxFit.contain, color: isCompleted ? Colors.grey.shade600 : null),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isCompleted ? Colors.grey.shade600 : Colors.black87,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      cardContent = Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isCompleted ? Colors.grey.shade600 : Colors.black87,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
      );
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isCompleted) {
            isLeft ? _selectLeft(position) : _selectRight(position);
          }
          _speakText(text);
        },
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            double offset = 0;
            if (_shakeController.isAnimating && !isCompleted && isSelected) {
              offset = sin(_shakeController.value * 10 * pi) * 8;
            }
            return Transform.translate(offset: Offset(offset, 0), child: child);
          },
          child: ScaleTransition(
            scale: isSelected ? _bounceAnim : const AlwaysStoppedAnimation(1.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 2.5),
                boxShadow: [
                  if (isSelected) BoxShadow(color: baseColor.withOpacity(0.4), blurRadius: 8, spreadRadius: 2),
                ],
              ),
              child: cardContent,
            ),
          ),
        ),
      ),
    );
  }
}