import 'package:flutter/material.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate sizes based on screen size for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth / 4; // Dynamic image size based on screen width

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB4D4FF),
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            SizedBox(width: 10),
            Text('Contact Us'),
          ],
        ),
      ),
      body: SingleChildScrollView( // Make the body scrollable
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20, right: 20),
                  child: Text(
                    'We are three passionate Computer Science students who developed this application with love to make your university experience better than ours!',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF176B87),
                      fontFamily: 'Roboto',
                    ),
                    softWrap: true,
                  ),
                ),
                SizedBox(height: 30),
                // Developer images and names
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildDeveloper('images/ziad.jpg', 'Ziad Masalma', Icons.person, imageSize),
                      _buildDeveloper('images/jnn.jpg', 'Jenin Hajyassin', Icons.person, imageSize),
                      _buildDeveloper('images/fadi.jpg', 'Fadi AlAmleh', Icons.person, imageSize),
                    ],
                  ),
                ),
                // Contact information using Wrap for better responsiveness
                Wrap(
                  spacing: 20, // Space between each chip
                  runSpacing: 10, // Space between lines
                  alignment: WrapAlignment.center,
                  children: [
                    _buildContactInfo('z.j.masalma@gmail.com', Icons.email),
                    _buildContactInfo('jeninhajyassin02@gmail.com', Icons.email),
                    _buildContactInfo('fadyalmlt294@gmail.com', Icons.email),
                  ],
                ),
                // Additional text
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    'Feel free to contact us if you have new ideas or encounter any problems using our application!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Color(0xFF176B87),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Modified _buildDeveloper to include imageSize for dynamic sizing
  Widget _buildDeveloper(String imagePath, String name, IconData icon, double imageSize) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(255, 70, 145, 172)),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              imagePath,
              height: imageSize, // Adjusted size
              width: imageSize, // Adjusted size
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Icon(icon),
      ],
    );
  }

  // Updated _buildContactInfo function for better text visibility
  Widget _buildContactInfo(String email, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 20),
      label: Text(
        email,
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}
