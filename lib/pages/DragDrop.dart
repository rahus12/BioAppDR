import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bioappdr/pages/Home.dart';

class DragDrop extends StatefulWidget {
  const DragDrop({super.key});

  @override
  State<DragDrop> createState() => _DragDropQuizState();
}

class _DragDropQuizState extends State<DragDrop> {
  int _currentQuestionIndex = 0;
  bool _isCorrectMatch = false;
  bool _isWrongMatch = false;
  int _score = 0;
  bool _showSpanish = false;


  final FlutterTts _textToSpeech = FlutterTts();

  @override
  void initState() {
    super.initState();
    _setupTextToSpeech();
  }

  void _setupTextToSpeech() async {
    await _textToSpeech.setLanguage(_showSpanish ? "es-ES" : "en-US");
    await _textToSpeech.setSpeechRate(0.5);
    await _textToSpeech.setVolume(1.0);
  }

  void _pronounceWord(String text) async {
    await _textToSpeech.speak(text);
  }

  final List<Map<String, dynamic>> _quizData = [
    {
      'englishPrompt': 'Drag the correct image for "heart" onto the target:',
      'spanishPrompt': 'Arrastra la imagen correcta para "El corazón" al objetivo:',
      'spanishWord': 'El corazón',
      'englishWord': 'heart',
      'options': [
        {"data": "El corazón", "image": "assets/heart.jpeg"},
        {"data": "La nariz", "image": "assets/nose.jpeg"},
        {"data": "El cerebro", "image": "assets/brain.jpg"},
        {"data": "La boca", "image": "assets/mouth.png"},
      ],
    },
    {
      'englishPrompt': 'Drag the correct image for "nose" onto the target:',
      'spanishPrompt': 'Arrastra la imagen correcta para "La nariz" al objetivo:',
      'spanishWord': 'La nariz',
      'englishWord': 'nose',
      'options': [
        {"data": "El corazón", "image": "assets/heart.jpeg"},
        {"data": "La nariz", "image": "assets/nose.jpeg"},
        {"data": "El cerebro", "image": "assets/brain.jpg"},
        {"data": "La boca", "image": "assets/mouth.png"},
      ],
    },
    {
      'englishPrompt': 'Drag the correct image for "brain" onto the target:',
      'spanishPrompt': 'Arrastra la imagen correcta para "El cerebro" al objetivo:',
      'spanishWord': 'El cerebro',
      'englishWord': 'brain',
      'options': [
        {"data": "El corazón", "image": "assets/heart.jpeg"},
        {"data": "La nariz", "image": "assets/nose.jpeg"},
        {"data": "El cerebro", "image": "assets/brain.jpg"},
        {"data": "La boca", "image": "assets/mouth.png"},
      ],
    },
    {
      'englishPrompt': 'Drag the correct image for "mouth" onto the target:',
      'spanishPrompt': 'Arrastra la imagen correcta para "La boca" al objetivo:',
      'spanishWord': 'La boca',
      'englishWord': 'mouth',
      'options': [
        {"data": "El corazón", "image": "assets/heart.jpeg"},
        {"data": "La nariz", "image": "assets/nose.jpeg"},
        {"data": "El cerebro", "image": "assets/brain.jpg"},
        {"data": "La boca", "image": "assets/mouth.png"},
      ],
    },
  ];

  void _moveToNextQuestion() {
    setState(() {
      _isCorrectMatch = false;
      _isWrongMatch = false;
      if (_currentQuestionIndex < _quizData.length - 1) {
        _currentQuestionIndex++;
      } else {
        _showQuizCompletionDialog();
      }
    });
  }

  Future<void> _addToTotalScore(double sessionScore) async {
    final prefs = await SharedPreferences.getInstance();
    double total = prefs.getDouble('totalScore') ?? 0.0;
    total += sessionScore;
    await prefs.setDouble('totalScore', total);
  }

  Future<void> _updateProgress(int questionsCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dragdrop_progress', questionsCompleted);
  }

  void _showQuizCompletionDialog() {
    // Add score to total before showing dialog
    _addToTotalScore(_score.toDouble());
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            _showSpanish ? '¡Felicidades!' : 'Congratulations!',
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/trophy.png',
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 16),
              Text(
                _showSpanish
                    ? '¡Completaste el cuestionario con $_score de ${_quizData.length} respuestas correctas!'
                    : 'You completed the quiz with $_score out of ${_quizData.length} correct answers!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(_showSpanish ? 'Intentar de nuevo' : 'Try Again'),
              onPressed: () {
                setState(() {
                  _currentQuestionIndex = 0;
                  _score = 0;
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(_showSpanish ? 'Volver al inicio' : 'Return to Home'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/');
                // Refresh home data after navigation
                Future.delayed(const Duration(milliseconds: 100), () {
                  Home.refreshHomeData();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Map<String, dynamic> currentQuestion = _quizData[_currentQuestionIndex];
    String prompt =
    _showSpanish ? currentQuestion['spanishPrompt'] : currentQuestion['englishPrompt'];
    String correctSpanishWord = currentQuestion['spanishWord'];
    String correctEnglishWord = currentQuestion['englishWord'];
    List<Map<String, String>> options =
    List<Map<String, String>>.from(currentQuestion['options']);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showSpanish
              ? "Cuestionario de Arrastrar y Soltar"
              : "Drag & Drop Quiz",
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,

        elevation: 0,
        actions: [

          TextButton.icon(
            icon: Icon(Icons.translate, color: theme.colorScheme.onPrimary),
            label: Text(
              _showSpanish ? "English" : "Español",
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
            onPressed: () {
              setState(() {
                _showSpanish = !_showSpanish;
                _setupTextToSpeech(); // Update TTS language
              });
            },
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_currentQuestionIndex + 1}/${_quizData.length}',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _pronounceWord(
            _showSpanish
                ? currentQuestion['spanishWord']
                : currentQuestion['englishWord'],
          );
        },
        backgroundColor: theme.colorScheme.primary,
        tooltip: _showSpanish ? 'Pronunciar' : 'Pronounce',
        child: const Icon(Icons.volume_up),
      ),
      body: Container(

        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.3),
              theme.colorScheme.primary.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Question card
                    _buildQuestionCard(
                      prompt,
                      correctSpanishWord,
                      correctEnglishWord,
                      theme,
                    ),
                    const SizedBox(height: 24),

                    // Image options
                    _buildDraggableOptions(options),
                    const SizedBox(height: 32),

                    // Drop target
                    _buildDropTarget(correctSpanishWord, correctEnglishWord, theme),
                    const SizedBox(height: 24),

                    // Feedback messages
                    _buildFeedbackMessage(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
      String prompt,
      String spanishWord,
      String englishWord,
      ThemeData theme,
      ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4, // Subtle elevation in M3
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    prompt,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () {
                    _pronounceWord(_showSpanish ? spanishWord : englishWord);
                  },
                  tooltip: _showSpanish ? 'Escuchar' : 'Listen',
                ),
              ],
            ),
            // Show translation under prompt
            if (!_showSpanish)
              Text(
                'Spanish: "$spanishWord"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Text(
                'English: "$englishWord"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableOptions(List<Map<String, String>> options) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      alignment: WrapAlignment.center,
      children: options.map((option) {
        return Draggable<String>(
          data: option["data"],
          feedback: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                option["image"]!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  option["image"]!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                option["image"]!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropTarget(
      String spanishWord,
      String englishWord,
      ThemeData theme,
      ) {
    return DragTarget<String>(
      onAccept: (data) {
        setState(() {
          if (data == spanishWord) {
            _isCorrectMatch = true;
            _isWrongMatch = false;
            _score++;
            _updateProgress(_score); // Update progress for each correct answer

            // Success sound could be added here

            Future.delayed(const Duration(seconds: 2), () {
              _moveToNextQuestion();
            });
          } else {
            _isCorrectMatch = false;
            _isWrongMatch = true;

            // Error sound could be added here
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        // Compute border and background color based on correctness
        Color borderColor = _isCorrectMatch
            ? Colors.green
            : _isWrongMatch
            ? Colors.red
            : theme.colorScheme.onSurface;
        Color fillColor = _isCorrectMatch
            ? Colors.green.withOpacity(0.2)
            : _isWrongMatch
            ? Colors.red.withOpacity(0.2)
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.8);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 200,
          height: 120,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 3),
            borderRadius: BorderRadius.circular(16),
            color: fillColor,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _showSpanish ? spanishWord : englishWord,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: borderColor,
                ),
              ),
              if (!_showSpanish)
                Text(
                  "($spanishWord)",
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                Text(
                  "($englishWord)",
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (candidateData.isEmpty && !_isCorrectMatch && !_isWrongMatch)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _showSpanish ? "Suelta aquí" : "Drop here",
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedbackMessage(ThemeData theme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isWrongMatch
          ? Card(
        color: theme.colorScheme.errorContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.error),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.close, color: theme.colorScheme.onErrorContainer),
              const SizedBox(width: 8),
              Text(
                _showSpanish ? "¡Inténtalo de nuevo!" : "Try again!",
                style: TextStyle(
                  fontSize: 18,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ),
      )
          : _isCorrectMatch
          ? Card(
        color: theme.colorScheme.tertiaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.tertiary),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                _showSpanish ? "¡Excelente!" : "Excellent!",
                style: TextStyle(
                  fontSize: 18,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
        ),
      )
          : const SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    _textToSpeech.stop();
    super.dispose();
  }
}
