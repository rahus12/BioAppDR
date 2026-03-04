import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:bioappdr/services/ai_tutor_service.dart';
import 'package:bioappdr/services/ai_evaluator_service.dart';

/// AI Tutor Chat Page - Kid-friendly chat interface with Bio Buddy
/// Uses the AiTutorService to interact with Gemini AI
class AiTutorChatPage extends StatefulWidget {
  const AiTutorChatPage({super.key});

  @override
  State<AiTutorChatPage> createState() => _AiTutorChatPageState();
}

class _AiTutorChatPageState extends State<AiTutorChatPage>
    with TickerProviderStateMixin {
  final AiTutorService _tutorService = AiTutorService();
  final AiEvaluatorService _evaluatorService = AiEvaluatorService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _flutterTts = FlutterTts();

  // Speech-to-Text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  bool _isSpanish = false;
  bool _isLoading = false;
  bool _isSpeaking = false;
  List<Map<String, String>> _messages = [];

  // Suggested questions for kids
  final List<Map<String, String>> _suggestedQuestionsEn = [
    {'emoji': '❤️', 'question': 'What does my heart do?'},
    {'emoji': '🧠', 'question': 'Why do I need a brain?'},
    {'emoji': '🦴', 'question': 'How many bones do I have?'},
    {'emoji': '🫁', 'question': 'How do lungs work?'},
    {'emoji': '👀', 'question': 'Why do I blink?'},
    {'emoji': '🍎', 'question': 'Why is fruit healthy?'},
  ];

  final List<Map<String, String>> _suggestedQuestionsEs = [
    {'emoji': '❤️', 'question': '¿Qué hace mi corazón?'},
    {'emoji': '🧠', 'question': '¿Por qué necesito un cerebro?'},
    {'emoji': '🦴', 'question': '¿Cuántos huesos tengo?'},
    {'emoji': '🫁', 'question': '¿Cómo funcionan los pulmones?'},
    {'emoji': '👀', 'question': '¿Por qué parpadeo?'},
    {'emoji': '🍎', 'question': '¿Por qué la fruta es saludable?'},
  ];

  late AnimationController _botAnimController;
  late Animation<double> _botBounceAnimation;

  @override
  void initState() {
    super.initState();
    _loadConversation();
    _loadEvaluatorHistory();
    _initTts();
    _initSpeech();
    _initAnimations();
  }

  void _initAnimations() {
    _botAnimController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _botBounceAnimation = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _botAnimController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.1);
    _updateTtsLanguage();

    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
  }

  Future<void> _updateTtsLanguage() async {
    await _flutterTts.setLanguage(_isSpanish ? 'es-ES' : 'en-US');
  }

  Future<void> _loadConversation() async {
    await _tutorService.loadConversation();
    setState(() {
      _messages = _tutorService.getConversationHistory();
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _messageController.clear();
    setState(() {
      _isLoading = true;
      _messages.add({'role': 'user', 'content': message});
    });
    _scrollToBottom();

    try {
      final response = await _tutorService.askQuestion(
        message,
        isSpanish: _isSpanish,
      );

      setState(() {
        _messages = _tutorService.getConversationHistory();
        _isLoading = false;
      });
      _scrollToBottom();

      // Auto-speak the response for kids
      _speak(response);

      // Evaluate the response in the background (for quality monitoring)
      _evaluateResponse(message, response);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add({
          'role': 'assistant',
          'content': _isSpanish
              ? '¡Ups! Algo salió mal. Intenta de nuevo. 🤔'
              : 'Oops! Something went wrong. Try again! 🤔',
        });
      });
    }
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await _flutterTts.speak(text);
    }
  }

  /// Evaluate the tutor's response in the background
  Future<void> _evaluateResponse(String question, String response) async {
    print('📊 Evaluating tutor response...');
    try {
      final result = await _evaluatorService.evaluateResponse(question, response);
      if (result != null) {
        print('✅ Evaluation complete: Overall ${result.overall}/5');
        print('   Accuracy: ${result.accuracy}, Clarity: ${result.clarity}');
        print('   Age-appropriate: ${result.ageAppropriate}, Engagement: ${result.engagement}');
        print('   Feedback: ${result.feedback}');
      } else {
        print('⚠️ Evaluation failed');
      }
    } catch (e) {
      print('⚠️ Evaluation error: $e');
    }
  }

  void _toggleLanguage() {
    setState(() => _isSpanish = !_isSpanish);
    _updateTtsLanguage();
  }

  Future<void> _clearChat() async {
    await _tutorService.clearHistory();
    setState(() => _messages.clear());
  }

  /// Load evaluator history
  Future<void> _loadEvaluatorHistory() async {
    await _evaluatorService.loadEvaluations();
  }

  /// Initialize Speech-to-Text
  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        print('Speech error: $error');
        setState(() => _isListening = false);
      },
    );
    setState(() {});
  }

  /// Start or stop listening
  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      if (_speechAvailable) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (result) {
            if (result.finalResult && result.recognizedWords.isNotEmpty) {
              _messageController.text = result.recognizedWords;
              // Auto-send after speech recognition completes
              _sendMessage(result.recognizedWords);
            } else if (!result.finalResult) {
              // Show interim results in the text field
              _messageController.text = result.recognizedWords;
            }
          },
          localeId: _isSpanish ? 'es_ES' : 'en_US',
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        );
      } else {
        // Show error if speech not available
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSpanish 
                ? 'Micrófono no disponible' 
                : 'Microphone not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _flutterTts.stop();
    _speech.stop();
    _botAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final suggestedQuestions =
        _isSpanish ? _suggestedQuestionsEs : _suggestedQuestionsEn;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.orange.shade600],
            ),
          ),
        ),
        title: Row(
          children: [
            const Text('🤖', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Text(
              _isSpanish ? 'Amigo Bio' : 'Bio Buddy',
              style: const TextStyle(
                fontFamily: 'LuckiestGuy',
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          // Language toggle
          IconButton(
            icon: Text(_isSpanish ? '🇪🇸' : '🇺🇸', style: const TextStyle(fontSize: 20)),
            tooltip: _isSpanish ? 'Cambiar a inglés' : 'Switch to Spanish',
            onPressed: _toggleLanguage,
          ),
          // Clear chat
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: _isSpanish ? 'Limpiar chat' : 'Clear chat',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(_isSpanish ? '¿Limpiar chat?' : 'Clear chat?'),
                  content: Text(_isSpanish
                      ? '¿Estás seguro de que quieres borrar todos los mensajes?'
                      : 'Are you sure you want to delete all messages?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(_isSpanish ? 'Cancelar' : 'Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _clearChat();
                        Navigator.pop(ctx);
                      },
                      child: Text(_isSpanish ? 'Borrar' : 'Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(suggestedQuestions)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isLoading && index == _messages.length) {
                        return _buildTypingIndicator();
                      }
                      final msg = _messages[index];
                      final isUser = msg['role'] == 'user';
                      return _buildMessageBubble(
                        msg['content'] ?? '',
                        isUser,
                        cs,
                      );
                    },
                  ),
          ),

          // Suggested questions (show when few messages)
          if (_messages.length < 4)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: suggestedQuestions.length,
                itemBuilder: (context, index) {
                  final q = suggestedQuestions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      avatar: Text(q['emoji']!, style: const TextStyle(fontSize: 16)),
                      label: Text(
                        q['question']!,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => _sendMessage(q['question']!),
                      backgroundColor: cs.primaryContainer,
                    ),
                  );
                },
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Text input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: cs.outline.withOpacity(0.3)),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: _isSpanish
                              ? '¡Pregúntame sobre el cuerpo! 🌟'
                              : 'Ask me about the body! 🌟',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Microphone button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isListening 
                            ? [Colors.red.shade400, Colors.red.shade600]
                            : [Colors.purple.shade400, Colors.purple.shade600],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: _isListening ? [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ] : null,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                      ),
                      onPressed: _toggleListening,
                      tooltip: _isSpanish ? 'Hablar' : 'Speak',
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.orange.shade600],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: () => _sendMessage(_messageController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(List<Map<String, String>> suggestedQuestions) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated bot
            AnimatedBuilder(
              animation: _botBounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_botBounceAnimation.value),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade100, Colors.orange.shade200],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Text('🤖', style: TextStyle(fontSize: 72)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isSpanish ? '¡Hola! Soy Amigo Bio' : 'Hi! I\'m Bio Buddy',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'LuckiestGuy',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isSpanish
                  ? '¡Pregúntame sobre el cuerpo humano!'
                  : 'Ask me anything about the human body!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              _isSpanish ? 'Prueba preguntar:' : 'Try asking:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggestedQuestions.map((q) {
                return ActionChip(
                  avatar: Text(q['emoji']!, style: const TextStyle(fontSize: 18)),
                  label: Text(q['question']!),
                  onPressed: () => _sendMessage(q['question']!),
                  backgroundColor: Colors.orange.shade50,
                  side: BorderSide(color: Colors.orange.shade200),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isUser, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: const Text('🤖', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onTap: isUser ? null : () => _speak(message),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser ? cs.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                    if (!isUser) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.volume_up,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isSpanish ? 'Toca para escuchar' : 'Tap to hear',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Text('👧', style: TextStyle(fontSize: 20)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: const Text('🤖', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.orange.shade400.withOpacity(0.5 + (value * 0.5)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
