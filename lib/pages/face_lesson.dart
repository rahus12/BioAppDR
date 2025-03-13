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

  final List<Map<String, String>> faceLessons = [
    {
      "image": "assets/eyes.jpg",
      "title": "Eyes",
      "function": "Allow vision, interpret light and color, provide sense of sight.",
      "location": "Front of the face, within the eye sockets.",
      "importance": "Essential for visual perception; many daily tasks rely on sight."
    },
    {
      "image": "assets/ears.jpg",
      "title": "Ears",
      "function": "Capture sound waves, enabling hearing and balance.",
      "location": "On either side of the head.",
      "importance": "Vital for communication and spatial awareness; helps maintain balance."
    },
    {
      "image": "assets/nose.jpg",
      "title": "Nose",
      "function": "Filters, warms, and moistens air; provides sense of smell.",
      "location": "Center of the face, above the mouth.",
      "importance": "Crucial for breathing, smell, and flavor perception."
    },
    {
      "image": "assets/mouth.jpg",
      "title": "Mouth",
      "function": "Ingests food, initiates digestion, enables speech.",
      "location": "Lower center of the face.",
      "importance": "Key for eating, communication, and facial expressions."
    },
    {
      "image": "assets/teeth.jpg",
      "title": "Teeth",
      "function": "Chew food into smaller pieces for easier digestion.",
      "location": "Inside the mouth, anchored in the gums.",
      "importance": "Essential for proper nutrition and clear speech; also a key aspect of facial aesthetics."
    },
    {
      "image": "assets/tongue.jpg",
      "title": "Tongue",
      "function": "Facilitates taste, aids in chewing, swallowing, and speech.",
      "location": "Inside the mouth, floor of the oral cavity.",
      "importance": "Critical for flavor detection, speech articulation, and initiating swallowing."
    },
  ];

  void nextLesson() {
    setState(() {
      currentIndex = (currentIndex + 1) % faceLessons.length;
    });
  }

  void speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final lesson = faceLessons[currentIndex];

    String speakText = "";
    if (lesson.containsKey("function")) {
      speakText = "Function: ${lesson["function"]}\n"
          "Location: ${lesson["location"]}\n"
          "Importance: ${lesson["importance"]}";
    } else if (lesson.containsKey("description")) {
      speakText = lesson["description"]!;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson["title"]!),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Translation feature coming soon!"),
                ),
              );
            },
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
              lesson["image"]!,
              height: 200,
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              lesson["title"]!,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            if (lesson.containsKey("function")) ...[
              _buildColorfulBlock(
                icon: Icons.build,
                label: "Function",
                text: lesson["function"]!,
                backgroundColor: Colors.blueAccent.withOpacity(0.1),
                iconColor: Colors.blueAccent,
              ),
              _buildColorfulBlock(
                icon: Icons.location_on,
                label: "Location",
                text: lesson["location"]!,
                backgroundColor: Colors.greenAccent.withOpacity(0.1),
                iconColor: Colors.green,
              ),
              _buildColorfulBlock(
                icon: Icons.warning,
                label: "Importance",
                text: lesson["importance"]!,
                backgroundColor: Colors.yellowAccent.withOpacity(0.1),
                iconColor: Colors.orange,
              ),
            ] else if (lesson.containsKey("description")) ...[
              _buildColorfulBlock(
                icon: Icons.info,
                label: "Description",
                text: lesson["description"]!,
                backgroundColor: Colors.tealAccent.withOpacity(0.1),
                iconColor: Colors.teal,
              ),
            ],

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
              child: const Text("Next"),
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
