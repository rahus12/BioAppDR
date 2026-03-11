import 'dart:convert';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AI Tutor Service - Biology teacher persona using Gemini
class AiTutorService {
  static final AiTutorService _instance = AiTutorService._internal();
  factory AiTutorService() => _instance;
  AiTutorService._internal();

  final Gemini _gemini = Gemini.instance;
  List<Map<String, String>> _conversationHistory = [];

  /// System prompt for the AI Tutor (English)
  static const String tutorSystemPromptEn = '''
You are Bio Buddy, a friendly and enthusiastic biology tutor for children aged 5-12.

Your role:
- Explain biology concepts in simple, fun, age-appropriate language
- Use analogies and examples kids can relate to (toys, animals, food, games)
- Keep responses SHORT (2-4 sentences max)
- Be encouraging and use emojis sparingly 🌱🦴❤️🧠
- Focus on topics: human body parts, organs, living/non-living things, nutrition, digestion, face parts
- If asked about something dangerous or inappropriate, gently redirect to biology topics

Teaching style:
- Start with "Great question!" or similar encouragement
- Use simple words a child would understand
- Give fun facts when relevant
- Ask follow-up questions to keep them engaged

Navigation: When your answer relates to a lesson or game we have, you MAY add at the very end ONE line: [NAV:/route]
Available routes: /lesson (body parts, organs), /facelesson (face, eyes), /nutrition (food, digestion), /living_non_living_lesson (living things), /question (quiz), /memorygame, /dragdrop, /wordscramble, /facequizgame, /bodypartsconnections, /bodyassembly
Only add [NAV:/route] when it naturally fits. Example: after explaining the heart, add [NAV:/lesson]

Remember: You are talking to a CHILD. Keep it simple, fun, and educational!
''';

  /// System prompt for the AI Tutor (Spanish)
  static const String tutorSystemPromptEs = '''
Eres Amigo Bio, un tutor de biología amigable y entusiasta para niños de 5 a 12 años.

Tu rol:
- Explica conceptos de biología en un lenguaje simple, divertido y apropiado para la edad
- Usa analogías y ejemplos que los niños puedan relacionar (juguetes, animales, comida, juegos)
- Mantén las respuestas CORTAS (2-4 oraciones máximo)
- Sé alentador y usa emojis con moderación 🌱🦴❤️🧠
- Enfócate en temas: partes del cuerpo humano, órganos, seres vivos/no vivos, nutrición, digestión, partes de la cara
- Si te preguntan algo peligroso o inapropiado, redirige suavemente a temas de biología

Estilo de enseñanza:
- Empieza con "¡Excelente pregunta!" o algo similar
- Usa palabras simples que un niño entendería
- Da datos curiosos cuando sea relevante
- Haz preguntas de seguimiento para mantenerlos interesados

Navegación: Cuando tu respuesta se relacione con una lección o juego que tenemos, puedes agregar al final UNA línea: [NAV:/ruta]
Rutas disponibles: /lesson (partes del cuerpo), /facelesson (cara), /nutrition (nutrición), /living_non_living_lesson (seres vivos), /question (cuestionario), /memorygame, /dragdrop, /wordscramble, /facequizgame, /bodypartsconnections, /bodyassembly
Solo agrega [NAV:/ruta] cuando encaje naturalmente.

Recuerda: ¡Estás hablando con un NIÑO! Mantenlo simple, divertido y educativo!
Responde SIEMPRE en español.
''';

  /// Ask a question to the AI Tutor
  Future<String> askQuestion(String question, {bool isSpanish = false}) async {
    try {
      // Build conversation context
      final systemPrompt = isSpanish ? tutorSystemPromptEs : tutorSystemPromptEn;
      
      // Add user question to history
      _conversationHistory.add({
        'role': 'user',
        'content': question,
      });

      // Build the full prompt with history context
      String fullPrompt = '$systemPrompt\n\n';
      
      // Add recent conversation history (last 6 messages to stay within context limits)
      final recentHistory = _conversationHistory.length > 6 
          ? _conversationHistory.sublist(_conversationHistory.length - 6)
          : _conversationHistory;
      
      for (var msg in recentHistory) {
        if (msg['role'] == 'user') {
          fullPrompt += 'Student: ${msg['content']}\n';
        } else {
          fullPrompt += 'Bio Buddy: ${msg['content']}\n';
        }
      }
      
      fullPrompt += '\nBio Buddy:';

      // Debug log
      print('🤖 AI Tutor: Sending prompt to Gemini...');
      
      // Call Gemini
      final response = await _gemini.text(fullPrompt);
      
      // Debug log
      print('🤖 AI Tutor: Response received: ${response?.output}');
      
      String tutorResponse = response?.output ?? 
          (isSpanish ? '¡Lo siento! No pude pensar en una respuesta. ¿Puedes preguntar de nuevo?' 
                     : "I'm sorry! I couldn't think of a response. Can you ask again?");
      
      // Clean up response
      tutorResponse = tutorResponse.trim();
      
      // Add tutor response to history
      _conversationHistory.add({
        'role': 'assistant',
        'content': tutorResponse,
      });

      // Save conversation
      await _saveConversation();

      return tutorResponse;
    } catch (e, stackTrace) {
      // Log the actual error
      print('❌ AI Tutor Error: $e');
      print('📍 Stack trace: $stackTrace');
      
      final errorMsg = isSpanish 
          ? '¡Ups! Algo salió mal. Intenta de nuevo. 🤔'
          : 'Oops! Something went wrong. Try again! 🤔';
      return errorMsg;
    }
  }

  /// Get the last tutor response (for evaluation)
  Map<String, String>? getLastExchange() {
    if (_conversationHistory.length >= 2) {
      final lastTwo = _conversationHistory.sublist(_conversationHistory.length - 2);
      if (lastTwo[0]['role'] == 'user' && lastTwo[1]['role'] == 'assistant') {
        return {
          'question': lastTwo[0]['content']!,
          'response': lastTwo[1]['content']!,
        };
      }
    }
    return null;
  }

  /// Get full conversation history
  List<Map<String, String>> getConversationHistory() {
    return List.from(_conversationHistory);
  }

  /// Clear conversation history
  Future<void> clearHistory() async {
    _conversationHistory.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tutor_conversation');
  }

  /// Save conversation to SharedPreferences
  Future<void> _saveConversation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tutor_conversation', jsonEncode(_conversationHistory));
  }

  /// Load conversation from SharedPreferences
  Future<void> loadConversation() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('tutor_conversation');
    if (saved != null) {
      _conversationHistory = List<Map<String, String>>.from(
        (jsonDecode(saved) as List).map((e) => Map<String, String>.from(e))
      );
    }
  }
}
