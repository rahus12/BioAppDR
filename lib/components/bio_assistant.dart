import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:bioappdr/utils/navigator_key.dart';

class BioAssistant extends StatefulWidget {
  const BioAssistant({super.key});

  @override
  State<BioAssistant> createState() => _BioAssistantState();
}

class _BioAssistantState extends State<BioAssistant>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isSpanish = false; // Language toggle
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // Text-to-Speech
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  // Speech-to-Text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  // Translations map
  final Map<String, Map<String, String>> _translations = {
    'bio_buddy': {'en': 'Bio Buddy', 'es': 'Amigo Bio'},
    'where_to_go': {'en': 'Where do you want to go?', 'es': '¿A dónde quieres ir?'},
    'lessons': {'en': '📚 Lessons', 'es': '📚 Lecciones'},
    'games_quizzes': {'en': '🎮 Games & Quizzes', 'es': '🎮 Juegos y Cuestionarios'},
    'interactive': {'en': '🎤 Interactive Learning', 'es': '🎤 Aprendizaje Interactivo'},
    'living_non_living': {'en': 'Living & Non-Living', 'es': 'Vivo y No Vivo'},
    'living_desc': {'en': 'Learn about living things!', 'es': '¡Aprende sobre seres vivos!'},
    'human_body': {'en': 'Human Body Parts', 'es': 'Partes del Cuerpo Humano'},
    'body_desc': {'en': 'Explore body organs', 'es': 'Explora los órganos'},
    'face_parts': {'en': 'Face Parts', 'es': 'Partes de la Cara'},
    'face_desc': {'en': 'Learn about the face', 'es': 'Aprende sobre la cara'},
    'nutrition': {'en': 'Nutrition & Digestion', 'es': 'Nutrición y Digestión'},
    'nutrition_desc': {'en': 'How food gives us energy', 'es': 'Cómo la comida nos da energía'},
    'body_quiz': {'en': 'Body Quiz', 'es': 'Cuestionario del Cuerpo'},
    'quiz_desc': {'en': 'Test your knowledge!', 'es': '¡Pon a prueba tu conocimiento!'},
    'drag_drop': {'en': 'Drag & Drop', 'es': 'Arrastrar y Soltar'},
    'drag_desc': {'en': 'Match organs to functions', 'es': 'Relaciona órganos con funciones'},
    'word_scramble': {'en': 'Word Scramble', 'es': 'Revuelve Palabras'},
    'scramble_desc': {'en': 'Unscramble organ names', 'es': 'Descifra nombres de órganos'},
    'memory_game': {'en': 'Memory Game', 'es': 'Juego de Memoria'},
    'memory_desc': {'en': 'Match the pairs!', 'es': '¡Empareja las parejas!'},
    'face_quiz': {'en': 'Face Quiz', 'es': 'Cuestionario de la Cara'},
    'face_quiz_desc': {'en': 'Name the face parts', 'es': 'Nombra las partes de la cara'},
    'connections': {'en': 'Connections', 'es': 'Conexiones'},
    'connect_desc': {'en': 'Connect body parts', 'es': 'Conecta partes del cuerpo'},
    'body_assembly': {'en': 'Body Assembly', 'es': 'Ensamblar Cuerpo'},
    'assembly_desc': {'en': 'Build a body!', 'es': '¡Construye un cuerpo!'},
    'body_speech': {'en': 'Body Learning (Speech)', 'es': 'Cuerpo (Voz)'},
    'speech_desc': {'en': 'Learn with your voice', 'es': 'Aprende con tu voz'},
    'face_speech': {'en': 'Face Learning (Speech)', 'es': 'Cara (Voz)'},
    'face_speech_desc': {'en': 'Say face part names', 'es': 'Di nombres de la cara'},
    'ai_tutor': {'en': 'AI Voice Tutor', 'es': 'Tutor de Voz IA'},
    'tutor_desc': {'en': 'Your personal tutor', 'es': 'Tu tutor personal'},
    'tap_speak': {'en': 'Tap to speak', 'es': 'Toca para hablar'},
    'listening': {'en': 'Listening...', 'es': 'Escuchando...'},
    'welcome_msg': {
      'en': 'Hi! I\'m Bio Buddy. Where would you like to go?',
      'es': '¡Hola! Soy Amigo Bio. ¿A dónde te gustaría ir?'
    },
  };

  String _t(String key) {
    return _translations[key]?[_isSpanish ? 'es' : 'en'] ?? key;
  }

  // Navigation categories - now uses translations
  List<NavigationCategory> get _categories => [
    NavigationCategory(
      title: _t('lessons'),
      color: Colors.blue,
      items: [
        NavItem(
          icon: Icons.nature_people,
          label: _t('living_non_living'),
          route: "/living_non_living_lesson",
          description: _t('living_desc'),
        ),
        NavItem(
          icon: Icons.accessibility_new,
          label: _t('human_body'),
          route: "/lesson",
          description: _t('body_desc'),
        ),
        NavItem(
          icon: Icons.face,
          label: _t('face_parts'),
          route: "/facelesson",
          description: _t('face_desc'),
        ),
        NavItem(
          icon: Icons.restaurant,
          label: _t('nutrition'),
          route: "/nutrition",
          description: _t('nutrition_desc'),
        ),
      ],
    ),
    NavigationCategory(
      title: _t('games_quizzes'),
      color: Colors.green,
      items: [
        NavItem(
          icon: Icons.quiz,
          label: _t('body_quiz'),
          route: "/question",
          description: _t('quiz_desc'),
        ),
        NavItem(
          icon: Icons.drag_indicator,
          label: _t('drag_drop'),
          route: "/dragdrop",
          description: _t('drag_desc'),
        ),
        NavItem(
          icon: Icons.extension,
          label: _t('word_scramble'),
          route: "/wordscramble",
          description: _t('scramble_desc'),
        ),
        NavItem(
          icon: Icons.grid_view,
          label: _t('memory_game'),
          route: "/memorygame",
          description: _t('memory_desc'),
        ),
        NavItem(
          icon: Icons.face_retouching_natural,
          label: _t('face_quiz'),
          route: "/facequizgame",
          description: _t('face_quiz_desc'),
        ),
        NavItem(
          icon: Icons.link,
          label: _t('connections'),
          route: "/bodypartsconnections",
          description: _t('connect_desc'),
        ),
        NavItem(
          icon: Icons.build,
          label: _t('body_assembly'),
          route: "/bodyassembly",
          description: _t('assembly_desc'),
        ),
      ],
    ),
    NavigationCategory(
      title: _t('interactive'),
      color: Colors.purple,
      items: [
        NavItem(
          icon: Icons.record_voice_over,
          label: _t('body_speech'),
          route: "/learningpage",
          description: _t('speech_desc'),
        ),
        NavItem(
          icon: Icons.mic,
          label: _t('face_speech'),
          route: "/facelearningpage",
          description: _t('face_speech_desc'),
        ),
        NavItem(
          icon: Icons.smart_toy,
          label: _t('ai_tutor'),
          route: "/voice_tutor",
          description: _t('tutor_desc'),
        ),
        NavItem(
          icon: Icons.calendar_month,
          label: _isSpanish ? 'Planificador' : 'Planner',
          route: "/lesson_planner",
          description: _isSpanish ? 'Planifica tus lecciones' : 'Plan your lessons',
        ),
        NavItem(
          icon: Icons.analytics,
          label: _isSpanish ? 'Evaluador' : 'Evaluator',
          route: "/evaluator",
          description: _isSpanish ? 'Calidad del tutor' : 'Tutor quality',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _initTts();
    _initSpeech();
  }

  Future<void> _initTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    _updateTtsLanguage();

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  Future<void> _updateTtsLanguage() async {
    await _flutterTts.setLanguage(_isSpanish ? 'es-ES' : 'en-US');
  }

  Future<void> _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) {
        setState(() {
          _isListening = false;
        });
      },
    );
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
      });
    } else {
      setState(() {
        _isSpeaking = true;
      });
      await _flutterTts.speak(text);
    }
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _lastWords = '';
        });
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _lastWords = result.recognizedWords;
            });
            // Simple voice command detection
            _handleVoiceCommand(_lastWords.toLowerCase());
          },
          localeId: _isSpanish ? 'es_ES' : 'en_US',
        );
      }
    } else {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  void _handleVoiceCommand(String command) {
    // Map voice commands to navigation
    final Map<String, String> voiceRoutes = {
      'lesson': '/lesson',
      'lección': '/lesson',
      'body': '/lesson',
      'cuerpo': '/lesson',
      'face': '/facelesson',
      'cara': '/facelesson',
      'quiz': '/question',
      'cuestionario': '/question',
      'game': '/memorygame',
      'juego': '/memorygame',
      'memory': '/memorygame',
      'memoria': '/memorygame',
      'nutrition': '/nutrition',
      'nutrición': '/nutrition',
      'living': '/living_non_living_lesson',
      'vivo': '/living_non_living_lesson',
    };

    for (var entry in voiceRoutes.entries) {
      if (command.contains(entry.key)) {
        _speech.stop();
        setState(() {
          _isListening = false;
        });
        _navigateTo(context, entry.value);
        break;
      }
    }
  }

  void _toggleLanguage() {
    setState(() {
      _isSpanish = !_isSpanish;
    });
    _updateTtsLanguage();
    // Speak welcome message in new language
    _speak(_t('welcome_msg'));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _flutterTts.stop();
    _speech.stop();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _navigateTo(BuildContext context, String route) {
    // Use global navigator key for navigation from overlay
    navigatorKey.currentState?.pushNamed(route);
    setState(() {
      _isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Expanded navigation panel
        if (_isExpanded)
          Positioned(
            bottom: 90,
            right: 16,
            child: Material(
              elevation: 16,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.88,
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 560),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.orange.shade50,
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.orange.shade200,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade400,
                            Colors.orange.shade600,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(22),
                          topRight: Radius.circular(22),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              "🤖",
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _t('bio_buddy'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'LuckiestGuy',
                                  ),
                                ),
                                Text(
                                  _t('where_to_go'),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: _toggleExpanded,
                          ),
                        ],
                      ),
                    ),

                    // Control Bar: Language Toggle, TTS, Microphone
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Language Toggle
                          _buildControlButton(
                            icon: _isSpanish ? '🇪🇸' : '🇺🇸',
                            label: _isSpanish ? 'Español' : 'English',
                            onTap: _toggleLanguage,
                            isActive: false,
                          ),
                          
                          // Text-to-Speech
                          _buildControlButton(
                            icon: _isSpeaking ? '🔊' : '🔈',
                            label: _isSpeaking ? 'Stop' : 'Speak',
                            onTap: () => _speak(_t('welcome_msg')),
                            isActive: _isSpeaking,
                          ),
                          
                          // Microphone
                          _buildControlButton(
                            icon: '🎤',
                            label: _isListening ? _t('listening') : _t('tap_speak'),
                            onTap: _startListening,
                            isActive: _isListening,
                          ),
                        ],
                      ),
                    ),

                    // Voice feedback display
                    if (_lastWords.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.mic, size: 18, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '"$_lastWords"',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Navigation items
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _categories.map((category) {
                            return _buildCategory(context, category);
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Floating action button
        Positioned(
          bottom: 16,
          right: 16,
          child: ListenableBuilder(
            listenable: _bounceAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _isExpanded ? 0 : -_bounceAnimation.value),
                child: child,
              );
            },
            child: GestureDetector(
              onTap: _toggleExpanded,
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.orange.shade400,
                      Colors.orange.shade700,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulsing ring effect when not expanded
                    if (!_isExpanded)
                      ListenableBuilder(
                        listenable: _bounceController,
                        builder: (context, child) {
                          final size = 65.0 + (_bounceController.value * 15.0);
                          return Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.orange.withValues(
                                  alpha: 0.5 - (_bounceController.value * 0.5),
                                ),
                                width: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    // Bot face
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isExpanded
                          ? const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30,
                              key: Key('close'),
                            )
                          : const Text(
                              "🤖",
                              style: TextStyle(fontSize: 32),
                              key: Key('bot'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.orange.shade400 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.orange.shade300,
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.orange.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(BuildContext context, NavigationCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            category.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Sunshine',
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: category.items.map((item) {
            return _buildNavButton(context, item, category.color);
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildNavButton(BuildContext context, NavItem item, Color categoryColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateTo(context, item.route),
        onLongPress: () => _speak('${item.label}. ${item.description}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 170,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: categoryColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: categoryColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: categoryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

class NavigationCategory {
  final String title;
  final MaterialColor color;
  final List<NavItem> items;

  NavigationCategory({
    required this.title,
    required this.color,
    required this.items,
  });
}

class NavItem {
  final IconData icon;
  final String label;
  final String route;
  final String description;

  NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.description,
  });
}
