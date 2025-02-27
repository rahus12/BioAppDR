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
      "image": "assets/heart.jpg",
      "image2": "assets/blood.jpg",
      "title": "Heart",
      "description": "The heart is a powerful organ that pumps blood throughout the body, delivering oxygen and nutrients to cells. It beats about 100,000 times a day and is about the size of your fist!"
    },
    {
      "image": "assets/lung.jpg",
      "image2": "assets/oxygen.jpg",
      "title": "Lungs",
      "description": "The lungs help us breathe by taking in oxygen and releasing carbon dioxide. They are spongy organs that work with the heart to send oxygen-rich blood throughout the body."
    },
    {
      "image": "assets/brain.jpg",
      "image2": "assets/nerves.jpg",
      "title": "Brain",
      "description": "The brain is the control center of the body, managing movement, thoughts, emotions, and memories. It has about 86 billion neurons that send and receive messages rapidly!"
    },
    {
      "image": "assets/stomach.jpg",
      "image2": "assets/digestion.jpg",
      "title": "Stomach",
      "description": "The stomach helps break down food using acids and enzymes, turning it into energy. It churns food before passing it to the intestines for further digestion."
    },
    {
      "image": "assets/bone.jpg",
      "image2": "assets/skeleton.jpg",
      "title": "Bones",
      "description": "Bones provide structure to our body and protect vital organs. The human body has 206 bones, which also store minerals like calcium to keep them strong."
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
    return Scaffold(
      appBar: AppBar(
        title: Text(lessons[currentIndex]["title"]!),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Translation feature coming soon!")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => speak(lessons[currentIndex]["description"]!),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // First Image
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Image.asset(lessons[currentIndex]["image"]!, height: 200),
            ),

            // Second Image
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Image.asset(lessons[currentIndex]["image2"]!, height: 200),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                lessons[currentIndex]["title"]!,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                lessons[currentIndex]["description"]!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 30),

            // Next Button
            ElevatedButton(
              onPressed: nextLesson,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text("Next"),
            ),

            const SizedBox(height: 20), // Extra space at the bottom
          ],
        ),
      ),
    );
  }
}
