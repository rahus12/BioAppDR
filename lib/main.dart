import 'package:bioappdr/pages/Home.dart';
import 'package:bioappdr/pages/lesson.dart';
import 'package:bioappdr/pages/mcq.dart';
import 'package:flutter/material.dart';
import 'package:bioappdr/pages/profile_page.dart';
import 'package:bioappdr/pages/face_lesson.dart';
import 'DragDrop.dart';

void main() {
  runApp(MaterialApp(
    initialRoute  : '/',
    routes: {
      '/': (context) => const Home(),
      '/question': (context) => Mcq(),
      '/lesson': (context) => Lesson(),
      '/facelesson': (context) => FaceLesson(),
      '/dragdrop': (context) => DragDrop(),
    },
  ));
}