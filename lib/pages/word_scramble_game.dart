import 'package:flutter/material.dart';

class WordScrambleGame extends StatefulWidget {
  const WordScrambleGame({Key? key}) : super(key: key);

  @override
  State<WordScrambleGame> createState() => _WordScrambleGameState();
}

class _WordScrambleGameState extends State<WordScrambleGame> {
  // List of organs or words to scramble.
  // Each entry has: 'word' (the correct word), 'hint' (optional help text),
  // and 'image' (optional: path to an asset image).
  final List<Map<String, String>> _scrambleItems = [
    {
      "word": "HEART",
      "hint": "It pumps blood throughout the body.",
      "image": "assets/heart.jpeg"
    },
    {
      "word": "LUNGS",
      "hint": "They help you breathe in oxygen.",
      "image": "assets/lungs.jpeg"
    },
    {
      "word": "BRAIN",
      "hint": "The control center of the body.",
      "image": "assets/brain.jpg"
    },
    {
      "word": "LIVER",
      "hint": "Filters toxins from your blood.",
      "image": "assets/liver.jpeg"
    },
    {
      "word": "STOMACH",
      "hint": "It churns and digests your food.",
      "image": "assets/stomach.jpeg"
    },
  ];

  // Keep track of which word we're currently on.
  int _currentIndex = 0;

  // Store the letters for the scrambled word.
  late List<String> _scrambledLetters;

  // Store the letters that the user has tapped in order.
  List<String> _userInput = [];

  // Lifecycle: scramble the first word on init.
  @override
  void initState() {
    super.initState();
    _resetGameState();
  }

  // Helper: scramble the letters of a word.
  List<String> _scrambleWord(String word) {
    List<String> letters = word.split('');
    letters.shuffle();
    return letters;
  }

  // Resets the userInput and scrambles the current word.
  void _resetGameState() {
    // 1. Get the current word from the list.
    final currentWord = _scrambleItems[_currentIndex]["word"] ?? "";

    // 2. Scramble the letters of that word.
    _scrambledLetters = _scrambleWord(currentWord);

    // 3. Clear the user’s current selections.
    _userInput = [];
  }

  // Called whenever the user taps a letter.
  void _onLetterTap(String letter, int letterIndex) {
    setState(() {
      // Add the tapped letter to userInput.
      _userInput.add(letter);
      // Remove that letter from the scrambled array so user cannot tap it again.
      _scrambledLetters[letterIndex] = "";
    });

    final correctWord = _scrambleItems[_currentIndex]["word"] ?? "";
    // If userInput is the length of the correct word, check correctness.
    if (_userInput.length == correctWord.length) {
      final userGuess = _userInput.join("");
      if (userGuess.toUpperCase() == correctWord.toUpperCase()) {
        // Show success
        _showResultDialog(true);
      } else {
        // Show fail
        _showResultDialog(false);
      }
    }
  }

  // Reset the state for the next word or re-try the same word.
  void _showResultDialog(bool success) {
    final String title = success ? "Correct!" : "Incorrect!";
    final String content = success
        ? "Great job! You unscrambled the word correctly."
        : "That’s not the right spelling. Try again?";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog

              setState(() {
                if (success) {
                  // Move to next word
                  _currentIndex = (_currentIndex + 1) % _scrambleItems.length;
                }
                // Reset for next attempt or next word.
                _resetGameState();
              });
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Current puzzle data
    final item = _scrambleItems[_currentIndex];
    final String correctWord = item["word"] ?? "";
    final String hint = item["hint"] ?? "";
    final String imagePath = item["image"] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Word Scramble"),
        flexibleSpace: Container(
          // Optional gradient matching your other screens
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE6E1F5), Color(0xFFF5F5F5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 16.0),
          child: Column(
            children: [
              // Optional: Show the related image
              if (imagePath.isNotEmpty) ...[
                Image.asset(
                  imagePath,
                  height: 200,
                ),
                const SizedBox(height: 20),
              ],
              // Display a hint
              Text(
                "Hint: $hint",
                style: const TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),

              // Display the user's input as underscores or joined letters
              // Example: H _ A _ T
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  correctWord.length,
                  (index) {
                    String displayLetter =
                        index < _userInput.length ? _userInput[index] : "_";
                    return Container(
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        displayLetter.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Display the scrambled letters as buttons
              Wrap(
                alignment: WrapAlignment.center,
                children: List.generate(
                  _scrambledLetters.length,
                  (index) {
                    final letter = _scrambledLetters[index];
                    if (letter.isEmpty) {
                      // Already tapped letter
                      return const SizedBox(width: 0, height: 0);
                    }
                    return Container(
                      margin: const EdgeInsets.all(4),
                      child: ElevatedButton(
                        onPressed: () => _onLetterTap(letter, index),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: Text(
                          letter.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Optional: bottom nav to stay consistent with your other screens
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
