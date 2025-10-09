import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bioappdr/pages/Home.dart';

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
      // Update progress for each correct answer
      _updateProgress(currentIndex + 1);
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
          _updateProgress(questions.length); // Mark quiz as completed
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
                    // Refresh home data after navigation
                    Future.delayed(const Duration(milliseconds: 100), () {
                      Home.refreshHomeData();
                    });
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

  Future<void> _updateProgress(int questionsCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mcq_progress', questionsCompleted);
  }

  @override
  Widget build(BuildContext context) {
    final questionData = questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text(
            "Science MCQ",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 35,
                letterSpacing: 0.5,
                fontFamily:'LuckiestGuy')),

        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.orange.shade300,
                Colors.orange.shade500,
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            const SizedBox(height: 20),
            Center(
              child: AnimatedQuestionCard(
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

class AnimatedQuestionCard extends StatefulWidget {
  final String imagePath;
  final String question;
  final List<String> options;
  final Function(String) onOptionSelected;
  final String? selectedOption;
  final bool? isCorrect;

  const AnimatedQuestionCard({
    required this.imagePath,
    required this.question,
    required this.options,
    required this.onOptionSelected,
    this.selectedOption,
    this.isCorrect,
    Key? key,
  }) : super(key: key);

  @override
  _AnimatedQuestionCardState createState() => _AnimatedQuestionCardState();
}

class _AnimatedQuestionCardState extends State<AnimatedQuestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _timer;
  final _random = Random();

  late Animation<Offset> _bottomAnimation;
  late Animation<Offset> _leftAnimation;
  late Animation<Offset> _rightAnimation;
  Alignment _alignment = Alignment.bottomCenter;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _bottomAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _leftAnimation = Tween<Offset>(
      begin:  const Offset(0.2, 0.0),
      end: const Offset(-0.8, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rightAnimation = Tween<Offset>(
      begin: const Offset(-0.2, 0.0),
      end: const Offset(0.8, 0.0) ,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _offsetAnimation = _bottomAnimation; // Default animation

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _playAnimation();
    });
  }

  void _playAnimation() {
    final orientation = MediaQuery.of(context).orientation;
    int count = 0;
    setState(() {
      if (orientation == Orientation.portrait) {
        final side = _random.nextInt(3); // 0: bottom, 1: left, 2: right
        if (side == 0) {
          _alignment = Alignment.bottomCenter;
          _offsetAnimation = _bottomAnimation;
          print("goin bottom");
        } else if (side == 1) {
          _alignment = Alignment.centerLeft;
          _offsetAnimation = _leftAnimation;
          print("goin left");
        } else {
          _alignment = Alignment.centerRight;
          _offsetAnimation = _rightAnimation;
          print("goin right");
        }
      } else { // Landscape
        final side = _random.nextInt(2); // 0: left, 1: right
        // int side = count % 2;
        if (side == 0) {
          _alignment = Alignment.centerLeft;
          _offsetAnimation = _leftAnimation;
          print("goin left");
        } else {
          _alignment = Alignment.centerRight;
          _offsetAnimation = _rightAnimation;
          print("goin right");
        }
        // count = count +1;
      }
    });

    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        _controller.reverse();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Allow image to pop out
      alignment: _alignment,
      children: [
        // The monkey/character that pops up
        SlideTransition(
          position: _offsetAnimation,
          child: Image.asset('assets/monkey.webp', height: 200), // Placeholder
        ),
        // The actual question card
        QuestionCard(
          imagePath: widget.imagePath,
          question: widget.question,
          options: widget.options,
          onOptionSelected: widget.onOptionSelected,
          selectedOption: widget.selectedOption,
          isCorrect: widget.isCorrect,
        ),
      ],
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top image
          Image.asset(imagePath, height: 150),
          const SizedBox(height: 20),
          // Question text
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Sunshine'
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Option buttons
          Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: options.map((option) {
                bool isSelected = selectedOption == option;
                Color buttonColor;
                Widget? trailingIcon;

                if (isSelected) {
                  if (isCorrect == true) {
                    buttonColor = Colors.green.shade400;
                    trailingIcon =
                        const Icon(Icons.check_circle, color: Colors.white);
                  } else {
                    buttonColor = Colors.red.shade400;
                    trailingIcon =
                        const Icon(Icons.cancel, color: Colors.white);
                  }
                } else {
                  buttonColor = Colors.orange.shade400;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 20,
                  ),
                  child: ElevatedButton(
                    onPressed: () => onOptionSelected(option),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(250, 55),
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(option,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white)),
                        if (trailingIcon != null) ...[
                          const SizedBox(width: 10),
                          trailingIcon,
                        ]
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
