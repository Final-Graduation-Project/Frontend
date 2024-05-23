import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = EdgeInsets.all(screenWidth > 600 ? 16 : 8); // Smaller padding
    final margin = EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 16 : 8, vertical: 10); // Smaller margin
    final textSize = screenWidth > 600 ? 20 : 16; // Smaller text size
    final featureTextSize = screenWidth > 600 ? 18 : 14; // Smaller feature text size

    return Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
        backgroundColor: Color(0xFF176B87),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "images/studentdigitalguidelogo.png",
                height: screenWidth > 600 ? 300 : 150, // Smaller image size
                width: screenWidth > 600 ? 300 : 150,
              ),
              Container(
                margin: margin,
                padding: padding,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Color(0xFF176B87),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "SDG is a digital platform that streamlines interaction between university components and creates an interactive environment that connects all university components. This project aims to create a comprehensive digital platform that improves communication and interaction among students, the student council, teaching staff, and the university administration.",
                  style: TextStyle(
                    fontSize: textSize.toDouble(),
                    color: Color.fromARGB(255, 10, 74, 95),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                margin: margin,
                padding: padding,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
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
                    SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildFeatureList(screenWidth),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFeatureList(double screenWidth) {
    final featureTextSize = screenWidth > 600 ? 18 : 14; // Smaller feature text size
    List<String> features = [
      "1. Event viewing",
      "2. Proposal submission",
      "3. Advanced search capabilities",
      "4. Schedule of faculty office hours",
      "5. Interactive university map",
      "6. Live chat support",
      "7. Communication channels between students and the Student Council",
    ];

    return features
        .map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                feature,
                style: TextStyle(
                  fontSize: featureTextSize.toDouble(),
                  color: Color.fromARGB(255, 10, 74, 95),
                ),
              ),
            ))
        .toList();
  }
}
