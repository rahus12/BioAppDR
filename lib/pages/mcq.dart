import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCQ App',
      debugShowCheckedModeBanner: false,
      home: const Mcq(),
    );
  }
}

class Mcq extends StatefulWidget {
  const Mcq({Key? key}) : super(key: key);

  @override
  _McqState createState() => _McqState();
}

class _McqState extends State<Mcq> {
  int currentIndex = 0;

  final List<Map<String, dynamic>> questions = [
    {
      "image": "assets/heart.jpg",
      "question": "What does the heart do?",
      "options": ["Pumps blood", "Helps breathe", "Digests food", "Sees light"],
    },
    {
      "image": "assets/lung.jpg",
      "question": "Which organ helps us breathe?",
      "options": ["Heart", "Lungs", "Liver", "Stomach"],
    },
    {
      "image": "assets/bone.jpg",
      "question": "What gives our body structure?",
      "options": ["Bones", "Skin", "Lungs", "Eyes"],
    },
  ];

  void nextQuestion(String selectedOption) {
    // Here you could also check for the correctness of the answer
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      // Restart the quiz or navigate to a results screen
      setState(() {
        currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      // Wrap the content in SingleChildScrollView to avoid overflow
      body: SingleChildScrollView(
        child: Center(
          child: QuestionCard(
            imagePath: questions[currentIndex]["image"],
            question: questions[currentIndex]["question"],
            options: List<String>.from(questions[currentIndex]["options"]),
            onOptionSelected: nextQuestion,
          ),
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

  const QuestionCard({
    required this.imagePath,
    required this.question,
    required this.options,
    required this.onOptionSelected,
    Key? key,
  }) : super(key: key);

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white,
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 40, 10, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    Column(
                      children: options.map((option) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 20),
                          child: ElevatedButton(
                            onPressed: () => onOptionSelected(option),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(250, 50),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                    color: Color(0xFFC0BABA)),
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
