import 'package:flutter/material.dart';

class IndexCard extends StatelessWidget {

  String? title = "";
  String? questions;
  String? progress;

  IndexCard({this.title, this.questions, this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF5F5F5),
      child: Column(
        children: [
          // black box container
          SizedBox(height: 30,),
          Center(
            child: Container(
              padding: EdgeInsets.fromLTRB(20 ,10, 20, 10),
              width: 337,
              height: 116,
              decoration: BoxDecoration(
                color: Colors.black, // Background color
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$title",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white
                    ),
                  ),
                  Text(
                    "$questions Questions",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7C7C7C)
                    ),
                  ),
                  SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Progress $progress%",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFFFD166)
                        ),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFD166),
                              foregroundColor: Colors.black,
                              fixedSize: Size(55, 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6), // Set the radius here
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5)
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/question');
                          },
                          child: Text("Start", style: TextStyle(
                            fontSize: 16,
                          ),)),
                    ],
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}