/*
Home page, where the user can select different quizes,
for now lets just do one quiz, and when user clicks he can go to the quiz/mcq page

Need to style the quiz buttons like the Figma design
 */
import 'package:flutter/material.dart';
import 'package:bioappdr/components/indexcard.dart';
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
        backgroundColor: Colors.purple[400],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Text("Home Page", style: TextStyle(fontSize: 30) ),
          IndexCard(
            title: "Heart Quiz",
            questions: "13",
            progress: "17",
          ),
          IndexCard(
            title: "Lorem Ipsum",
            questions: "23",
            progress: "0",
          ),
        ],
      ),
    );
  }
}

