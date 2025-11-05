
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LivingNonLivingLesson extends StatefulWidget {
  const LivingNonLivingLesson({super.key});

  @override
  State<LivingNonLivingLesson> createState() => _LivingNonLivingLessonState();
}

class _LivingNonLivingLessonState extends State<LivingNonLivingLesson> {
  int currentIndex = 0;
  final FlutterTts flutterTts = FlutterTts();
  bool _isSpanish = false;

  final List<Map<String, String>> lessons = [
    {
      "image": "assets/living-things.gif",
      "title_en": "Living Things",
      "title_es": "Seres Vivos",
      "description_en": "Living things grow, eat, breathe, and have babies. Can you think of a living thing?",
      "description_es": "Los seres vivos crecen, comen, respiran y tienen bebés. ¿Puedes pensar en un ser vivo?"
    },
    {
      "image": "assets/tv.gif",
      "title_en": "Non-Living Things",
      "title_es": "Cosas No Vivas",
      "description_en": "Non-living things do not grow, eat, or breathe. They are not alive. Can you think of a non-living thing?",
      "description_es": "Las cosas no vivas no crecen, no comen ni respiran. No están vivas. ¿Puedes pensar en una cosa no viva?"
    },
    {
      "image": "assets/sunflower-plant.gif",
      "title_en": "Plants are Living Things",
      "title_es": "Las Plantas son Seres Vivos",
      "description_en": "Plants are alive! They need sunlight, water, and air to grow. They make their own food.",
      "description_es": "¡Las plantas están vivas! Necesitan luz solar, agua y aire para crecer. Hacen su propia comida."
    },
    {
      "image": "assets/rock.gif",
      "title_en": "Is a Rock a Living Thing?",
      "title_es": "¿Es una Roca un Ser Vivo?",
      "description_en": "A rock is a non-living thing. It does not grow, eat, or breathe. It can be very old, but it is not alive.",
      "description_es": "Una roca es una cosa no viva. No crece, no come ni respira. Puede ser muy antigua, pero no está viva."
    },
    {
      "image": "assets/Robot.gif",
      "title_en": "Is a Robot a Living Thing?",
      "title_es": "¿Es un Robot un Ser Vivo?",
      "description_en": "Robots can move and talk, but they are not alive. They are made in a factory and cannot grow or have babies.",
      "description_es": "Los robots pueden moverse y hablar, pero no están vivos. Se fabrican en una fábrica y no pueden crecer ni tener bebés."
    }

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final lesson = lessons[currentIndex];
    final String title = _isSpanish ? (lesson["title_es"] ?? "") : (lesson["title_en"] ?? "");
    final String description = _isSpanish ? (lesson["description_es"] ?? "") : (lesson["description_en"] ?? "");

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(_isSpanish ? Icons.translate : Icons.g_translate),
            onPressed: _toggleLanguage,
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => speak(description),
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
                          const SizedBox(height: 50,),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.asset(lesson["image"] ?? "", height: 450, fit: BoxFit.cover),
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
                            style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colorScheme.primary.withOpacity(0.5)),
                            ),
                            child: Text(
                              description,
                              style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 2.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(_isSpanish ? "Siguiente" : "Next"),
                            onPressed: nextLesson,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              textStyle: theme.textTheme.titleLarge,
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
                  const SizedBox(height: 100),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.asset(lesson["image"] ?? "", height: 450, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.primary.withOpacity(0.5)),
                    ),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 2.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(_isSpanish ? "Siguiente" : "Next"),
                    onPressed: nextLesson,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: theme.textTheme.titleLarge,
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
}
