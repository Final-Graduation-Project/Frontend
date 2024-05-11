import 'package:flutter/material.dart';

class grouppage extends StatefulWidget {
  const grouppage({super.key});

  @override
  State<grouppage> createState() => _grouppageState();
}

class _grouppageState extends State<grouppage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB4D4FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFEEF5FF),
        title: Text('Groups'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              // Handle search action
            },
            icon: Icon(Icons.search),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
            child: Text("Log Out"),
          ),
        ],
      ),
     
    );
  }
}