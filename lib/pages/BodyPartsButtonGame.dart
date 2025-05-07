import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

class BodyPartsButtonGame extends StatefulWidget {
  const BodyPartsButtonGame({Key? key}) : super(key: key);

  @override
  _BodyPartsButtonGameState createState() => _BodyPartsButtonGameState();
}

class _BodyPartsButtonGameState extends State<BodyPartsButtonGame> with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpanish = false;
  int _score = 0;
  int _currentPartIndex = 0;
  bool _showFeedback = false;
  bool _isCorrect = false;
  String _feedbackMessage = '';

  // Selected part tracking
  int? _selectedPartIndex;

  // Line animation controller
  late AnimationController _lineAnimController;
  late Animation<double> _lineAnimProgress;

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  // Track part placements
  List<bool> _partsPlaced = [];

  // Image loading status
  bool _imagesLoaded = false;
  final Map<String, ui.Image> _loadedImages = {};

  // Configuration
  static const String _bodyImagePath = 'assets/Body.png';

  // Store button positions for line drawing
  Map<int, Offset> _buttonPositions = {};
  Map<int, Offset> _targetPositions = {};

  // Game data - Body parts with their descriptions and target positions
  // Game data - Body parts with their descriptions and target positions
  final List<Map<String, dynamic>> _bodyParts = [
    {
      'name_en': 'Heart',
      'name_es': 'Corazón',
      'imagePath': 'assets/Heart.png',
      'description_en': 'This organ pumps blood through your body, delivering oxygen and nutrients to your cells. It beats about 100,000 times a day!',
      'description_es': 'Este órgano bombea sangre a través de tu cuerpo, entregando oxígeno y nutrientes a tus células. ¡Late aproximadamente 100,000 veces al día!',
      'targetX': 0.44, // Modified: moved left from 0.52
      'targetY': 0.40,
      'tolerance': 0.07,
      'sizeFactor': 0.08,
      'color': Colors.red.shade400,
    },
    {
      'name_en': 'Brain',
      'name_es': 'Cerebro',
      'imagePath': 'assets/Brain.png',
      'description_en': 'This organ controls all bodily functions, thoughts, emotions, and memory. It\'s the command center of your body.',
      'description_es': 'Este órgano controla todas las funciones corporales, pensamientos, emociones y memoria. Es el centro de mando de tu cuerpo.',
      'targetX': 0.5,
      'targetY': 0.12,
      'tolerance': 0.06,
      'sizeFactor': 0.09,
      'color': Colors.pink.shade200,
    },
    {
      'name_en': 'Lungs',
      'name_es': 'Pulmones',
      'imagePath': 'assets/Lungs.png',
      'description_en': 'These organs help you breathe by taking in oxygen and releasing carbon dioxide. They expand and contract as you breathe.',
      'description_es': 'Estos órganos te ayudan a respirar tomando oxígeno y liberando dióxido de carbono. Se expanden y contraen mientras respiras.',
      'targetX': 0.42, // Modified: moved left from 0.5
      'targetY': 0.36,
      'tolerance': 0.08,
      'sizeFactor': 0.12,
      'color': Colors.blue.shade200,
    },
    {
      'name_en': 'Liver',
      'name_es': 'Hígado',
      'imagePath': 'assets/liver.jpeg',
      'description_en': 'This organ filters blood, detoxifies chemicals, and produces proteins for blood clotting. It also helps with digestion.',
      'description_es': 'Este órgano filtra la sangre, desintoxica químicos y produce proteínas para la coagulación sanguínea. También ayuda con la digestión.',
      'targetX': 0.58,
      'targetY': 0.46,
      'tolerance': 0.07,
      'sizeFactor': 0.09,
      'color': Colors.brown.shade400,
    },
    {
      'name_en': 'Stomach',
      'name_es': 'Estómago',
      'imagePath': 'assets/Stomach.png',
      'description_en': 'This organ digests food and mixes it with digestive juices. It breaks down food before it passes to the intestines.',
      'description_es': 'Este órgano digiere los alimentos y los mezcla con jugos digestivos. Descompone los alimentos antes de que pasen a los intestinos.',
      'targetX': 0.48,
      'targetY': 0.50,
      'tolerance': 0.07,
      'sizeFactor': 0.09,
      'color': Colors.amber.shade300,
    },
    {
      'name_en': 'Kidneys',
      'name_es': 'Riñones',
      'imagePath': 'assets/Kidney.png',
      'description_en': 'These organs filter waste from your blood and make urine. They help maintain the proper balance of water and minerals in your body.',
      'description_es': 'Estos órganos filtran los desechos de la sangre y producen orina. Ayudan a mantener el equilibrio adecuado de agua y minerales en tu cuerpo.',
      'targetX': 0.5,
      'targetY': 0.58,
      'tolerance': 0.08,
      'sizeFactor': 0.09,
      'color': Colors.purple.shade300,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initTTS();
    _preloadImages().then((_) {
      if (mounted) {
        setState(() {
          _imagesLoaded = true;
          _setupGame();
          _speakCurrentPartDescription();
        });
      }
    });
  }

  Future<void> _preloadImages() async {
    await _loadImage(_bodyImagePath);
    for (final part in _bodyParts) {
      await _loadImage(part['imagePath']);
    }
  }

  Future<void> _loadImage(String path) async {
    try {
      final data = await DefaultAssetBundle.of(context).load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final fi = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _loadedImages[path] = fi.image;
        });
      }
    } catch (e) {
      print("Error loading image $path: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading $path')),
        );
      }
    }
  }

  void _initAnimations() {
    // Pulse animation for target hints
    _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700)
    )..repeat(reverse: true);

    _pulseAnim = Tween(
        begin: 1.0,
        end: 1.15
    ).animate(CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut
    ));

    // Bounce animation for feedback
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _bounceAnim = Tween<double>(
        begin: 0.0,
        end: 1.0
    ).animate(CurvedAnimation(
        parent: _bounceController,
        curve: Curves.elasticOut
    ));

    // Line animation
    _lineAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _lineAnimProgress = CurvedAnimation(
      parent: _lineAnimController,
      curve: Curves.easeInOut,
    );
  }

  void _initTTS() async {
    await _flutterTts.setVolume(1);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1);
    await _flutterTts.setLanguage(_isSpanish ? 'es-ES' : 'en-US');
  }

  void _speakCurrentPartDescription() async {
    final part = _bodyParts[_currentPartIndex];
    final text = _isSpanish ? part['description_es'] : part['description_en'];
    await _flutterTts.stop();
    await _flutterTts.setLanguage(_isSpanish ? 'es-ES' : 'en-US');
    await _flutterTts.speak(text);
  }

  void _toggleLanguage() {
    setState(() => _isSpanish = !_isSpanish);
    _speakCurrentPartDescription();
  }

  void _setupGame() {
    _score = 0;
    _partsPlaced = List.filled(_bodyParts.length, false);
    _currentPartIndex = Random().nextInt(_bodyParts.length);
    _selectedPartIndex = null;
    _buttonPositions = {};
    _targetPositions = {};

    // Precalculate target positions
    final size = MediaQuery.of(context).size;
    for (int i = 0; i < _bodyParts.length; i++) {
      final part = _bodyParts[i];
      _targetPositions[i] = Offset(
          part['targetX'] * size.width,
          part['targetY'] * size.height
      );
    }
  }

  void _selectPart(int idx) {
    if (_partsPlaced[idx]) return;

    setState(() {
      _selectedPartIndex = idx;
      _showFeedback = false;
      // Start line animation
      _lineAnimController.forward(from: 0);
    });
  }

  void _attemptPlacement() {
    if (_selectedPartIndex == null) return;

    final idx = _selectedPartIndex!;
    final targetPart = _bodyParts[_currentPartIndex];

    setState(() {
      if (idx == _currentPartIndex) {
        // Correct part selected
        _partsPlaced[idx] = true;
        _score += 10;

        _isCorrect = true;
        _feedbackMessage = _isSpanish ? '¡Correcto! (+10)' : 'Correct! (+10)';
        _showFeedback = true;

        // Play bounce animation
        _bounceController.forward(from: 0);

        // Check for game completion or advance to next part
        Future.delayed(const Duration(milliseconds: 800), () {
          if (_partsPlaced.every((placed) => placed)) {
            _showCompletionDialog();
          } else {
            _advanceToNextPart();
          }
        });
      } else {
        // Incorrect part selected
        _isCorrect = false;
        _feedbackMessage = _isSpanish ? 'Intenta de nuevo' : 'Try again';
        _showFeedback = true;

        // Hide feedback after delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() => _showFeedback = false);
          }
        });
      }

      _selectedPartIndex = null;
      _lineAnimController.reverse();
    });
  }

  void _advanceToNextPart() {
    // Find next unplaced part
    int next = (_currentPartIndex + 1) % _bodyParts.length;
    while (_partsPlaced[next] && next != _currentPartIndex) {
      next = (next + 1) % _bodyParts.length;
    }

    setState(() {
      _currentPartIndex = next;
      _showFeedback = false;
      _selectedPartIndex = null;
    });

    _speakCurrentPartDescription();
  }

  void _showCompletionDialog() {
    _flutterTts.speak(_isSpanish ? '¡Felicidades! Has completado el juego!' : 'Congratulations! You completed the game!');

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.purple.shade50, Colors.purple.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title with sparkles
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.celebration, color: Colors.amber, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    _isSpanish ? '¡Felicidades!' : 'Congratulations!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.celebration, color: Colors.amber, size: 28),
                ],
              ),

              const SizedBox(height: 20),

              // Completion message
              Text(
                _isSpanish
                    ? '¡Has colocado correctamente todas las partes del cuerpo!'
                    : 'You have correctly placed all body parts!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              // Score display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 30),
                    const SizedBox(width: 12),
                    Text(
                      '${_isSpanish ? 'Puntuación Final' : 'Final Score'}: $_score',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Play again button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _imagesLoaded = false);
                  _preloadImages().then((_) {
                    if (mounted) {
                      setState(() => _imagesLoaded = true);
                      _setupGame();
                      _speakCurrentPartDescription();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  _isSpanish ? 'Jugar de Nuevo' : 'Play Again',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _replayDescription() => _speakCurrentPartDescription();

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    _lineAnimController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  // Modified: Target hint displays next to body image
  Widget _buildTargetHintWidget(int idx, Size size) {
    final part = _bodyParts[idx];
    final targetX = part['targetX'] as double;
    final targetY = part['targetY'] as double;
    final sizeFactor = part['sizeFactor'] as double;

    // Calculate positions for the target indicators (next to body, not on it)
    // For left side organs, place them to the left, for right side organs, place them to the right
    bool placeOnRight = targetX >= 0.5;

    final displayX = placeOnRight
        ? size.width * 0.75 // Right side of the body
        : size.width * 0.25; // Left side of the body

    // Keep the same vertical position
    final displayY = targetY * size.height;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Positioned(
          left: displayX - (size.width * sizeFactor * _pulseAnim.value / 2),
          top: displayY - (size.width * sizeFactor * _pulseAnim.value / 2),
          width: size.width * sizeFactor * _pulseAnim.value,
          height: size.width * sizeFactor * _pulseAnim.value,
          child: GestureDetector(
            onTap: _selectedPartIndex != null ? _attemptPlacement : null,
            child: Container(
              decoration: BoxDecoration(
                color: _selectedPartIndex != null
                    ? (part['color'] as Color).withOpacity(0.8) // More visible
                    : (part['color'] as Color).withOpacity(0.6), // More visible
                borderRadius: BorderRadius.circular(12), // More rounded
                border: Border.all(
                  color: _selectedPartIndex != null
                      ? Colors.white
                      : (part['color'] as Color),
                  width: 3, // Thicker border
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: _selectedPartIndex != null
                  ? Icon(Icons.add_circle, color: Colors.white, size: 24) // Larger icon
                  : Icon(Icons.circle_outlined, color: Colors.white.withOpacity(0.7), size: 18), // Visible indicator
            ),
          ),
        );
      },
    );
  }

  // Modified: Placed parts next to body image, not on it
  Widget _buildPlacedPartWidget(int idx, Size size) {
    final part = _bodyParts[idx];
    final targetX = part['targetX'] as double;
    final targetY = part['targetY'] as double;
    final sizeFactor = part['sizeFactor'] as double;

    // Calculate positions for the placed parts (next to the body, not on it)
    // For left side organs, place them to the left, for right side organs, place them to the right
    bool placeOnRight = targetX >= 0.5;

    final displayX = placeOnRight
        ? size.width * 0.75 // Right side of the body
        : size.width * 0.25; // Left side of the body

    // Keep the same vertical position
    final displayY = targetY * size.height;

    return Positioned(
      left: displayX - (size.width * sizeFactor / 2),
      top: displayY - (size.width * sizeFactor / 2),
      width: size.width * sizeFactor,
      height: size.width * sizeFactor,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), // More rounded
          boxShadow: [
            BoxShadow(
              color: (part['color'] as Color).withOpacity(0.7), // More visible shadow
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12), // More rounded
          child: Container(
            color: (part['color'] as Color).withOpacity(0.9), // Background color for contrast
            child: Padding(
              padding: EdgeInsets.all(4), // Padding for the image
              child: Image.asset(
                part['imagePath'],
                fit: BoxFit.contain, // Better fit
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Modified: Draw connecting line between button and target on the body (not the display position)
  Widget _buildConnectingLine(Size size) {
    if (_selectedPartIndex == null) return Container();

    final idx = _selectedPartIndex!;
    final part = _bodyParts[idx];
    final color = part['color'] as Color;

    // Only draw if we have the button position
    if (!_buttonPositions.containsKey(idx)) return Container();

    final buttonPos = _buttonPositions[idx]!;

    // Connect to the ACTUAL target position on the body, not the display position
    final targetPos = Offset(
        part['targetX'] * size.width,
        part['targetY'] * size.height
    );

    return AnimatedBuilder(
      animation: _lineAnimProgress,
      builder: (context, child) {
        return CustomPaint(
          size: Size(size.width, size.height),
          painter: LineConnectorPainter(
            start: buttonPos,
            end: targetPos,
            color: color,
            progress: _lineAnimProgress.value,
            strokeWidth: 3.0, // Thicker line for better visibility
          ),
        );
      },
    );
  }

  // Modified: Build bottom grid with better fitting buttons and images
  Widget _buildPartButtonsGrid(Size size) {
    return Container(
        height: size.height * 0.15, // Taller for better visibility
        decoration: BoxDecoration(
          color: Colors.purple.shade100,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: GridView.builder(
        padding: const EdgeInsets.all(10),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 6,
    childAspectRatio: 0.8, // Taller buttons
    crossAxisSpacing: 8, // More spacing
    mainAxisSpacing: 8,
    ),
    itemCount: _bodyParts.length,
    itemBuilder: (context, idx) {
    final part = _bodyParts[idx];
    final isPlaced = _partsPlaced[idx];
    final isSelected = _selectedPartIndex == idx;
    final isCurrent = idx == _currentPartIndex;

    // Skip already placed parts
    if (isPlaced) {
    return Container(
    decoration: BoxDecoration(
    color: Colors.grey.withOpacity(0.3),
    borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
    child: Icon(
    Icons.check_circle,
    color: Colors.green.withOpacity(0.5),
    size: 24, // Larger icon
    ),
    ),
    );
    }

    // Return button with builder to measure its position
    return LayoutBuilder(
    builder: (context, constraints) {
    return Container(
    key: GlobalKey(),
    child: InkWell(
    onTap: () {
    // Get the button's render box to find its position
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);

    // Store button center position
    _buttonPositions[idx] = Offset(
    position.dx + box.size.width / 2,
    position.dy + box.size.height / 2,
    );

    _selectPart(idx);
    },
    child: Container(
    decoration: BoxDecoration(
    color: isSelected
    ? part['color']
        : (isCurrent
    ? Colors.white
        : Colors.purple.shade50),
    borderRadius: BorderRadius.circular(12), // More rounded
    border: isCurrent && !isSelected
    ? Border.all(color: Colors.yellow, width: 3) // Thicker border
        : null,
    boxShadow: [
    BoxShadow(
        color: isSelected
        ? (part['color'] as Color).withOpacity(0.7)
        : Colors.black.withOpacity(0.1),
      blurRadius: 4,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
    ],
    ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  part['imagePath'],
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _isSpanish ? part['name_es'] : part['name_en'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    ),
    );
    },
    );
    },
        ),
    );
  }

  Widget _buildFeedbackWidget(Size size) {
    if (!_showFeedback) return Container();

    return AnimatedBuilder(
      animation: _bounceAnim,
      builder: (context, child) {
        final scale = _isCorrect
            ? 0.8 + (_bounceAnim.value * 0.4)  // 0.8 to 1.2 scale
            : 1.0;

        return Center(
          child: Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _isCorrect ? Colors.green.shade400 : Colors.orange.shade300,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                _feedbackMessage,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (!_imagesLoaded) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: Text(_isSpanish ? 'Juego de Partes del Cuerpo' : 'Body Parts Game'),
        backgroundColor: Colors.purple.shade300,
        actions: [
          // Score display
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 4),
                Text('$_score',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
              ],
            ),
          ),
          // Language toggle
          IconButton(
            icon: Icon(_isSpanish ? Icons.language : Icons.language),
            onPressed: _toggleLanguage,
            tooltip: _isSpanish ? 'Switch to English' : 'Cambiar a Español',
          ),
          // Replay description
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: _replayDescription,
            tooltip: _isSpanish ? 'Repetir descripción' : 'Replay description',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Body background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade50, Colors.purple.shade100],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Body image
          Positioned(
            top: size.height * 0.05,
            left: 0,
            right: 0,
            bottom: size.height * 0.2,
            child: Center(
              child: Container(
                height: size.height * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    _bodyImagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // Line connecting button to target
          _buildConnectingLine(size),

          // Placed parts (alongside body)
          for (int i = 0; i < _bodyParts.length; i++)
            if (_partsPlaced[i]) _buildPlacedPartWidget(i, size),

          // Current target hint
          if (!_partsPlaced[_currentPartIndex])
            _buildTargetHintWidget(_currentPartIndex, size),

          // Feedback message (center of screen)
          _buildFeedbackWidget(size),

          // Body part description
          Positioned(
            bottom: size.height * 0.15 + 20, // Above the buttons grid
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isSpanish
                        ? '¿Puedes encontrar el ${_bodyParts[_currentPartIndex]['name_es']}?'
                        : 'Can you find the ${_bodyParts[_currentPartIndex]['name_en']}?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isSpanish
                        ? _bodyParts[_currentPartIndex]['description_es']
                        : _bodyParts[_currentPartIndex]['description_en'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom part buttons grid
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildPartButtonsGrid(size),
          ),
        ],
      ),
    );
  }
}

// Custom painter for drawing the connecting line with animation
class LineConnectorPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;
  final double progress;
  final double strokeWidth;

  LineConnectorPainter({
    required this.start,
    required this.end,
    required this.color,
    required this.progress,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Calculate the animated endpoint
    final currentEnd = Offset(
      start.dx + (end.dx - start.dx) * progress,
      start.dy + (end.dy - start.dy) * progress,
    );

    // Draw the line
    canvas.drawLine(start, currentEnd, paint);

    // Draw a pulsing circle at the end of the line
    final circlePaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(currentEnd, strokeWidth * 2, circlePaint);

    // Add directional arrow at the end of the line for better guidance
    if (progress > 0.7) {
      final arrowSize = strokeWidth * 3;

      // Calculate angle
      final angle = atan2(end.dy - start.dy, end.dx - start.dx);

      // Calculate points for the arrow
      final p1 = Offset(
        currentEnd.dx - arrowSize * cos(angle - pi/6),
        currentEnd.dy - arrowSize * sin(angle - pi/6),
      );

      final p2 = Offset(
        currentEnd.dx - arrowSize * cos(angle + pi/6),
        currentEnd.dy - arrowSize * sin(angle + pi/6),
      );

      // Draw the arrow
      final path = Path()
        ..moveTo(currentEnd.dx, currentEnd.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close();

      canvas.drawPath(path, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(LineConnectorPainter oldDelegate) =>
      oldDelegate.progress != progress ||
          oldDelegate.start != start ||
          oldDelegate.end != end ||
          oldDelegate.color != color;
}
