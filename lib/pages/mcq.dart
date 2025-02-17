/*
Need to build the MCQ page, which idealy has a picture and 4 options.
Questions can later come from FireBase
For now use a list if u want
 */


import 'package:flutter/material.dart';

class Mcq extends StatefulWidget {
  const Mcq({super.key});

  @override
  State<Mcq> createState() => _McqState();
}

class _McqState extends State<Mcq> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BioApp", style: TextStyle(fontWeight: FontWeight.w500)),
      ),
      body: Text("MCQ Page", style: TextStyle(fontSize: 30) ),
    );
  }
}
