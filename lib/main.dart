import 'package:flutter/material.dart';
import 'package:flutter_application_1/EventPage.dart';
import 'package:flutter_application_1/Login.dart';
import 'package:flutter_application_1/Validate.dart';
import 'package:flutter_application_1/aboutus.dart';
import 'package:flutter_application_1/chatPage.dart';
import 'package:flutter_application_1/chatbot.dart';
import 'package:flutter_application_1/contactus.dart';
import 'package:flutter_application_1/firstPage.dart';
import 'package:flutter_application_1/proposalstudent.dart';
import 'package:flutter_application_1/signup.dart';
import 'package:flutter_application_1/map.dart';
import 'package:flutter_application_1/proposal.dart';
import 'package:flutter_application_1/course.dart';

void main() {
  runApp(Mainpage());
}

class Mainpage extends StatelessWidget {
  final Color color1 = Color(0xFF176B87); // Dark Blue
  final Color color2 = Color(0xFFB4D4FF); // Lighter Blue
  final Color color3 = Color(0xFF86B6F6); // Even Lighter Blue
  final Color color4 = Color(0xFFEEF5FF); // Very Light Blue

  Mainpage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Digital Guide",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          actionsIconTheme: IconThemeData(color: color4),
          iconTheme: IconThemeData(color: color4),
          titleTextStyle: TextStyle(
            color: color4,
            fontSize: 20,
          ),
        ),
        scaffoldBackgroundColor: color4,
        primaryColor: color1,
        hintColor: color3,
      ),
      routes: {
        '/': (context) => Home(),
        '/login': (context) => const Login(),
        '/aboutus': (context) => const AboutUs(),
        '/signup': (context) => Signup(),
        '/contactus': (context) => const ContactUs(),
        //'/validate': (context) => const Validate(),
        '/firstPage': (context) => const FirstPage(),
        '/Eve': (context) => EventPage(),
        '/chatbot': (context) => ChatBot(),
        '/map': (context) => MapPage(),
        '/proposal': (context) =>
            Proposal(onProposalAccepted: (Map<String, dynamic> data) {}),
        '/course': (context) => CourseSearchScreen(),
        '/Chatpage': (context) => ChatPage(),
        '/propstudent': (context) => proposalstudent(),
      },
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF176B87),
        title: Text("Student Digital Guide"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/aboutus');
            },
            child: Text(
              "About us",
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/contactus');
            },
            child: Text(
              "Contact us",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
          child: isMobile
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "images/studentdigitalguidelogo.png",
                      height: 150,
                      width: 150,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color(0xFF176B87),
                        backgroundColor: Colors.white,
                        textStyle: TextStyle(fontSize: 24),
                        padding:
                            EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                      ),
                      child: Text("Login"),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFF176B87),
                        textStyle: TextStyle(fontSize: 24),
                        padding:
                            EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                      ),
                      child: Text("Sign up"),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "images/login.jpg",
                      height: MediaQuery.of(context).size.height * 0.8,
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                    SizedBox(width: 100),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "images/studentdigitalguidelogo.png",
                          height: 250,
                          width: 250,
                        ),
                        SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Color(0xFF176B87),
                            backgroundColor: Colors.white,
                            textStyle: TextStyle(fontSize: 24),
                            padding: EdgeInsets.symmetric(
                                horizontal: 60, vertical: 20),
                          ),
                          child: Text("Login"),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xFF176B87),
                            textStyle: TextStyle(fontSize: 24),
                            padding: EdgeInsets.symmetric(
                                horizontal: 60, vertical: 20),
                          ),
                          child: Text("Sign up"),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/map');
        },
        backgroundColor: Color(0xFF176B87),
        child: Icon(Icons.map),
      ),
    );
  }
}
