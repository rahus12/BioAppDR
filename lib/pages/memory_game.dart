import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

// Card model with image path, description, and type (image or name)
class _CardModel {
  final String value; // It can either be an image path or a name
  final bool isImage; // Whether this card is an image or a name
  bool isFlipped;
  bool isMatched;
  final int index;

  _CardModel({
    required this.value,
    required this.isImage,
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
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpanish = false;
  // List of image paths and their names
  final List<String> _images = [
    'assets/heart.jpeg',
    'assets/lungs.jpeg',
    'assets/brain.jpg',
    'assets/liver.jpeg',
  ];

  final List<String> _names = [
    'Heart',
    'Lungs',
    'Brain',
    'Liver',
  ];
  final List<String> _namesEs = [
    'Corazón',
    'Pulmones',
    'Cerebro',
    'Hígado',
  ];

  late List<_CardModel> _cards;
  int? _firstFlippedIndex;
  int? _secondFlippedIndex;
  bool _wait = false;
  int _matchesFound = 0;

  @override
  void initState() {
    super.initState();
    _setupCards();
  }

  void _toggleLanguage() {
    setState(() {
      _isSpanish = !_isSpanish;
    });
  }

  Future<void> _speak(String text) async {
    try {
      await _flutterTts.stop();
      await _flutterTts.setLanguage(_isSpanish ? 'es-ES' : 'en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);
      if (text.isNotEmpty) await _flutterTts.speak(text);
    } catch (_) {}
  }

  void _setupCards() {
    List<_CardModel> cardList = [];
    for (int i = 0; i < _images.length; i++) {
      // Add image cards
      cardList.add(_CardModel(
        value: _images[i],
        isImage: true,
        index: i,
      ));
      // Add name cards
      cardList.add(_CardModel(
        value: _names[i],
        isImage: false,
        index: i,
      ));
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

  void _onCardTap(int cardIndex) {
    if (_wait) return;

    final clickedCard = _cards[cardIndex];
    if (clickedCard.isMatched || clickedCard.isFlipped) {
      return;
    }

    setState(() {
      clickedCard.isFlipped = true;

      if (_firstFlippedIndex == null) {
        _firstFlippedIndex = cardIndex;
        // Speak the name when a name card is flipped
        if (!clickedCard.isImage) {
          final name = _isSpanish ? _namesEs[clickedCard.index] : _names[clickedCard.index];
          _speak(name);
        }
      } else if (_secondFlippedIndex == null) {
        _secondFlippedIndex = cardIndex;
        _checkForMatch();
      }
    });
  }

  void _checkForMatch() {
    if (_firstFlippedIndex == null || _secondFlippedIndex == null) return;

    final firstCard = _cards[_firstFlippedIndex!];
    final secondCard = _cards[_secondFlippedIndex!];

    // Check if one is an image and the other is a name and if they match
    if (firstCard.isImage != secondCard.isImage && firstCard.index == secondCard.index) {
      setState(() {
        firstCard.isMatched = true;
        secondCard.isMatched = true;
        _matchesFound += 1;
      });

      _firstFlippedIndex = null;
      _secondFlippedIndex = null;

      if (_matchesFound == _images.length) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _showGameWonDialog();
        });
      }
    } else {
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

  void _showGameWonDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isSpanish ? "¡Felicidades!" : "Congratulations!"),
        content: Text(_isSpanish ? "¡Has encontrado todas las parejas!" : "You matched all the pairs!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _setupCards();
            },
            child: Text(_isSpanish ? "Jugar de nuevo" : "Play Again"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSpanish ? "Juego de Memoria" : "Memory Game"),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: _isSpanish ? 'Switch to English' : 'Cambiar a Español',
            onPressed: _toggleLanguage,
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            tooltip: _isSpanish ? 'Leer instrucciones' : 'Speak instructions',
            onPressed: () {
              final instructions = _isSpanish
                  ? 'Encuentra pares coincidentes para ganar.'
                  : 'Find matching pairs to win.';
              _speak(instructions);
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: _cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final card = _cards[index];
            return GestureDetector(
              onTap: () => _onCardTap(index),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: card.isFlipped || card.isMatched
                    ? card.isImage
                        ? Image.asset(
                            card.value,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Text(
                              _isSpanish ? _namesEs[card.index] : _names[card.index],
                              style: const TextStyle(fontSize: 18),
                            ),
                          )
                    : Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: Center(
                          child: Text(
                            _isSpanish ? "Toca" : "Tap",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
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
