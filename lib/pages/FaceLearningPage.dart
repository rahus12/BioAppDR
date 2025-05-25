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
      home: const Facelearningpage(),
    );
  }
}

class Facelearningpage extends StatefulWidget {
  const Facelearningpage({Key? key}) : super(key: key);

  @override
  State<Facelearningpage> createState() => _Facelearningpage();
}

class _Facelearningpage extends State<Facelearningpage> {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';
  Map<String, String>? _selectedLesson;
  Timer? _listeningTimer;
  bool _isSpanish = false;

  final List<Map<String, String>> _lessons = [
    // — face parts entries —
    {
      'image': 'assets/teeth.jpeg',
      'title_en': 'Teeth',
      'title_es': 'Dientes',
      'function_en':
      'Chews and breaks down food into smaller pieces.',
      'function_es':
      'Mastica y descompone los alimentos en trozos más pequeños.',
      'location_en': 'Inside the mouth, attached to the jawbones.',
      'location_es': 'Dentro de la boca, adheridos a los huesos de la mandíbula.',
      'importance_en':
      'Essential for digestion and proper nutrition.',
      'importance_es':
      'Esenciales para la digestión y la nutrición adecuada.'
    },
    {
      'image': 'assets/tongue.jpeg',
      'title_en': 'Tongue',
      'title_es': 'Lengua',
      'function_en':
      'Helps taste food, manipulate it for chewing, and enables speech.',
      'function_es':
      'Ayuda a saborear los alimentos, manipularlos para masticar y permite el habla.',
      'location_en': 'Inside the mouth, resting on the floor of the oral cavity.',
      'location_es': 'Dentro de la boca, apoyada en el suelo de la cavidad oral.',
      'importance_en':
      'Vital for taste perception, swallowing, and clear speech.',
      'importance_es':
      'Vital para la percepción del gusto, la deglución y el habla clara.'
    },
    {
      'image': 'assets/mouth.png',
      'title_en': 'Mouth',
      'title_es': 'Boca',
      'function_en':
      'Ingests food and liquids, starts digestion, and forms speech sounds.',
      'function_es':
      'Ingiere alimentos y líquidos, inicia la digestión y forma sonidos del habla.',
      'location_en': 'Lower part of the face, below the nose.',
      'location_es': 'Parte inferior de la cara, debajo de la nariz.',
      'importance_en':
      'First step in both digestion and verbal communication.',
      'importance_es':
      'Primer paso en la digestión y la comunicación verbal.'
    },
    {
      'image': 'assets/eyes.jpeg',
      'title_en': 'Eyes',
      'title_es': 'Ojos',
      'function_en':
      'Detects light and sends visual information to the brain.',
      'function_es':
      'Detecta la luz y envía información visual al cerebro.',
      'location_en': 'In the eye sockets (orbits) of the skull.',
      'location_es': 'En las cuencas de los ojos (órbitas) del cráneo.',
      'importance_en':
      'Primary organs for vision and spatial awareness.',
      'importance_es':
      'Órganos principales para la visión y la conciencia espacial.'
    },
    {
      'image': 'assets/ears.jpeg',
      'title_en': 'Ears',
      'title_es': 'Oídos',
      'function_en':
      'Hears sound and helps maintain balance.',
      'function_es':
      'Percibe sonidos y ayuda a mantener el equilibrio.',
      'location_en': 'On both sides of the head, just above the jawline.',
      'location_es': 'A ambos lados de la cabeza, justo encima de la línea de la mandíbula.',
      'importance_en':
      'Crucial for hearing, communication, and balance control.',
      'importance_es':
      'Cruciales para la audición, la comunicación y el control del equilibrio.'
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
