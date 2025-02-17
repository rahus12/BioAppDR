/*
Home page, where the user can select different quizes,
for now lets just do one quiz, and when user clicks he can go to the quiz/mcq page

Need to style the quiz buttons like the Figma design
 */
import 'package:flutter/material.dart';

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
        title: Text("AppName"),
      ),
      body: Column(
        children: [
          Text("Home Page", style: TextStyle(fontSize: 30) ),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/question');
              },
              child: Text("Quiz 1"))
        ],
      ),
    );
  }
}
