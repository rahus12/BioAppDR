import 'package:flutter/material.dart';

class DragDrop extends StatefulWidget {
  const DragDrop({Key? key}) : super(key: key);

  @override
  State<DragDrop> createState() => _DragDropQuizState();
}

class _DragDropQuizState extends State<DragDrop> {
  // Index to track the current quiz question.
  int currentQuestionIndex = 0;
  // Flags for displaying messages.
  bool isMatched = false;
  bool isWrong = false;

  // List of quiz questions for all 4 images.
  // Each question contains:
  // - 'prompt': Instruction text (with the Spanish target word)
  // - 'correctAnswer': The expected answer (e.g., "El corazón")
  // - 'options': A list of options (each a map with "data" and "image")
  final List<Map<String, dynamic>> quizQuestions = [
    {
      'prompt': 'Drag the correct image for "El corazón" onto the target:\n\nEl corazón',
      'correctAnswer': 'El corazón',
      'options': [
        {"data": "El corazón", "image": "assets/heart.jpeg"},
        {"data": "La nariz", "image": "assets/nose.jpeg"},
        {"data": "El cerebro", "image": "assets/brain.jpg"},
        {"data": "La boca", "image": "assets/mouth.png"},
      ],
    },
    {
      'prompt': 'Drag the correct image for "La nariz" onto the target:\n\nLa nariz',
      'correctAnswer': 'La nariz',
      'options': [
        {"data": "El corazón", "image": "assets/heart.jpeg"},
        {"data": "La nariz", "image": "assets/nose.jpeg"},
        {"data": "El cerebro", "image": "assets/brain.jpg"},
        {"data": "La boca", "image": "assets/mouth.png"},
      ],
    },
    {
      'prompt': 'Drag the correct image for "El cerebro" onto the target:\n\nEl cerebro',
      'correctAnswer': 'El cerebro',
      'options': [
        {"data": "El corazón", "image": "assets/heart.jpeg"},
        {"data": "La nariz", "image": "assets/nose.jpeg"},
        {"data": "El cerebro", "image": "assets/brain.jpg"},
        {"data": "La boca", "image": "assets/mouth.png"},
      ],
    },
    {
      'prompt': 'Drag the correct image for "La boca" onto the target:\n\nLa boca',
      'correctAnswer': 'La boca',
      'options': [
        {"data": "El corazón", "image": "assets/heart.jpeg"},
        {"data": "La nariz", "image": "assets/nose.jpeg"},
        {"data": "El cerebro", "image": "assets/brain.jpg"},
        {"data": "La boca", "image": "assets/mouth.png"},
      ],
    },
  ];

  // Moves to the next quiz question (or resets at the end).
  void goToNextQuestion() {
    setState(() {
      isMatched = false;
      isWrong = false;
      if (currentQuestionIndex < quizQuestions.length - 1) {
        currentQuestionIndex++;
      } else {
        currentQuestionIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get current quiz question.
    Map<String, dynamic> currentQuiz = quizQuestions[currentQuestionIndex];
    String prompt = currentQuiz['prompt'];
    String correctAnswer = currentQuiz['correctAnswer'];
    List<Map<String, String>> options =
    List<Map<String, String>>.from(currentQuiz['options']);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Drag & Drop Quiz"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Column(
              children: [
                // Display quiz instructions.
                Text(
                  prompt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 40),
                // Display draggable image options.
                Wrap(
                  spacing: 20.0,
                  runSpacing: 20.0,
                  children: options.map((option) {
                    return Draggable<String>(
                      data: option["data"],
                      feedback: Material(
                        color: Colors.transparent,
                        child: Image.asset(
                          option["image"]!,
                          width: 160,
                          height: 160,
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: Image.asset(
                          option["image"]!,
                          width: 160,
                          height: 160,
                        ),
                      ),
                      child: Image.asset(
                        option["image"]!,
                        width: 160,
                        height: 160,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                // DragTarget that expects the correct answer.
                DragTarget<String>(
                  onAccept: (data) {
                    setState(() {
                      if (data == correctAnswer) {
                        isMatched = true;
                        isWrong = false;
                        // After a 1-second delay, load the next question.
                        Future.delayed(const Duration(seconds: 1), () {
                          goToNextQuestion();
                        });
                      } else {
                        isMatched = false;
                        isWrong = true;
                      }
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 140,
                      height: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blueAccent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: isMatched
                            ? Colors.green.withOpacity(0.2)
                            : Colors.white,
                      ),
                      child: Text(
                        isMatched ? "Matched: $correctAnswer" : correctAnswer,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: isMatched ? Colors.green[800] : Colors.black,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                // Wrong answer message.
                if (isWrong)
                  const Text(
                    "Wrong answer! Please try again.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                // Success message.
                if (isMatched)
                  Text(
                    "¡Excelente!\nYou matched the image with \"$correctAnswer\".",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.green),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
