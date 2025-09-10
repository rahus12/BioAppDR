import 'package:bioappdr/pages/Home.dart';
import 'package:bioappdr/pages/lesson.dart';
import 'package:bioappdr/pages/mcq.dart';
import 'package:flutter/material.dart';
import 'package:bioappdr/pages/face_lesson.dart';
import 'package:bioappdr/pages/word_scramble_game.dart';
import 'package:bioappdr/pages/memory_game.dart';
import 'package:bioappdr/pages/FaceQuizGame.dart';
import 'package:bioappdr/pages/BodyPartsConnections.dart';
import 'package:bioappdr/pages/search.dart';

import 'package:bioappdr/pages/DragDrop.dart';
import 'package:bioappdr/pages/BodyPartsButtonGame.dart';
import 'package:bioappdr/pages/LearningPage.dart';
import 'package:bioappdr/pages/FaceLearningPage.dart';






void main() {
  runApp(MaterialApp(
    initialRoute  : '/',
    routes: {
      '/': (context) => const Home(),
      '/question': (context) => const Mcq(),
      '/lesson': (context) => const Lesson(),
      '/facelesson': (context) => const FaceLesson(),
      '/memorygame': (context) => const MemoryGame(),
      '/dragdrop': (context) => const DragDrop(),
      "/wordscramble": (context) => const WordScrambleGameV2(),
      "/facequizgame": (context) => const FaceQuizGame(),
      "/bodypartsconnections": (context) => const BodyPartsConnections(),
      "/bodyassembly": (context) => const BodyPartsButtonGame(),
      "/learningpage": (context) => const LearningPage(),
      "/facelearningpage": (context) => const Facelearningpage(),
      '/search': (context) => const SearchPage(),
    },
    onGenerateRoute: (settings) {
      final String? name = settings.name;
      if (name == null) {
        return null;
      }
      final Uri uri = Uri.parse(name);

      // Deep link: /search?q=face
      if (uri.path == '/search') {
        final String initialQuery = uri.queryParameters['q'] ?? '';
        final String initialType = uri.queryParameters['type'] ?? 'all';
        return MaterialPageRoute(
          builder: (_) => SearchPage(initialQuery: initialQuery, initialType: initialType),
          settings: settings,
        );
      }

      // Deep link: /open/<route>
      // Example: /open/lesson → navigates to '/lesson'
      if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'open') {
        final String target = '/${uri.pathSegments[1]}';
        return MaterialPageRoute(
          builder: (context) {
            // Redirect immediately to target route
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(target);
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
          settings: settings,
        );
      }

      return null; // Fallback to routes or onUnknownRoute
    },
  ));
}