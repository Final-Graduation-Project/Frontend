import 'package:flutter/material.dart';
import 'package:flutter_application_1/EventPage.dart';
import 'package:flutter_application_1/Login.dart';
import 'package:flutter_application_1/Validate.dart';
import 'package:flutter_application_1/aboutus.dart';
import 'package:flutter_application_1/cahtbot.dart';
import 'package:flutter_application_1/contactus.dart';
import 'package:flutter_application_1/firstPage.dart';
import 'package:flutter_application_1/signup.dart';
import 'package:flutter_application_1/map.dart';
import 'package:flutter_application_1/proposal.dart';

import 'course.dart';


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
      title: "student digital guide",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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
        '/validate': (context) => const Validate(),
        '/firstPage': (context) => const FirstPage(),
        '/Eve': (context) => EventPage(),
        '/chatbot': (context) => ChatBot(),
        '/map':(context) => map(),
        '/proposal': (context) => Proposal(),
        '/course': (context) => CourseSearchScreen(),
      },
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB4D4FF),
        leading: Image.asset('images/studentdigitalguidelogo.png',
            height: 40, width: 40),
        title: Text("Student Digital Guide"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/aboutus');
            },
            child: Text("About us"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/contactus');
            },
            child: Text("Contact us"),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset("images/studentdigitalguidelogo.png",
                height: 200, width: 200),
          ),
          SizedBox(height: 24),
          Text(
            "Student Digital Guide",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already signed in ?"),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text("Login"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("New student? "),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Text("Sign up"),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/map');
        },
        child: Icon(Icons.map),
      ),
    );
  }
}
