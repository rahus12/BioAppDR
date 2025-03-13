import 'package:flutter/material.dart';

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

  final List<Map<String, dynamic>> questions = [
    {
      "image": "assets/heart.jpg",
      "question": "What does the heart do?",
      "options": ["Pumps blood", "Helps breathe", "Digests food", "Sees light"],
      "correctOption": "Pumps blood",
    },
    {
      "image": "assets/lung.jpg",
      "question": "Which organ helps us breathe?",
      "options": ["Heart", "Lungs", "Liver", "Stomach"],
      "correctOption": "Lungs",
    },
    {
      "image": "assets/bone.jpg",
      "question": "What gives our body structure?",
      "options": ["Bones", "Skin", "Lungs", "Eyes"],
      "correctOption": "Bones",
    },
  ];

  /// Checks the answer, highlights if correct, shows popup if wrong
  void checkAnswer(String selectedOption) {
    final correct = questions[currentIndex]["correctOption"];
    if (selectedOption == correct) {
      // Correct answer
      setState(() {
        _selectedOption = selectedOption;
        _isCorrect = true;
      });
      // Wait 1 second, then go to next question
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          // Move to next question
          if (currentIndex < questions.length - 1) {
            currentIndex++;
          } else {
            currentIndex = 0; // or navigate to a results screen
          }
          // Reset
          _selectedOption = null;
          _isCorrect = null;
        });
      });
    } else {
      // Wrong answer
      setState(() {
        _selectedOption = selectedOption;
        _isCorrect = false;
      });
      // Show red popup
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Incorrect!"),
          content: const Text("Please try again."),
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

  @override
  Widget build(BuildContext context) {
    final questionData = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Science MCQ"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
      body: Center(
        child: QuestionCard(
          imagePath: questionData["image"],
          question: questionData["question"],
          options: List<String>.from(questionData["options"]),
          onOptionSelected: checkAnswer,
          selectedOption: _selectedOption,
          isCorrect: _isCorrect,
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

  /// These two fields tell us which button (if any) is currently selected,
  /// and whether it's correct or not.
  final String? selectedOption;
  final bool? isCorrect;

  const QuestionCard({
    required this.imagePath,
    required this.question,
    required this.options,
    required this.onOptionSelected,
    required this.selectedOption,
    required this.isCorrect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
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
                    // Render all options
                    Column(
                      children: options.map((option) {
                        // Decide button color based on selection
                        Color buttonColor = Colors.white; // default
                        Color textColor = Colors.black;

                        if (selectedOption == option) {
                          // The user has selected this option
                          if (isCorrect == true) {
                            // Correct => highlight green
                            buttonColor = Colors.green;
                            textColor = Colors.white;
                          } else if (isCorrect == false) {
                            // Wrong => highlight red
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
