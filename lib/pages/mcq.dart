import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Mcq extends StatefulWidget {
  const Mcq({Key? key}) : super(key: key);

  @override
  _McqState createState() => _McqState();
}

class _McqState extends State<Mcq> {
  int currentIndex = 0;

  // Track the user's selection
  String? _selectedOption;
  bool? _isCorrect;
  double _sessionScore = 0.0;
  int _attempts = 0;

  final List<Map<String, dynamic>> questions = [
    {
      "image": "assets/heart.jpeg",
      "question": "What does the heart do?",
      "options": ["Pumps blood", "Helps breathe", "Digests food", "Sees light"],
      "correctOption": "Pumps blood",
    },
    {
      "image": "assets/lungs.jpeg",
      "question": "Which organ helps us breathe?",
      "options": ["Heart", "Lungs", "Liver", "Stomach"],
      "correctOption": "Lungs",
    },
    {
      "image": "assets/bone.jpeg",
      "question": "What gives our body structure?",
      "options": ["Bones", "Skin", "Lungs", "Eyes"],
      "correctOption": "Bones",
    },
  ];

  /// Checks the answer, highlights if correct, shows popup if wrong
  void checkAnswer(String selectedOption) {
    final correct = questions[currentIndex]["correctOption"];
    if (_selectedOption != null && _isCorrect == true) return; // Prevent further scoring after correct

    if (selectedOption == correct) {
      setState(() {
        _selectedOption = selectedOption;
        _isCorrect = true;
      });
      if (_attempts == 0) {
        _sessionScore += 1.0;
      } else if (_attempts == 1) {
        _sessionScore += 0.5;
      }
      Future.delayed(const Duration(seconds: 1), () {
        if (currentIndex < questions.length - 1) {
          setState(() {
            currentIndex++;
            _selectedOption = null;
            _isCorrect = null;
            _attempts = 0;
          });
        } else {
          _addToTotalScore(_sessionScore); // Save to total score
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Quiz Complete!'),
              content: Text('You scored $_sessionScore out of ${questions.length} possible!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  child: const Text('Return to Home'),
                ),
              ],
            ),
          );
        }
      });
    } else {
      setState(() {
        _selectedOption = selectedOption;
        _isCorrect = false;
      });
      _attempts++;
      if (_attempts < 2) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Incorrect!"),
            content: Text("Score: $_sessionScore"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              )
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Incorrect!"),
            content: Text("No points for this question. Try until correct.\nScore: $_sessionScore"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    }
  }

  Future<void> _addToTotalScore(double sessionScore) async {
    final prefs = await SharedPreferences.getInstance();
    double total = prefs.getDouble('totalScore') ?? 0.0;
    total += sessionScore;
    await prefs.setDouble('totalScore', total);
  }

  @override
  Widget build(BuildContext context) {
    final questionData = questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text("Science MCQ"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE6E1F5),
                Color(0xFFF5F5F5),
              ],
            ),
          ),
        ),
      ),
      // Wrap body in a SingleChildScrollView
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Score display
            Text(
              'Score: $_sessionScore',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            Center(
              child: QuestionCard(
                imagePath: questionData["image"],
                question: questionData["question"],
                options: List<String>.from(questionData["options"]),
                onOptionSelected: checkAnswer,
                selectedOption: _selectedOption,
                isCorrect: _isCorrect,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class QuestionCard extends StatelessWidget {
  final String imagePath;
  final String question;
  final List<String> options;
  final Function(String) onOptionSelected;

  /// Tracks which button is currently selected, and whether it's correct.
  final String? selectedOption;
  final bool? isCorrect;

  const QuestionCard({
    required this.imagePath,
    required this.question,
    required this.options,
    required this.onOptionSelected,
    required this.selectedOption,
    required this.isCorrect,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          // Top image
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 100),
            child: Image.asset(imagePath, height: 250),
          ),
          // Card for the question and options
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white,
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 40, 10, 20),
                child: Column(
                  children: [
                    // Question text
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Option buttons
                    Column(
                      children: options.map((option) {
                        // Decide button color based on selection
                        Color buttonColor = Colors.white;
                        Color textColor = Colors.black;

                        if (selectedOption == option) {
                          // The user has selected this option
                          if (isCorrect == true) {
                            buttonColor = Colors.green;
                            textColor = Colors.white;
                          } else if (isCorrect == false) {
                            buttonColor = Colors.red;
                            textColor = Colors.white;
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 20,
                          ),
                          child: ElevatedButton(
                            onPressed: () => onOptionSelected(option),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(250, 50),
                              backgroundColor: buttonColor,
                              foregroundColor: textColor,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                  color: Color(0xFFC0BABA),
                                ),
                              ),
                            ),
                            child: Text(option),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
