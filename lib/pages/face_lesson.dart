import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FaceLesson extends StatefulWidget {
  const FaceLesson({super.key});

  @override
  State<FaceLesson> createState() => _FaceLessonState();
}

class _FaceLessonState extends State<FaceLesson> {
  int currentIndex = 0;
  final FlutterTts flutterTts = FlutterTts();


  bool _isSpanish = false;


  final List<Map<String, String>> faceLessons = [
    {
      // EYES
      "image": "assets/eyes.jpeg",
      "title_en": "Eyes",
      "title_es": "Ojos",
      "function_en": "Allow vision, interpret light and color, provide sense of sight.",
      "function_es": "Permiten la visión, interpretan la luz y el color, y brindan el sentido de la vista.",
      "location_en": "Front of the face, within the eye sockets.",
      "location_es": "Parte frontal de la cara, dentro de las cuencas oculares.",
      "importance_en": "Essential for visual perception; many daily tasks rely on sight.",
      "importance_es": "Esenciales para la percepción visual; muchas tareas diarias dependen de la vista."
    },
    {
      // EARS
      "image": "assets/ears.jpeg",
      "title_en": "Ears",
      "title_es": "Oídos",
      "function_en": "Capture sound waves, enabling hearing and balance.",
      "function_es": "Captan ondas sonoras, permitiendo la audición y el equilibrio.",
      "location_en": "On either side of the head.",
      "location_es": "A cada lado de la cabeza.",
      "importance_en": "Vital for communication and spatial awareness; helps maintain balance.",
      "importance_es": "Vitales para la comunicación y la percepción espacial; ayudan a mantener el equilibrio."
    },
    {
      // NOSE
      "image": "assets/nose.jpeg",
      "title_en": "Nose",
      "title_es": "Nariz",
      "function_en": "Filters, warms, and moistens air; provides sense of smell.",
      "function_es": "Filtra, calienta y humedece el aire; proporciona el sentido del olfato.",
      "location_en": "Center of the face, above the mouth.",
      "location_es": "Centro de la cara, sobre la boca.",
      "importance_en": "Crucial for breathing, smell, and flavor perception.",
      "importance_es": "Crucial para la respiración, el olfato y la percepción de sabores."
    },
    {
      // MOUTH
      "image": "assets/mouth.png",
      "title_en": "Mouth",
      "title_es": "Boca",
      "function_en": "Ingests food, initiates digestion, enables speech.",
      "function_es": "Ingiere alimentos, inicia la digestión y permite el habla.",
      "location_en": "Lower center of the face.",
      "location_es": "Parte inferior central de la cara.",
      "importance_en": "Key for eating, communication, and facial expressions.",
      "importance_es": "Clave para comer, comunicarse y las expresiones faciales."
    },
    {
      // TEETH
      "image": "assets/teeth.jpeg",
      "title_en": "Teeth",
      "title_es": "Dientes",
      "function_en": "Chew food into smaller pieces for easier digestion.",
      "function_es": "Mastican la comida en trozos más pequeños para facilitar la digestión.",
      "location_en": "Inside the mouth, anchored in the gums.",
      "location_es": "Dentro de la boca, anclados en las encías.",
      "importance_en": "Essential for proper nutrition and clear speech; also a key aspect of facial aesthetics.",
      "importance_es": "Esenciales para una buena nutrición y una pronunciación clara; también son clave en la estética facial."
    },
    {
      // TONGUE
      "image": "assets/tongue.jpeg",
      "title_en": "Tongue",
      "title_es": "Lengua",
      "function_en": "Facilitates taste, aids in chewing, swallowing, and speech.",
      "function_es": "Facilita el gusto y ayuda a masticar, tragar y hablar.",
      "location_en": "Inside the mouth, floor of the oral cavity.",
      "location_es": "Dentro de la boca, en el piso de la cavidad bucal.",
      "importance_en": "Critical for flavor detection, speech articulation, and initiating swallowing.",
      "importance_es": "Crítica para la detección de sabores, la articulación del habla y el inicio de la deglución."
    },
  ];

  void nextLesson() {
    setState(() {
      currentIndex = (currentIndex + 1) % faceLessons.length;
    });
  }

  void speak(String text) async {

    await flutterTts.stop();

    await flutterTts.setLanguage(_isSpanish ? "es-ES" : "en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }


  void _toggleLanguage() {
    setState(() {
      _isSpanish = !_isSpanish;
    });
  }

  @override
  void dispose() {

    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = faceLessons[currentIndex];


    final title = _isSpanish ? lesson["title_es"] : lesson["title_en"];
    final func = _isSpanish ? lesson["function_es"] : lesson["function_en"];
    final loc = _isSpanish ? lesson["location_es"] : lesson["location_en"];
    final imp = _isSpanish ? lesson["importance_es"] : lesson["importance_en"];


    String speakText = "";
    if (func != null && loc != null && imp != null) {
      speakText = "Function: $func\nLocation: $loc\nImportance: $imp";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: Text(title ?? ""),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [

          IconButton(
            icon: Icon(_isSpanish ? Icons.translate : Icons.g_translate),
            onPressed: _toggleLanguage,
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => speak(speakText),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            // Image.
            Image.asset(
              lesson["image"]!,
              height: 200,
            ),
            const SizedBox(height: 20),
            // Title.
            Text(
              title ?? "",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            _buildColorfulBlock(
              icon: Icons.build,
              label: _isSpanish ? "Función" : "Function",
              text: func ?? "",
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
              iconColor: Colors.blueAccent,
            ),

            _buildColorfulBlock(
              icon: Icons.location_on,
              label: _isSpanish ? "Ubicación" : "Location",
              text: loc ?? "",
              backgroundColor: Colors.greenAccent.withOpacity(0.1),
              iconColor: Colors.green,
            ),

            _buildColorfulBlock(
              icon: Icons.warning,
              label: _isSpanish ? "Importancia" : "Importance",
              text: imp ?? "",
              backgroundColor: Colors.yellowAccent.withOpacity(0.1),
              iconColor: Colors.orange,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: nextLesson,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: Text(_isSpanish ? "Siguiente" : "Next"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildColorfulBlock({
    required IconData icon,
    required String label,
    required String text,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$label: $text",
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
