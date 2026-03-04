import 'dart:convert';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Evaluation result model
class EvaluationResult {
  final int accuracy;      // 1-5: Is the biology information correct?
  final int clarity;       // 1-5: Is it easy for a child to understand?
  final int ageAppropriate; // 1-5: Is the language suitable for ages 5-12?
  final int engagement;    // 1-5: Is it interesting and encouraging?
  final double overall;    // Average of all scores
  final String feedback;   // Brief improvement suggestion
  final String question;   // Original question
  final String response;   // Tutor's response
  final DateTime timestamp;

  EvaluationResult({
    required this.accuracy,
    required this.clarity,
    required this.ageAppropriate,
    required this.engagement,
    required this.overall,
    required this.feedback,
    required this.question,
    required this.response,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'accuracy': accuracy,
    'clarity': clarity,
    'ageAppropriate': ageAppropriate,
    'engagement': engagement,
    'overall': overall,
    'feedback': feedback,
    'question': question,
    'response': response,
    'timestamp': timestamp.toIso8601String(),
  };

  factory EvaluationResult.fromJson(Map<String, dynamic> json) {
    return EvaluationResult(
      accuracy: json['accuracy'] ?? 3,
      clarity: json['clarity'] ?? 3,
      ageAppropriate: json['ageAppropriate'] ?? 3,
      engagement: json['engagement'] ?? 3,
      overall: (json['overall'] ?? 3.0).toDouble(),
      feedback: json['feedback'] ?? '',
      question: json['question'] ?? '',
      response: json['response'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

/// AI Evaluator Service - Evaluates the AI Tutor's responses
class AiEvaluatorService {
  static final AiEvaluatorService _instance = AiEvaluatorService._internal();
  factory AiEvaluatorService() => _instance;
  AiEvaluatorService._internal();

  final Gemini _gemini = Gemini.instance;
  List<EvaluationResult> _evaluationHistory = [];

  /// System prompt for the AI Evaluator
  static const String evaluatorSystemPrompt = '''
You are a quality evaluator for an AI biology tutor designed for children ages 5-12.

Your task is to evaluate the tutor's response to a student's biology question.

Evaluate on these criteria (score 1-5, where 5 is best):

1. ACCURACY (1-5): Is the biology/science information factually correct?
   - 5: Completely accurate
   - 3: Mostly accurate with minor issues
   - 1: Contains significant errors

2. CLARITY (1-5): Is the explanation easy for a child to understand?
   - 5: Crystal clear, uses simple words
   - 3: Understandable but could be simpler
   - 1: Too complex for children

3. AGE_APPROPRIATE (1-5): Is the content and language suitable for ages 5-12?
   - 5: Perfect for young children
   - 3: Acceptable but could be more kid-friendly
   - 1: Not appropriate for children

4. ENGAGEMENT (1-5): Is the response interesting and encouraging?
   - 5: Fun, encouraging, makes learning exciting
   - 3: Neutral, just answers the question
   - 1: Boring or discouraging

You MUST respond ONLY with valid JSON in this exact format (no markdown, no extra text):
{"accuracy":4,"clarity":5,"ageAppropriate":5,"engagement":4,"overall":4.5,"feedback":"One sentence suggestion for improvement"}
''';

  /// Evaluate a tutor response
  Future<EvaluationResult?> evaluateResponse(String question, String tutorResponse) async {
    try {
      final prompt = '''
$evaluatorSystemPrompt

STUDENT QUESTION: "$question"

TUTOR RESPONSE: "$tutorResponse"

Evaluate the tutor's response now. Respond ONLY with JSON:
''';

      print('📊 Evaluator: Sending evaluation request to Gemini...');
      final response = await _gemini.text(prompt);
      final output = response?.output?.trim() ?? '';
      print('📊 Evaluator: Raw response: $output');
      
      // Try to parse the JSON response
      try {
        // Clean up potential markdown formatting
        String jsonStr = output;
        if (jsonStr.contains('```')) {
          jsonStr = jsonStr.replaceAll(RegExp(r'```json?\n?'), '').replaceAll('```', '');
        }
        jsonStr = jsonStr.trim();
        
        final Map<String, dynamic> parsed = jsonDecode(jsonStr);
        
        final result = EvaluationResult(
          accuracy: (parsed['accuracy'] ?? 3).toInt().clamp(1, 5),
          clarity: (parsed['clarity'] ?? 3).toInt().clamp(1, 5),
          ageAppropriate: (parsed['ageAppropriate'] ?? parsed['age_appropriate'] ?? 3).toInt().clamp(1, 5),
          engagement: (parsed['engagement'] ?? 3).toInt().clamp(1, 5),
          overall: (parsed['overall'] ?? 3.0).toDouble().clamp(1.0, 5.0),
          feedback: parsed['feedback']?.toString() ?? 'No feedback provided',
          question: question,
          response: tutorResponse,
          timestamp: DateTime.now(),
        );

        // Add to history
        _evaluationHistory.add(result);
        await _saveEvaluations();

        return result;
      } catch (parseError) {
        print('⚠️ Evaluator: Parse error: $parseError');
        // If parsing fails, create a default evaluation
        final result = EvaluationResult(
          accuracy: 3,
          clarity: 3,
          ageAppropriate: 3,
          engagement: 3,
          overall: 3.0,
          feedback: 'Evaluation could not be parsed',
          question: question,
          response: tutorResponse,
          timestamp: DateTime.now(),
        );
        _evaluationHistory.add(result);
        await _saveEvaluations();
        return result;
      }
    } catch (e, stackTrace) {
      print('❌ Evaluator Error: $e');
      print('📍 Stack trace: $stackTrace');
      return null;
    }
  }

  /// Get all evaluation history
  List<EvaluationResult> getEvaluationHistory() {
    return List.from(_evaluationHistory);
  }

  /// Get average scores across all evaluations
  Map<String, double> getAverageScores() {
    if (_evaluationHistory.isEmpty) {
      return {
        'accuracy': 0,
        'clarity': 0,
        'ageAppropriate': 0,
        'engagement': 0,
        'overall': 0,
      };
    }

    double sumAccuracy = 0, sumClarity = 0, sumAge = 0, sumEngagement = 0, sumOverall = 0;
    
    for (var eval in _evaluationHistory) {
      sumAccuracy += eval.accuracy;
      sumClarity += eval.clarity;
      sumAge += eval.ageAppropriate;
      sumEngagement += eval.engagement;
      sumOverall += eval.overall;
    }

    final count = _evaluationHistory.length;
    return {
      'accuracy': sumAccuracy / count,
      'clarity': sumClarity / count,
      'ageAppropriate': sumAge / count,
      'engagement': sumEngagement / count,
      'overall': sumOverall / count,
    };
  }

  /// Get total evaluation count
  int getEvaluationCount() => _evaluationHistory.length;

  /// Clear evaluation history
  Future<void> clearHistory() async {
    _evaluationHistory.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('evaluator_history');
  }

  /// Save evaluations to SharedPreferences
  Future<void> _saveEvaluations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _evaluationHistory.map((e) => e.toJson()).toList();
    await prefs.setString('evaluator_history', jsonEncode(jsonList));
  }

  /// Load evaluations from SharedPreferences
  Future<void> loadEvaluations() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('evaluator_history');
    if (saved != null) {
      final List<dynamic> jsonList = jsonDecode(saved);
      _evaluationHistory = jsonList.map((e) => EvaluationResult.fromJson(e)).toList();
    }
  }
}
