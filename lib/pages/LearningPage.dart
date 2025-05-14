// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bilingual Body Parts',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Nunito',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const LearningPage(),
    );
  }
}

class LearningPage extends StatefulWidget {
  const LearningPage({Key? key}) : super(key: key);

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';
  Map<String, String>? _selectedLesson;
  Timer? _listeningTimer;
  bool _isSpanish = false;

  final List<Map<String, String>> _lessons = [
    {
      'image': 'assets/Body.png',
      'title_en': 'Human Body',
      'title_es': 'Cuerpo Humano',
      'description_en':
      'The human body is a complex structure composed of multiple organ systems working together to maintain life and health. Each system, like the skeletal, muscular, and nervous systems, plays a vital role in bodily functions.',
      'description_es':
      'El cuerpo humano es una estructura compleja compuesta por múltiples sistemas de órganos que trabajan juntos para mantener la vida y la salud. Cada sistema, como el esquelético, muscular y nervioso, desempeña un papel vital en las funciones corporales.'
    },
    {
      'image': 'assets/heart.png',
      'title_en': 'Heart',
      'title_es': 'Corazón',
      'function_en':
      'Pumps blood, delivering oxygen and nutrients to the body while removing waste products.',
      'function_es':
      'Bombea sangre, entregando oxígeno y nutrientes al cuerpo mientras elimina desechos.',
      'location_en': 'Center of the chest.',
      'location_es': 'Centro del pecho.',
      'importance_en':
      'Essential for circulation; without it, life cannot be sustained',
      'importance_es':
      'Esencial para la circulación; sin él, la vida no puede sostenerse'
    },
    {
      'image': 'assets/Lungs.png',
      'title_en': 'Lungs',
      'title_es': 'Pulmones',
      'function_en':
      'Facilitate the exchange of oxygen and carbon dioxide between the air and blood.',
      'function_es':
      'Facilitan el intercambio de oxígeno y dióxido de carbono entre el aire y la sangre.',
      'location_en': 'On either side of the chest.',
      'location_es': 'A cada lado del pecho.',
      'importance_en': 'Vital for breathing and oxygen supply to tissues',
      'importance_es':
      'Vitales para la respiración y el suministro de oxígeno a los tejidos'
    },
    {
      'image': 'assets/Brain.png',
      'title_en': 'Brain',
      'title_es': 'Cerebro',
      'function_en':
      'Controls all bodily functions, thoughts, emotions, and memory.',
      'function_es':
      'Controla todas las funciones corporales, pensamientos, emociones y memoria.',
      'location_en': 'Inside the skull',
      'location_es': 'Dentro del cráneo.',
      'importance_en':
      'Acts as the control center of the body; damage can severely impair or end life',
      'importance_es':
      'Actúa como el centro de control del cuerpo; su daño puede perjudicar gravemente o terminar la vida'
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeSpeechRecognizer();
    _initializeTts();
  }

  void _initializeTts() async {
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    if (!kIsWeb) {
      try {
        var langs = await _flutterTts.getLanguages;
        if (langs is List) debugPrint('TTS langs: $langs');
      } catch (e) {
        debugPrint('TTS lang error: $e');
      }
    }
  }

  void _initializeSpeechRecognizer() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        bool listening = _speech.isListening;
        if (mounted) setState(() => _isListening = listening);
        if (listening) {
          _listeningTimer?.cancel();
          _listeningTimer = Timer(const Duration(seconds: 5), () {
            _speech.stop();
            if (mounted) setState(() => _isListening = false);
          });
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() => _isListening = false);
          _showErrorDialog('Speech error: ${e.errorMsg}');
        }
      },
    );
    if (!available && mounted) {
      _showErrorDialog('Speech recognizer unavailable.');
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.setLanguage(_isSpanish ? 'es-ES' : 'en-US');
    if (text.isNotEmpty) {
      try {
        await _flutterTts.speak(text);
      } catch (e) {
        if (mounted) _showErrorDialog('TTS error: $e');
      }
    }
  }

  void _onLessonTapped(Map<String, String> lesson) {
    setState(() {
      _selectedLesson = lesson;
      _recognizedText = '';
    });
    _speak(_isSpanish ? lesson['title_es']! : lesson['title_en']!);
  }

  void _startListening() {
    if (!_speech.isAvailable) {
      _showErrorDialog('Enable speech permissions.');
      return;
    }
    if (_isListening) {
      _speech.stop();
      if (mounted) setState(() => _isListening = false);
      _listeningTimer?.cancel();
      return;
    }
    _speech.listen(
      onResult: (res) {
        setState(() => _recognizedText = res.recognizedWords);
        if (res.finalResult) {
          _speech.stop();
          _checkAnswer();
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
    );
    if (mounted) setState(() => _isListening = true);
  }

  void _checkAnswer() {
    bool correct = _recognizedText.trim().toLowerCase() ==
        _selectedLesson?['title_en']?.toLowerCase().trim();
    _showFeedbackDialog(correct);
  }

  void _toggleLanguage() {
    setState(() {
      _isSpanish = !_isSpanish;
      if (_selectedLesson != null) {
        _speak(_isSpanish ? _selectedLesson!['title_es']! : _selectedLesson!['title_en']!);
      }
    });
  }

  void _showFeedbackDialog(bool isCorrect) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          isCorrect ? 'Great Job! 🎉' : 'Try Again! 💪',
          style: TextStyle(color: isCorrect ? Colors.green : Colors.red),
        ),
        content: Text(isCorrect
            ? 'You said “${_selectedLesson!['title_en']}” correctly!'
            : 'You said “$_recognizedText”. The correct answer is “${_selectedLesson!['title_en']}”.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 300.ms)
          .scale(delay: 100.ms, duration: 200.ms),
    );
  }

  void _showErrorDialog(String msg) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _selectedLesson != null
        ? (_isSpanish ? _selectedLesson!['title_es']! : _selectedLesson!['title_en']!)
        : (_isSpanish ? 'Explorador del Cuerpo 🚀' : 'Body Explorer Adventure! 🚀');
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(_isSpanish ? Icons.translate : Icons.g_translate),
            onPressed: _toggleLanguage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.face_retouching_natural, size: 40, color: Colors.amber[800]),
                const SizedBox(width: 10),
                Text(
                  _isSpanish ? '¡Hola!' : 'Hi!',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ).animate().slideY(begin: -0.5, duration: 600.ms).fadeIn(),
            const SizedBox(height: 10),
            _buildCharacterArea(),
            _buildInfoPanel(),
            _buildVoiceInputSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterArea() {
    final img = _selectedLesson?['image'] ?? _lessons.first['image']!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5, offset: const Offset(0,3))],
      ),
      child: Column(
        children: [
          Text(
            _isSpanish ? '¡Toca una Parte del Cuerpo!' : 'Tap a Body Part!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple[700]),
          ),
          const SizedBox(height: 15),
          Image.asset(
            img,
            height: MediaQuery.of(context).size.height * 0.2,
            fit: BoxFit.contain,
            errorBuilder: (ctx, e, st) => Center(child: Text('Image not found', style: TextStyle(color: Colors.grey[600]))),
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _lessons.map((lesson) {
              final sel = _selectedLesson?['title_en'] == lesson['title_en'];
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: sel ? Colors.amber[700] : Colors.deepPurple[300],
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => _onLessonTapped(lesson),
                child: Text(_isSpanish ? lesson['title_es']! : lesson['title_en']!),
              )
                  .animate(target: sel ? 1 : 0)
                  .scale(duration: 200.ms, begin: const Offset(0.9,0.9), end: const Offset(1,1))
                  .shake(hz: sel ? 4 : 0, duration: 300.ms);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    if (_selectedLesson == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
        child: Text(
          _isSpanish
              ? '¡Selecciona una parte del cuerpo arriba para aprender más!'
              : 'Select a body part above to learn more!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.green[800], fontStyle: FontStyle.italic),
        ),
      ).animate().fadeIn(delay: 300.ms, duration: 500.ms);
    }
    final lesson = _selectedLesson!;
    final hasFunc = lesson.containsKey('function_en');
    final blocks = hasFunc
        ? [
      _colorBlock(Icons.functions_outlined, 'Function', lesson['function_en']!, Colors.blueAccent),
      _colorBlock(Icons.location_on_outlined, 'Location', lesson['location_en']!, Colors.green),
      _colorBlock(Icons.star_outline, 'Importance', lesson['importance_en']!, Colors.orange),
    ]
        : [
      _colorBlock(Icons.info_outline, 'Description', lesson['description_en']!, Colors.teal),
    ];
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _isSpanish ? lesson['title_es']! : lesson['title_en']!,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ).animate().slideX(begin: -0.2, duration: 300.ms).fadeIn(),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () {
                    String textToSpeak = _isSpanish ? lesson['title_es']! : lesson['title_en']!;
                    if (hasFunc) {
                      textToSpeak += '. ' + (_isSpanish ? lesson['function_es']! : lesson['function_en']!);
                      textToSpeak += '. ' + (_isSpanish ? lesson['location_es']! : lesson['location_en']!);
                      textToSpeak += '. ' + (_isSpanish ? lesson['importance_es']! : lesson['importance_en']!);
                    } else {
                      textToSpeak += '. ' + (_isSpanish ? lesson['description_es']! : lesson['description_en']!);
                    }
                    _speak(textToSpeak);
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 15),
            ...blocks.map((w) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: w)),
          ],
        ),
      ),
    ).animate().flipV(duration: 500.ms, begin: -0.1);
  }

  Widget _colorBlock(IconData icon, String label, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 4),
                Text(_isSpanish ? text : text, style: const TextStyle(fontSize: 15, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceInputSection() {
    String prompt;
    if (_isListening) {
      prompt = _isSpanish ? 'Escuchando...' : 'Listening...';
    } else if (_selectedLesson == null) {
      prompt = _isSpanish
          ? 'Selecciona una parte, luego toca el micrófono'
          : 'Select a part, then tap mic';
    } else {
      prompt = _isSpanish
          ? 'Toca el micrófono y di: "${_selectedLesson!['title_en']}"'
          : 'Tap mic & say: "${_selectedLesson!['title_en']}"';
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            prompt,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color: _isListening ? Colors.redAccent : Colors.blueGrey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _selectedLesson == null ? null : _startListening,
            child: CircleAvatar(
              radius: 35,
              backgroundColor: _selectedLesson == null
                  ? Colors.grey[400]
                  : (_isListening ? Colors.red[400] : Theme.of(context).primaryColor),
              child: Icon(
                _isListening ? Icons.mic_off : Icons.mic,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          if (_recognizedText.isNotEmpty && !_isListening)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                '${_isSpanish ? 'Dijiste' : 'You said'}: "$_recognizedText"',
                style: const TextStyle(fontSize: 16),
              ),
            ).animate().fadeIn(),
        ],
      ),
    );
  }
}
