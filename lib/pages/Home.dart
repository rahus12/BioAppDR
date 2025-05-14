import 'package:flutter/material.dart';
import 'package:bioappdr/components/indexcard.dart';
import 'package:bioappdr/components/lesson_card.dart';
import 'package:bioappdr/pages/profile_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient AppBar
      appBar: AppBar(
        title: const Text(
          "BioApp",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE6E1F5),
                Color(0xFFF5F5F5),
              ],
            ),
          ),
        ),
      ),
      // Main content
      body: SingleChildScrollView(
        // Ensures the screen is scrollable if content is large
        child: Container(
          color: const Color(0xFFF5F5F5),
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting + Profile Picture
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Greeting Text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Hi, Jane",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.36,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Learn. Play. Grow!",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7C7C7C),
                        ),
                      ),
                    ],
                  ),

                  // Profile Picture
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(
                            name: "Jane",
                            surname: "Doe",
                            phoneNumber: "123-456-7890",
                          ),
                        ),
                      );
                    },
                    child: const CircleAvatar(
                      backgroundImage: AssetImage('assets/chunli.jpg'),
                      radius: 40,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // "Explore" heading
              const Text(
                "Explore",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(
                thickness: 2,
                color: Colors.black12,
                height: 30,
              ),

              // QUIZ CARD
              IndexCard(
                title: "Human Body Quiz",
                questions: "13",
                progress: "17",
                onPress: "/question", // Named route for MCQ page
              ),
              const SizedBox(height: 16),
              IndexCard(
                title: "Organ Word Scramble",
                questions: "5", // number of words to scramble
                progress: "0",  // your desired progress (or logic to track it)
                onPress: "/wordscramble",
              ),
              IndexCard(
                title: "Memory Game",
                questions: "8", // e.g., 8 total cards or 4 pairs
                progress: "0",
                onPress: "/memorygame",
              ),
              IndexCard(
                title: "Drag drop Quiz",
                questions: "7",
                progress: "69",
                onPress: "/dragdrop", // Named route for MCQ page
              ),
              const SizedBox(height: 16),
              IndexCard(
                title: "Game",
                questions: "7",
                progress: "90",
                onPress: "/facequizgame", // Named route for MCQ page
              ),
              const SizedBox(height: 16),
              IndexCard(
                title: "Body Parts Connections Game",
                questions: "7",
                progress: "90",
                onPress: "/bodypartsconnections", // Named route for MCQ page
              ),
              const SizedBox(height: 16),

              IndexCard(
                title: "Body Parts Assembly",
                questions: "6", // Number of body parts to place
                progress: "0",  // Start at 0 progress
                onPress: "/bodyassembly", // Named route for the new game
              ),
              const SizedBox(height: 16),

              // LESSON CARDS
              LessonCard(
                title: "Important parts of the Human Body",
                slides: "6", // Example: 6 slides
                onPress: "/lesson", // Named route for Lesson page
              ),
              const SizedBox(height: 16),

              LessonCard(
                title: "Important parts of the Face",
                slides: "6",
                onPress: "/facelesson", // Named route for Face lesson page
              ),
              const SizedBox(height: 40),

              LessonCard(
                title: "Speech to learning",
                slides: "6",
                onPress: "/learningpage", // Named route for Face lesson page
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      // Bottom Nav
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
