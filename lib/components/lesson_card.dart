import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title ?? "",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Sunshine',
                      ),
                    ),
                  ),
                  Icon(Icons.menu_book, color: Colors.blue.shade800, size: 28),
                ],
              ),
              // Slides
              Text(
                "${slides ?? "0"} slides",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7C7C7C),
                ),
              ),
              const SizedBox(height: 5),
              // Button row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, onPress);
                    },
                    icon: const Icon(Icons.lightbulb_outline, size: 18),
                    label: const Text(
                      "Learn!",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
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
