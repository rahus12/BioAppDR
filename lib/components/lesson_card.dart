import 'package:flutter/material.dart';

class LessonCard extends StatelessWidget {
  final String? title;
  final String? slides;
  final String onPress;

  const LessonCard({
    Key? key,
    this.title,
    this.slides,
    required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          width: double.infinity,
          height: 116,
          decoration: BoxDecoration(
            color: Colors.blue, // <-- Blue background
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title ?? "",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              // Slides
              Text(
                "${slides ?? "0"} slides",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 3, 3, 3),
                ),
              ),
              const SizedBox(height: 5),
              // Button row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD166),
                      foregroundColor: Colors.black,
                      fixedSize: const Size(55, 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, onPress);
                    },
                    child: const Text(
                      "Start",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
