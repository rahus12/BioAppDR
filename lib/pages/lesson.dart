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

  final List<Map<String, String>> lessons = [
    {
      "image": "assets/body.jpg",
      "title": "Human Body",
      "description":
          "The heart is a powerful organ that pumps blood throughout the body, delivering oxygen and nutrients to cells. It beats about 100,000 times a day and is about the size of your fist!"
    },
    {
      "image": "assets/heart.jpg",
      "title": "Heart",
      "function": "Pumps blood, delivering oxygen and nutrients to the body while removing waste products.",
      "location": "Center of the chest.",
      "importance": "Essential for circulation; without it, life cannot be sustained"
    },
    {
      "image": "assets/lung.jpg",
      "title": "Lungs",
      "function": "Facilitate the exchange of oxygen and carbon dioxide between the air and blood.",
      "location": "On either side of the chest.",
      "importance": "Vital for breathing and oxygen supply to tissues"
    },
    {
      "image": "assets/brain.jpg",
      "title": "Brain",
      "function": "Controls all bodily functions, thoughts, emotions, and memory.",
      "location": "Inside the skull",
      "importance": "Acts as the control center of the body; damage can severely impair or end life"
    },
    {
      "image": "assets/stomach.jpeg",
      "title": "Stomach",
      "function": "Food storage, mixing, and initial digestion",
      "location": "Center of the body.",
      "importance": "Essential for digestion; without it, life cannot be sustained"
    },
    {
      "image": "assets/liver.jpeg",
      "title": "Liver",
      "function": "Filters toxins from blood, produces bile for digestion, regulates blood sugar, and synthesizes proteins.",
      "location": "Upper right abdomen.",
      "importance": "Performs over 500 essential functions; damage can lead to severe health issues"
    },
    {
      "image": "assets/kidney.jpeg",
      "title": "Kidneys",
      "function": "Filter blood to remove waste and excess fluids, producing urine.",
      "location": "Center of the chest.",
      "importance": "Maintain fluid balance and remove toxins; failure requires medical intervention like dialysis"
    },
    {
      "image": "assets/bone.jpg",
      "title": "Bones",
      "function": "Provide structure, support, and protection for the body",
      "location": "Everywhere",
      "importance": "Essential for support; without it, life cannot be sustained"
    },
  ];

  void nextLesson() {
    setState(() {
      currentIndex = (currentIndex + 1) % lessons.length;
    });
  }

  void speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final lesson = lessons[currentIndex];

    // Prepare text to be spoken:
    String speakText;
    if (lesson.containsKey("function")) {
      speakText = "Function: ${lesson["function"]}\n"
          "Location: ${lesson["location"]}\n"
          "Importance: ${lesson["importance"]}";
    } else {
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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

              // If function, location, importance are present, show them in separate color blocks
              // Otherwise, show the description in a single block
              if (lesson.containsKey("function")) ...[
                _buildColorBlock(
                  label: "Function",
                  content: lesson["function"]!,
                  color: Colors.blue[50]!,
                ),
                _buildColorBlock(
                  label: "Location",
                  content: lesson["location"]!,
                  color: Colors.green[50]!,
                ),
                _buildColorBlock(
                  label: "Importance",
                  content: lesson["importance"]!,
                  color: Colors.orange[50]!,
                ),
              ] else ...[
                _buildColorBlock(
                  label: "Description",
                  content: lesson["description"]!,
                  color: Colors.blueGrey[50]!,
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
                child: const Text("Next"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // A helper widget that displays a label and content in a colorful block
  Widget _buildColorBlock({
    required String label,
    required String content,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$label: $content",
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
    );
  }
}
