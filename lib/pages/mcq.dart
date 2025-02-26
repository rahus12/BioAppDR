/*
Need to build the MCQ page, which idealy has a picture and 4 options.
Questions can later come from FireBase
For now use a list if u want
 */


import 'package:flutter/material.dart';

class Mcq extends StatefulWidget {
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
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      // Reset Mcq or navigate to a results screen
      setState(() {
        currentIndex = 0; // Restart Mcq
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Science Mcq")),
      body: Center(
        child: QuestionCard(
          imagePath: questions[currentIndex]["image"],
          question: questions[currentIndex]["question"],
          options: List<String>.from(questions[currentIndex]["options"]),
          onOptionSelected: nextQuestion,
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
        ]
      )
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Color(0xFFF5F5F5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0,50,0,100),
            child: Image.asset(imagePath, height: 250),
          ), // Display image on top,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white,
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10,40,10,20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(question, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 30,),
                    Column(
                      children: options.map((option) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                          child: ElevatedButton(
                            onPressed: () => onOptionSelected(option),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(250, 50),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Color(0xFFC0BABA))
                              )
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
