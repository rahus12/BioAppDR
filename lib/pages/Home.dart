/*
Home page, where the user can select different quizes,
for now lets just do one quiz, and when user clicks he can go to the quiz/mcq page

Need to style the quiz buttons like the Figma design
 */
import 'package:flutter/material.dart';
import 'package:bioappdr/components/indexcard.dart';
import 'package:bioappdr/pages/profile_page.dart';

>>>>>>> Stashed changes
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
        title: Text("BioApp", style: TextStyle(fontWeight: FontWeight.w500),),
        // backgroundColor: Colors.purple[400],
        // foregroundColor: Colors.white,
        flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
              begin: Alignment.topCenter, // Start direction
              end: Alignment.bottomCenter, // End direction
              colors: [
              Color(0xFFE6E1F5), // Start Color
              Color(0xFFF5F5F5),// End Color
              ], // Customize your colors here
              ),
            ),
        ),
      ),
      body: Container(
        color: Color(0xFFF5F5F5),
        padding: EdgeInsets.fromLTRB(40, 20, 40, 0),
        // avatar and title
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi, Jane",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        // letterSpacing is 1% of 36 => 0.36, but you can adjust
                        letterSpacing: 0.36,
                      ),
                    ),
                    Text(
                      "Learn. Play. Grow!",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7C7C7C),
>>>>>>> Stashed changes
                      ),
                    ),
                    Text("Learn. Play. Grow!", style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7C7C7C),

                    ),)
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

            // Quiz index cards
            IndexCard(
              title: "Heart Quiz",
              questions: "13",
              progress: "17",
            ),
            IndexCard(
              title: "Learn lessons? (change the name)",
              questions: "23",
              progress: "0",
              onPress: "/lesson",
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
      backgroundColor: Colors.black, // Background color
      selectedItemColor: Colors.white, // Active item color
      unselectedItemColor: Colors.white, // Inactive item color
      items: [
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

