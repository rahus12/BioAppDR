import 'package:flutter/material.dart';
import 'package:bioappdr/components/indexcard.dart';
import 'package:bioappdr/components/lesson_card.dart';
import 'package:bioappdr/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();

  // Static method to refresh home data from other pages
  static void refreshHomeData() {
    _HomeState.refreshHomeData();
  }
}

class _HomeState extends State<Home> {
  int _totalScore = 0;
  Map<String, int> _quizProgress = {};
  static _HomeState? _instance;

  @override
  void initState() {
    super.initState();
    _instance = this;
    _loadTotalScore();
    _loadQuizProgress();
  }

  @override
  void dispose() {
    _instance = null;
    super.dispose();
  }

  static void refreshHomeData() {
    _instance?._refreshData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data whenever the page becomes visible
    _refreshData();
  }

  Future<void> _loadTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalScore = prefs.getDouble('totalScore')?.round() ?? 0;
    });
  }

  Future<void> _loadQuizProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _quizProgress = {
        'mcq_progress': prefs.getInt('mcq_progress') ?? 0,
        'wordscramble_progress': prefs.getInt('wordscramble_progress') ?? 0,
        'memory_progress': prefs.getInt('memory_progress') ?? 0,
        'dragdrop_progress': prefs.getInt('dragdrop_progress') ?? 0,
        'facequiz_progress': prefs.getInt('facequiz_progress') ?? 0,
        'connections_progress': prefs.getInt('connections_progress') ?? 0,
        'assembly_progress': prefs.getInt('assembly_progress') ?? 0,
      };
    });
  }

  int _calculateProgress(int completed, int total) {
    if (total == 0) return 0;
    return ((completed / total) * 100).round();
  }

  Future<void> _refreshData() async {
    await _loadTotalScore();
    await _loadQuizProgress();
  }

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
              const SizedBox(height: 20),
              // Add total score display
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Total Score: $_totalScore',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

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
                questions: "3",
                progress: "${_calculateProgress(_quizProgress['mcq_progress'] ?? 0, 3)}",
                onPress: "/question", // Named route for MCQ page
              ),
              const SizedBox(height: 16),
              IndexCard(
                title: "Organ Word Scramble",
                questions: "5", // number of words to scramble
                progress: "${_calculateProgress(_quizProgress['wordscramble_progress'] ?? 0, 5)}",
                onPress: "/wordscramble",
              ),
              IndexCard(
                title: "Memory Game",
                questions: "4", // e.g., 4 pairs to match
                progress: "${_calculateProgress(_quizProgress['memory_progress'] ?? 0, 4)}",
                onPress: "/memorygame",
              ),
              IndexCard(
                title: "Drag drop Quiz",
                questions: "4",
                progress: "${_calculateProgress(_quizProgress['dragdrop_progress'] ?? 0, 4)}",
                onPress: "/dragdrop", // Named route for MCQ page
              ),
              const SizedBox(height: 16),
              IndexCard(
                title: "Face Quiz Game",
                questions: "6",
                progress: "${_calculateProgress(_quizProgress['facequiz_progress'] ?? 0, 6)}",
                onPress: "/facequizgame", // Named route for MCQ page
              ),
              const SizedBox(height: 16),
              IndexCard(
                title: "Body Parts Connections Game",
                questions: "3",
                progress: "${_calculateProgress(_quizProgress['connections_progress'] ?? 0, 3)}",
                onPress: "/bodypartsconnections", // Named route for MCQ page
              ),
              const SizedBox(height: 16),

              IndexCard(
                title: "Body Parts Assembly",
                questions: "6", // Number of body parts to place
                progress: "${_calculateProgress(_quizProgress['assembly_progress'] ?? 0, 6)}",
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
                title: "Body learning - Speech recognition",
                slides: "6",
                onPress: "/learningpage", // Named route for Face lesson page
              ),
              const SizedBox(height: 40),

              LessonCard(
                title: "Face learning - Speech recognition",
                slides: "6",
                onPress: "/facelearningpage", // Named route for Face lesson page
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
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/search');
          } else if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ProfilePage(
                  name: "Jane",
                  surname: "Doe",
                  phoneNumber: "123-456-7890",
                ),
              ),
            );
          }
        },
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
