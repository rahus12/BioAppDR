import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Lesson extends StatefulWidget {
  const Lesson({super.key});

  @override
  State<Lesson> createState() => _LessonState();
}

class _LessonState extends State<Lesson> {
  int currentIndex = 0;
  final FlutterTts flutterTts = FlutterTts();

  // Toggle: false = English, true = Spanish
  bool _isSpanish = false;

  final List<Map<String, String>> lessons = [
    {
      "image": "assets/body.jpg",
      "title_en": "Human Body",
      "title_es": "Cuerpo Humano",
      "description_en":
          "The heart is a powerful organ that pumps blood throughout the body, delivering oxygen and nutrients to cells. It beats about 100,000 times a day and is about the size of your fist!",
      "description_es":
          "El corazón es un órgano poderoso que bombea sangre a todo el cuerpo, suministrando oxígeno y nutrientes a las células. ¡Late alrededor de 100,000 veces al día y es del tamaño de tu puño!"
    },
    {
      "image": "assets/heart.jpeg",
      "title_en": "Heart",
      "title_es": "Corazón",
      "function_en":
          "Pumps blood, delivering oxygen and nutrients to the body while removing waste products.",
      "function_es":
          "Bombea sangre, entregando oxígeno y nutrientes al cuerpo mientras elimina desechos.",
      "location_en": "Center of the chest.",
      "location_es": "Centro del pecho.",
      "importance_en":
          "Essential for circulation; without it, life cannot be sustained",
      "importance_es":
          "Esencial para la circulación; sin él, la vida no puede sostenerse"
    },
    {
      "image": "assets/lungs.jpeg",
      "title_en": "Lungs",
      "title_es": "Pulmones",
      "function_en":
          "Facilitate the exchange of oxygen and carbon dioxide between the air and blood.",
      "function_es":
          "Facilitan el intercambio de oxígeno y dióxido de carbono entre el aire y la sangre.",
      "location_en": "On either side of the chest.",
      "location_es": "A cada lado del pecho.",
      "importance_en": "Vital for breathing and oxygen supply to tissues",
      "importance_es":
          "Vitales para la respiración y el suministro de oxígeno a los tejidos"
    },
    {
      "image": "assets/brain.jpg",
      "title_en": "Brain",
      "title_es": "Cerebro",
      "function_en":
          "Controls all bodily functions, thoughts, emotions, and memory.",
      "function_es":
          "Controla todas las funciones corporales, pensamientos, emociones y memoria.",
      "location_en": "Inside the skull",
      "location_es": "Dentro del cráneo.",
      "importance_en":
          "Acts as the control center of the body; damage can severely impair or end life",
      "importance_es":
          "Actúa como el centro de control del cuerpo; su daño puede perjudicar gravemente o terminar la vida"
    },
    {
      "image": "assets/stomach.jpeg",
      "title_en": "Stomach",
      "title_es": "Estómago",
      "function_en": "Food storage, mixing, and initial digestion",
      "function_es":
          "Almacena, mezcla e inicia la digestión de los alimentos.",
      "location_en": "Center of the body.",
      "location_es": "Centro del cuerpo.",
      "importance_en":
          "Essential for digestion; without it, life cannot be sustained",
      "importance_es":
          "Esencial para la digestión; sin él, la vida no puede sostenerse"
    },
    {
      "image": "assets/liver.jpeg",
      "title_en": "Liver",
      "title_es": "Hígado",
      "function_en":
          "Filters toxins from blood, produces bile for digestion, regulates blood sugar, and synthesizes proteins.",
      "function_es":
          "Filtra toxinas de la sangre, produce bilis para la digestión, regula el azúcar en la sangre y sintetiza proteínas.",
      "location_en": "Upper right abdomen.",
      "location_es": "Parte superior derecha del abdomen.",
      "importance_en":
          "Performs over 500 essential functions; damage can lead to severe health issues",
      "importance_es":
          "Realiza más de 500 funciones esenciales; su daño puede causar graves problemas de salud"
    },
    {
      "image": "assets/kidney.jpeg",
      "title_en": "Kidneys",
      "title_es": "Riñones",
      "function_en":
          "Filter blood to remove waste and excess fluids, producing urine.",
      "function_es":
          "Filtran la sangre para eliminar desechos y exceso de fluidos, produciendo orina.",
      "location_en": "Center of the chest.",
      "location_es": "Centro del pecho.",
      "importance_en":
          "Maintain fluid balance and remove toxins; failure requires medical intervention like dialysis",
      "importance_es":
          "Mantienen el equilibrio de líquidos y eliminan toxinas; su falla requiere intervención médica como la diálisis"
    },
    {
      "image": "assets/bone.jpeg",
      "title_en": "Bones",
      "title_es": "Huesos",
      "function_en":
          "Provide structure, support, and protection for the body",
      "function_es":
          "Brindan estructura, soporte y protección para el cuerpo.",
      "location_en": "Everywhere",
      "location_es": "En todas partes.",
      "importance_en":
          "Essential for support; without it, life cannot be sustained",
      "importance_es":
          "Esenciales para el soporte; sin ellos, la vida no puede sostenerse"
    },
  ];

  void nextLesson() {
    setState(() {
      currentIndex = (currentIndex + 1) % lessons.length;
    });
  }

  void _toggleLanguage() {
    setState(() {
      _isSpanish = !_isSpanish;
    });
  }

  void speak(String text) async {
    // Use Spanish or English TTS
    await flutterTts.setLanguage(_isSpanish ? "es-ES" : "en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final lesson = lessons[currentIndex];

    // Decide which title to display
    final String title = _isSpanish
        ? (lesson["title_es"] ?? lesson["title_en"] ?? "")
        : (lesson["title_en"] ?? "");

    // Check if we have function-based fields
    final bool hasFunctionBlock = lesson.containsKey("function_en") ||
        lesson.containsKey("function_es");

    // Prepare text for TTS
    String speakText;
    if (hasFunctionBlock) {
      // Safely retrieve each field, fallback to "" if missing
      final String func = _isSpanish
          ? (lesson["function_es"] ?? lesson["function_en"] ?? "")
          : (lesson["function_en"] ?? "");
      final String loc = _isSpanish
          ? (lesson["location_es"] ?? lesson["location_en"] ?? "")
          : (lesson["location_en"] ?? "");
      final String imp = _isSpanish
          ? (lesson["importance_es"] ?? lesson["importance_en"] ?? "")
          : (lesson["importance_en"] ?? "");
      speakText = "Function: $func\nLocation: $loc\nImportance: $imp";
    } else {
      // Single description-based item
      final String desc = _isSpanish
          ? (lesson["description_es"] ?? lesson["description_en"] ?? "")
          : (lesson["description_en"] ?? "");
      speakText = desc;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.purple,
        actions: [
          // Language toggle icon
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
            // Image
            Image.asset(
              lesson["image"] ?? "",
              height: 200,
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            if (hasFunctionBlock) ...[
              _buildColorfulBlock(
                icon: Icons.build,
                label: _isSpanish ? "Función" : "Function",
                text: _isSpanish
                    ? (lesson["function_es"] ?? lesson["function_en"] ?? "")
                    : (lesson["function_en"] ?? ""),
                backgroundColor: Colors.blueAccent.withOpacity(0.1),
                iconColor: Colors.blueAccent,
              ),
              _buildColorfulBlock(
                icon: Icons.location_on,
                label: _isSpanish ? "Ubicación" : "Location",
                text: _isSpanish
                    ? (lesson["location_es"] ?? lesson["location_en"] ?? "")
                    : (lesson["location_en"] ?? ""),
                backgroundColor: Colors.greenAccent.withOpacity(0.1),
                iconColor: Colors.green,
              ),
              _buildColorfulBlock(
                icon: Icons.warning,
                label: _isSpanish ? "Importancia" : "Importance",
                text: _isSpanish
                    ? (lesson["importance_es"] ?? lesson["importance_en"] ?? "")
                    : (lesson["importance_en"] ?? ""),
                backgroundColor: Colors.yellowAccent.withOpacity(0.1),
                iconColor: Colors.orange,
              ),
            ] else ...[
              _buildColorfulBlock(
                icon: Icons.info,
                label: _isSpanish ? "Descripción" : "Description",
                text: _isSpanish
                    ? (lesson["description_es"] ?? lesson["description_en"] ?? "")
                    : (lesson["description_en"] ?? ""),
                backgroundColor: Colors.tealAccent.withOpacity(0.1),
                iconColor: Colors.teal,
              ),
            ],
            const SizedBox(height: 30),

            // Next Button
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
