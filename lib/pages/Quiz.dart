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
    // "El corazón" corresponds to "Heart"
    final isCorrect = selectedAnswer == "Heart";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? "Correct Answer!" : "Incorrect Answer!"),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              // Title
              const Text(
                'Select the correct image',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // Row with speaker icon + Spanish text
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Play TTS for "El corazón"
                      _speak("El corazón");
                    },
                    icon: const Icon(Icons.volume_up),
                    color: Colors.blueAccent,
                  ),
                  const Text(
                    'El corazón',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4 Cards in a Grid
              GridView.count(
                shrinkWrap: true, // So it doesn't take infinite height
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildImageCard(
                    imageUrl: 'assets/images/heart.png', // Example local asset
                    label: 'Heart',
                    onTap: () {
                      // Check if this is the correct answer (it is)
                      _checkAnswer("Heart");
                    },
                  ),
                  _buildImageCard(
                    imageUrl: 'assets/images/lungs.png',
                    label: 'Lungs',
                    onTap: () {
                      // Check answer for "Lungs" (incorrect for "El corazón")
                      _checkAnswer("Lungs");
                    },
                  ),
                  _buildImageCard(
                    imageUrl: 'assets/images/muscle.png',
                    label: 'Muscle',
                    onTap: () {
                      // Check answer for "Muscle" (incorrect for "El corazón")
                      _checkAnswer("Muscle");
                    },
                  ),
                  _buildImageCard(
                    imageUrl: 'assets/images/tongue.png',
                    label: 'Tongue',
                    onTap: () {
                      // Check answer for "Tongue" (incorrect for "El corazón")
                      _checkAnswer("Tongue");
                    },
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
