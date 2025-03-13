import 'package:bioappdr/pages/Home.dart';
import 'package:bioappdr/pages/lesson.dart';
import 'package:bioappdr/pages/mcq.dart';
import 'package:flutter/material.dart';
import 'package:bioappdr/pages/profile_page.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const Home(),
      '/question': (context) => Mcq(),
      '/lesson': (context) => Lesson()
    },
  ));
}