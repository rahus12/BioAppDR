import 'package:bioappdr/pages/Home.dart';
import 'package:bioappdr/pages/mcq.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const Home(),
      '/question': (context) => const Mcq()
    },
  ));
}
