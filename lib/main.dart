import 'package:bioappdr/pages/Home.dart';
import 'package:bioappdr/pages/mcq.dart';
import 'package:flutter/material.dart';
<<<<<<< Updated upstream
=======
import 'package:bioappdr/pages/profile_page.dart';
import 'package:bioappdr/pages/face_lesson.dart';
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
<<<<<<< Updated upstream
      '/': (context) => Home(),
      '/question': (context) => Mcq()
=======
      '/': (context) => const Home(),
      '/question': (context) => Mcq(),
      '/lesson': (context) => Lesson(),
      '/faceLesson': (context) => const FaceLesson(),
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    },
  ));
}
