import 'package:bioappdr/pages/Home.dart';
import 'package:bioappdr/pages/lesson.dart';
import 'package:bioappdr/pages/mcq.dart';
import 'package:flutter/material.dart';
import 'package:bioappdr/pages/profile_page.dart';
import 'package:bioappdr/pages/face_lesson.dart';
import 'package:bioappdr/pages/word_scramble_game.dart';
import 'package:bioappdr/pages/memory_game.dart';
import 'package:bioappdr/pages/FaceQuizGame.dart';
import 'package:bioappdr/pages/BodyPartsConnections.dart';
import 'package:bioappdr/pages/DragDrop.dart';
import 'package:bioappdr/pages/BodyPartsButtonGame.dart';
import 'package:bioappdr/pages/LearningPage.dart';
import 'package:bioappdr/pages/FaceLearningPage.dart';
import 'package:flutter_gemini/flutter_gemini.dart'; // 1. Import Gemini

void main() {
  // 2. Initialize Gemini with your API Key
  Gemini.init(
    apiKey: "AIzaSyC0n7lVN-UZ3L9sYoRd35BYno0QXdbqXic",
  );

  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const Home(),
      '/question': (context) => const Mcq(),
      '/lesson': (context) => const Lesson(),
      '/facelesson': (context) => const FaceLesson(),
      '/memorygame': (context) => const MemoryGame(),
      '/dragdrop': (context) => const DragDrop(),
      "/wordscramble": (context) =>
      const WordScrambleGameV2(), // Assuming this exists
      "/facequizgame": (context) => const FaceQuizGame(),
      "/bodypartsconnections": (context) => const BodyPartsConnections(),
      "/bodyassembly": (context) => const BodyPartsButtonGame(),
      "/learningpage": (context) => const LearningPage(),
      "/facelearningpage": (context) => const Facelearningpage(),
    },
  ));
}