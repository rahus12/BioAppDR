import 'package:flutter/material.dart';

class DragDropQuizPage extends StatefulWidget {
  const DragDropQuizPage({Key? key}) : super(key: key);

  @override
  State<DragDropQuizPage> createState() => _DragDropQuizPageState();
}

class _DragDropQuizPageState extends State<DragDropQuizPage> {
  // Track if the user has successfully matched the image
  bool isMatched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Heart Drag & Drop"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Column(
              children: [
                // Instructions
                const Text(
                  "Drag the heart image onto the Spanish word:\n\nEl corazón",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 40),

                // Draggable + DragTarget row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Draggable image of the heart
                    Draggable<String>(
                      data: "El corazón",
                      feedback: Material(
                        color: Colors.transparent,
                        child: Image.asset(
                          'assets/images/heart.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: Image.asset(
                          'assets/images/heart.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/heart.png',
                        width: 100,
                        height: 100,
                      ),
                    ),

                    // DragTarget expecting "El corazón"
                    DragTarget<String>(
                      onAccept: (data) {
                        if (data == "El corazón") {
                          setState(() {
                            isMatched = true;
                          });
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          width: 140,
                          height: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent, width: 2),
                            borderRadius: BorderRadius.circular(12),
                            color: isMatched
                                ? Colors.green.withOpacity(0.2)
                                : Colors.white,
                          ),
                          child: Text(
                            isMatched ? "Matched: El corazón" : "El corazón",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: isMatched ? Colors.green[800] : Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Show a success message if matched
                if (isMatched)
                  const Text(
                    "¡Excelente!\nYou matched the heart image with \"El corazón\".",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
