import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SelectImagePage extends StatefulWidget {
  const SelectImagePage({Key? key}) : super(key: key);

  @override
  State<SelectImagePage> createState() => _SelectImagePageState();
}

class _SelectImagePageState extends State<SelectImagePage> {
  int _selectedIndex = 0; // For bottom navigation
  final FlutterTts _flutterTts = FlutterTts();
  bool _answered = false;
  int _currentQuestion = 0;
  int _score = 0;
  final List<Map<String, dynamic>> _questions = [
    {
      'spanish': 'El corazón',
      'answer': 'Heart',
      'options': [
        {'label': 'Heart', 'image': 'assets/images/heart.png'},
        {'label': 'Lungs', 'image': 'assets/images/lungs.png'},
        {'label': 'Muscle', 'image': 'assets/images/muscle.png'},
        {'label': 'Tongue', 'image': 'assets/images/tongue.png'},
      ],
    },
    {
      'spanish': 'Los pulmones',
      'answer': 'Lungs',
      'options': [
        {'label': 'Lungs', 'image': 'assets/images/lungs.png'},
        {'label': 'Heart', 'image': 'assets/images/heart.png'},
        {'label': 'Bone', 'image': 'assets/bone.jpeg'},
        {'label': 'Tongue', 'image': 'assets/images/tongue.png'},
      ],
    },
    {
      'spanish': 'El hueso',
      'answer': 'Bone',
      'options': [
        {'label': 'Bone', 'image': 'assets/bone.jpeg'},
        {'label': 'Lungs', 'image': 'assets/images/lungs.png'},
        {'label': 'Heart', 'image': 'assets/images/heart.png'},
        {'label': 'Tongue', 'image': 'assets/images/tongue.png'},
      ],
    },
  ];

  // Example function to handle bottom nav taps with navigation logic
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigate to different pages based on the selected index.
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/questions');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  // Function to play audio/TTS for the given text
  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  // Function to check if the selected answer is correct
  void _checkAnswer(String selectedAnswer) {
    if (_answered) return;
    _answered = true;

    final isCorrect = selectedAnswer == _questions[_currentQuestion]['answer'];
    if (isCorrect) {
      _score++;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? "Correct Answer!" : "Incorrect Answer!"),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() {
        if (_currentQuestion < _questions.length - 1) {
          _currentQuestion++;
          _answered = false;
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Quiz Complete!'),
              content: Text('You got $_score out of ${_questions.length} questions correct!'),
              actions: [
                TextButton(
                  child: const Text('Return to Home'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
              ],
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    return Scaffold(
      appBar: AppBar(
        title: const Text('DR Biology'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87, // Make AppBar text/icon black
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${_currentQuestion + 1} of ${_questions.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Row with speaker icon + Spanish text
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Play TTS for the current question's Spanish text
                      _speak(question['spanish']);
                    },
                    icon: const Icon(Icons.volume_up),
                    color: Colors.blueAccent,
                  ),
                  Text(
                    question['spanish'],
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Cards in a Grid
              GridView.count(
                shrinkWrap: true, // So it doesn't take infinite height
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  for (final opt in question['options'])
                    _buildImageCard(
                      imageUrl: opt['image'],
                      label: opt['label'],
                      onTap: () => _checkAnswer(opt['label']),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Example Bottom Navigation Bar with navigation logic
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Questions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  // Helper method to build each card
  Widget _buildImageCard({
    required String imageUrl,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the image (using Image.asset for local assets)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
