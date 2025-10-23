import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart'; // Needed for kIsWeb

class Lesson extends StatefulWidget {
  const Lesson({super.key});

  @override
  State<Lesson> createState() => _LessonState();
}

class _LessonState extends State<Lesson> {
  int currentIndex = 0;
  final FlutterTts flutterTts = FlutterTts();
  bool _isSpanish = false;

  final List<Map<String, String>> lessons = [
    {
      "image": "assets/internal-organs.jpg",
      "title_en": "Human Body",
      "title_es": "Cuerpo Humano",
      "description_en":
      "The human body is a complex and amazing system of organs and structures working together to sustain life. Let's explore some of its key components!",
      "description_es":
      "¡El cuerpo humano es un sistema complejo y asombroso de órganos y estructuras que trabajan juntos para mantener la vida. ¡Exploremos algunos de sus componentes clave!"
    },
    {
      "image": "assets/Heart.gif",
      "title_en": "Heart",
      "title_es": "Corazón",
      "function_en":
      "Pumps blood, delivering oxygen and nutrients to the body while removing waste products.",
      "function_es":
      "Bombea sangre, entregando oxígeno y nutrientes al cuerpo mientras elimina desechos.",
      "location_en": "Center of the chest, slightly to the left.",
      "location_es": "Centro del pecho, ligeramente a la izquierda.",
      "importance_en":
      "Essential for circulation; without it, life cannot be sustained.",
      "importance_es":
      "Esencial para la circulación; sin él, la vida no puede sostenerse."
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
      "importance_en": "Vital for breathing and oxygen supply to tissues.",
      "importance_es":
      "Vitales para la respiración y el suministro de oxígeno a los tejidos."
    },
    {
      "image": "assets/brain.gif",
      "title_en": "Brain",
      "title_es": "Cerebro",
      "function_en":
      "Controls all bodily functions, thoughts, emotions, and memory.",
      "function_es":
      "Controla todas las funciones corporales, pensamientos, emociones y memoria.",
      "location_en": "Inside the skull.",
      "location_es": "Dentro del cráneo.",
      "importance_en":
      "Acts as the control center of the body; damage can severely impair or end life.",
      "importance_es":
      "Actúa como el centro de control del cuerpo; su daño puede perjudicar gravemente o terminar la vida."
    },
    {
      "image": "assets/stomach.jpeg",
      "title_en": "Stomach",
      "title_es": "Estómago",
      "function_en": "Food storage, mixing, and initial digestion.",
      "function_es":
      "Almacena, mezcla e inicia la digestión de los alimentos.",
      "location_en": "Upper abdomen, between the esophagus and small intestine.",
      "location_es": "Abdomen superior, entre el esófago y el intestino delgado.",
      "importance_en":
      "Breaks down food into a usable form for the body.",
      "importance_es":
      "Descompone los alimentos en una forma utilizable para el cuerpo."
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
      "Performs over 500 essential functions; damage can lead to severe health issues.",
      "importance_es":
      "Realiza más de 500 funciones esenciales; su daño puede causar graves problemas de salud."
    },
    {
      "image": "assets/kidney.jpeg",
      "title_en": "Kidneys",
      "title_es": "Riñones",
      "function_en":
      "Filter blood to remove waste and excess fluids, producing urine.",
      "function_es":
      "Filtran la sangre para eliminar desechos y exceso de fluidos, produciendo orina.",
      "location_en": "Lower back, on each side of the spine.",
      "location_es": "Parte baja de la espalda, a cada lado de la columna.",
      "importance_en":
      "Maintain fluid balance and remove toxins; failure requires medical intervention like dialysis.",
      "importance_es":
      "Mantienen el equilibrio de líquidos y eliminan toxinas; su falla requiere intervención médica como la diálisis."
    },
    {
      "image": "assets/bones.gif",
      "title_en": "Bones",
      "title_es": "Huesos",
      "function_en":
      "Provide structure, support, and protection for the body.",
      "function_es":
      "Brindan estructura, soporte y protección para el cuerpo.",
      "location_en": "Throughout the body.",
      "location_es": "En todo el cuerpo.",
      "importance_en":
      "Form the skeleton, which allows movement and protects vital organs.",
      "importance_es":
      "Forman el esqueleto, que permite el movimiento y protege los órganos vitales."
    },
  ];

  @override
  void initState() {
    super.initState();
    flutterTts.setSpeechRate(0.5);
    flutterTts.setVolume(1.0);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

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
    await flutterTts.stop();
    await flutterTts.setLanguage(_isSpanish ? "es-ES" : "en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final lesson = lessons[currentIndex];
    final String title = _isSpanish ? (lesson["title_es"] ?? "") : (lesson["title_en"] ?? "");
    final bool hasFunctionBlock = lesson.containsKey("function_en");

    String speakText;
    if (hasFunctionBlock) {
      final String func = _isSpanish ? (lesson["function_es"] ?? "") : (lesson["function_en"] ?? "");
      final String loc = _isSpanish ? (lesson["location_es"] ?? "") : (lesson["location_en"] ?? "");
      final String imp = _isSpanish ? (lesson["importance_es"] ?? "") : (lesson["importance_en"] ?? "");
      speakText = "Function: $func. Location: $loc. Importance: $imp";
    } else {
      final String desc = _isSpanish ? (lesson["description_es"] ?? "") : (lesson["description_en"] ?? "");
      speakText = desc;
    }

    return Scaffold(
      // The background color is inherited from the global theme's scaffoldBackgroundColor
      appBar: AppBar(
        title: Text(title),
        // No hardcoded colors; it correctly uses the theme's AppBar color
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
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            // Landscape layout
            return Padding(
              padding: const EdgeInsets.all(40.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.asset(lesson["image"] ?? "", height: 400, fit: BoxFit.cover),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          if (hasFunctionBlock) ...[
                            _buildColorfulBlock(
                              icon: Icons.functions,
                              label: _isSpanish ? "Función" : "Function",
                              text: _isSpanish ? (lesson["function_es"] ?? "") : (lesson["function_en"] ?? ""),
                              // Use theme colors
                              backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
                              iconColor: colorScheme.primary,
                            ),
                            _buildColorfulBlock(
                              icon: Icons.location_on,
                              label: _isSpanish ? "Ubicación" : "Location",
                              text: _isSpanish ? (lesson["location_es"] ?? "") : (lesson["location_en"] ?? ""),
                              // Use theme colors
                              backgroundColor: colorScheme.secondaryContainer.withOpacity(0.5),
                              iconColor: colorScheme.secondary,
                            ),
                            _buildColorfulBlock(
                              icon: Icons.star,
                              label: _isSpanish ? "Importancia" : "Importance",
                              text: _isSpanish ? (lesson["importance_es"] ?? "") : (lesson["importance_en"] ?? ""),
                              // Use theme colors
                              backgroundColor: colorScheme.tertiaryContainer.withOpacity(0.5),
                              iconColor: colorScheme.tertiary,
                            ),
                          ] else ...[
                            _buildColorfulBlock(
                              icon: Icons.info_outline,
                              label: _isSpanish ? "Descripción" : "Description",
                              text: _isSpanish ? (lesson["description_es"] ?? "") : (lesson["description_en"] ?? ""),
                              // Use theme colors
                              backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
                              iconColor: colorScheme.primary,
                            ),
                          ],
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(_isSpanish ? "Siguiente" : "Next"),
                            onPressed: nextLesson,
                            // The style is inherited from the global theme's ElevatedButtonTheme
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              textStyle: theme.textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Portrait layout
            return SingleChildScrollView(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.asset(lesson["image"] ?? "", height: 400, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (hasFunctionBlock) ...[
                    _buildColorfulBlock(
                      icon: Icons.functions,
                      label: _isSpanish ? "Función" : "Function",
                      text: _isSpanish ? (lesson["function_es"] ?? "") : (lesson["function_en"] ?? ""),
                      // Use theme colors
                      backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
                      iconColor: colorScheme.primary,
                    ),
                    _buildColorfulBlock(
                      icon: Icons.location_on,
                      label: _isSpanish ? "Ubicación" : "Location",
                      text: _isSpanish ? (lesson["location_es"] ?? "") : (lesson["location_en"] ?? ""),
                      // Use theme colors
                      backgroundColor: colorScheme.secondaryContainer.withOpacity(0.5),
                      iconColor: colorScheme.secondary,
                    ),
                    _buildColorfulBlock(
                      icon: Icons.star,
                      label: _isSpanish ? "Importancia" : "Importance",
                      text: _isSpanish ? (lesson["importance_es"] ?? "") : (lesson["importance_en"] ?? ""),
                      // Use theme colors
                      backgroundColor: colorScheme.tertiaryContainer.withOpacity(0.5),
                      iconColor: colorScheme.tertiary,
                    ),
                  ] else ...[
                    _buildColorfulBlock(
                      icon: Icons.info_outline,
                      label: _isSpanish ? "Descripción" : "Description",
                      text: _isSpanish ? (lesson["description_es"] ?? "") : (lesson["description_en"] ?? ""),
                      // Use theme colors
                      backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
                      iconColor: colorScheme.primary,
                    ),
                  ],
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(_isSpanish ? "Siguiente" : "Next"),
                    onPressed: nextLesson,
                    // The style is inherited from the global theme's ElevatedButtonTheme
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // This widget now builds using colors passed from the build method
  Widget _buildColorfulBlock({
    required IconData icon,
    required String label,
    required String text,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
