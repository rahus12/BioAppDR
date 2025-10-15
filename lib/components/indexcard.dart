import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class IndexCard extends StatelessWidget {
  final String? title;
  final String? questions;
  final String? progress;
  final String onPress;

  const IndexCard({
    Key? key,
    this.title,
    this.questions,
    this.progress,
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "$title",
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Sunshine',
                      ),
                    ),
                  ),
                  Icon(Icons.sports_esports, color: Colors.orange.shade800, size: 28),
                ],
              ),
              Text(
                "$questions Questions",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7C7C7C),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Progress $progress%",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange.shade800, // Changed for contrast
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.orange.shade300, // Restoring original color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      shadowColor: Colors.orange.withOpacity(0.5),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, onPress);
                    },
                    icon: const Icon(Icons.rocket_launch, size: 18),
                    label: const Text(
                      "Play!",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ).animate().fadeIn(delay: 300.ms).scale(duration: 500.ms, begin: const Offset(0.8, 0.8)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
