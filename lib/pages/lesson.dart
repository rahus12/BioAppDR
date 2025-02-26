import 'package:flutter/material.dart';

class Lesson extends StatefulWidget {
  const Lesson({super.key});

  @override
  State<Lesson> createState() => _LessonState();
}

class _LessonState extends State<Lesson> {
  int currentIndex = 0;

  final List<Map<String, String>> lessons = [
    {
      "image": "assets/heart.jpg",
      "title": "Heart",
      "description": "The heart pumps blood to all parts of the body."
    },
    {
      "image": "assets/lung.jpg",
      "title": "Lungs",
      "description": "Lungs help us breathe by taking in oxygen and releasing carbon dioxide."
    },
    {
      "image": "assets/bone.jpg",
      "title": "Bones",
      "description": "Bones give structure to our body and protect our organs."
    },
  ];

  void nextLesson() {
    setState(() {
      currentIndex = (currentIndex + 1) % lessons.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lesson"),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(lessons[currentIndex]["image"]!, height: 250),
            const SizedBox(height: 20),
            Text(
              lessons[currentIndex]["title"]!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                lessons[currentIndex]["description"]!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: nextLesson,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
