import 'package:flutter/material.dart';

class IndexCard extends StatelessWidget {

  String? title = "";
  String? questions;
  String? progress;
  String onPress;

  IndexCard({super.key, this.title, this.questions, this.progress, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // black box container
        const SizedBox(height: 10,),
        Container(
          padding: const EdgeInsets.fromLTRB(20 ,10, 20, 10),
          width: double.infinity,
          height: 116,
          decoration: BoxDecoration(
            color: Colors.black, // Background color
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$title",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                ),
              ),
              Text(
                "$questions Questions",
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7C7C7C)
                ),
              ),
              const SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Progress $progress%",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFFD166)
                    ),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD166),
                          foregroundColor: Colors.black,
                          fixedSize: const Size(55, 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6), // Set the radius here
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5)
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, onPress);
                      },
                      child: const Text("Start", style: TextStyle(
                        fontSize: 16,
                      ),)),
                ],
              ),
            ],
          ),
        ),

      ],
    );
  }
}