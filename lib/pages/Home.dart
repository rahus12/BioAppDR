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
      body: Container(
        color: const Color(0xFFF5F5F5),
        padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for "Hi, Jane" and Profile Picture
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text Column
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
                    Text(
                      "Learn. Play. Grow!",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7C7C7C),
                      ),
                    ),
                  ],
                ),

                // Profile Picture (tap to go to ProfilePage)
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

            // "Explore" text
            const Text(
              "Explore",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),

            // Quiz card
            IndexCard(
              title: "Heart Quiz",
              questions: "13",
              progress: "17",
              onPress: "/question", // Named route for MCQ page
            ),

            // Lesson card
            LessonCard(
              title: "Important parts of the Human Body",
              slides: "6", // Example: 6 slides
              onPress: "/lesson", // Named route for Lesson page
            ),
          ],
        ),
      ),
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
