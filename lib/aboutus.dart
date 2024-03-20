import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to make sizes responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = EdgeInsets.all(screenWidth > 600 ? 24 : 16); // Adjust padding based on screen width
    final margin = EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 20 : 10, vertical: 20);
    final textSize = screenWidth > 600 ? 24 : 20; // Adjust text size based on screen width

    return Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
        backgroundColor: Color(0xFFB4D4FF),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "images/studentdigitalguidelogo.png",
              height: screenWidth > 600 ? 400 : 200, // Adjust image size based on screen width
              width: screenWidth > 600 ? 400 : 200,
            ),
            Container(
              margin: margin,
              padding: padding,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFF176B87),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "SDG: is a digital platform that streamlines interaction between university components and creates an interactive environment that connects all university components. This project aims to create a comprehensive digital platform that improves communication and interaction among students, the student council, teaching staff, and the university administration.",
                style: TextStyle(
                  fontSize: textSize.toDouble(),
                  color: Color.fromARGB(255, 10, 74, 95),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Another bordered box for interesting features
            Container(
              margin: margin,
              padding: padding,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFF176B87),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Interesting Features:",
                    style: TextStyle(
                      fontSize: textSize.toDouble(),
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 10, 74, 95),
                    ),
                  ),
                  SizedBox(height: 10),
                  ..._buildFeatureList(screenWidth), // Generate feature list
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to generate feature texts with appropriate styling based on screen width
  List<Widget> _buildFeatureList(double screenWidth) {
    final featureTextSize = screenWidth > 600 ? 20 : 16; // Adjust feature text size based on screen width
    List<String> features = [
      "1. Event viewing",
      "2. Proposal submission",
      "3. Advanced search capabilities",
      "4. Schedule of faculty office hours",
      "5. Interactive university map",
      "6. Live chat support",
      "7. Straightforward communication channels between students and the Student Council",
    ];

    return features
        .map((feature) => Text(
              feature,
              style: TextStyle(
                fontSize: featureTextSize.toDouble(),
                color: Color.fromARGB(255, 10, 74, 95),
              ),
            ))
        .toList();
  }
}
