import 'package:flutter/material.dart';

// 1. Move _CardModel to the top-level scope in this file.
class _CardModel {
  final String imagePath;
  bool isFlipped;
  bool isMatched;
  final int index;

  _CardModel({
    required this.imagePath,
    required this.index,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class MemoryGame extends StatefulWidget {
  const MemoryGame({Key? key}) : super(key: key);

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  // 2. This list holds the image asset paths. Each will appear twice (a pair).
  //    You can expand this if you want more pairs!
  final List<String> _images = [
    'assets/heart.jpeg',
    'assets/lungs.jpeg',
    'assets/brain.jpg',
    'assets/liver.jpeg',
  ];

  // 3. We'll build a list of _CardModel objects. Each image is duplicated.
  late List<_CardModel> _cards;

  // Track the indices of the first and second flipped cards
  int? _firstFlippedIndex;
  int? _secondFlippedIndex;

  // Prevent additional taps while checking for matches
  bool _wait = false;

  // Track how many matches have been found
  int _matchesFound = 0;

  @override
  void initState() {
    super.initState();
    _setupCards();
  }

  // Creates the pairs, shuffles them, and resets game state
  void _setupCards() {
    List<_CardModel> cardList = [];
    for (int i = 0; i < _images.length; i++) {
      cardList.add(_CardModel(imagePath: _images[i], index: i));
      cardList.add(_CardModel(imagePath: _images[i], index: i));
    }
    cardList.shuffle();

    setState(() {
      _cards = cardList;
      _matchesFound = 0;
      _firstFlippedIndex = null;
      _secondFlippedIndex = null;
      _wait = false;
    });
  }

  // Called when the user taps a card
  void _onCardTap(int cardIndex) {
    if (_wait) return; // If we are waiting to flip back, do nothing

    final clickedCard = _cards[cardIndex];
    if (clickedCard.isMatched || clickedCard.isFlipped) {
      // Already matched or face-up? Ignore.
      return;
    }

    setState(() {
      // Flip the tapped card
      clickedCard.isFlipped = true;

      // If no card was flipped yet, store this as first flipped
      if (_firstFlippedIndex == null) {
        _firstFlippedIndex = cardIndex;
      } else if (_secondFlippedIndex == null) {
        // This is the second flip
        _secondFlippedIndex = cardIndex;
        _checkForMatch();
      }
    });
  }

  // Check if the two flipped cards form a match
  void _checkForMatch() {
    if (_firstFlippedIndex == null || _secondFlippedIndex == null) return;

    final firstCard = _cards[_firstFlippedIndex!];
    final secondCard = _cards[_secondFlippedIndex!];

    if (firstCard.index == secondCard.index) {
      // It's a match!
      setState(() {
        firstCard.isMatched = true;
        secondCard.isMatched = true;
        _matchesFound += 1;
      });

      // Reset flipped indices
      _firstFlippedIndex = null;
      _secondFlippedIndex = null;

      // If all pairs are matched, show a dialog
      if (_matchesFound == _images.length) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _showGameWonDialog();
        });
      }
    } else {
      // Not a match → wait a bit, then flip them back
      _wait = true;
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          firstCard.isFlipped = false;
          secondCard.isFlipped = false;
          _firstFlippedIndex = null;
          _secondFlippedIndex = null;
          _wait = false;
        });
      });
    }
  }

  // Show "Game Won" popup
  void _showGameWonDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Congratulations!"),
        content: const Text("You matched all the pairs!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Reset the game
              _setupCards();
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We have 2 cards per image in _images, so total cards = _images.length * 2.
    // A 4x? grid works well with 8 cards.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memory Game"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE6E1F5), Color(0xFFF5F5F5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: _cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,     // 4 columns across
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final card = _cards[index];
            return GestureDetector(
              onTap: () => _onCardTap(index),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: card.isFlipped || card.isMatched
                    ? Image.asset(
                        card.imagePath,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Text(
                            "Tap",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
              ),
            );
          },
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
