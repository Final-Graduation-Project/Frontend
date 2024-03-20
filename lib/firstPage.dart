import 'package:flutter/material.dart';

class firstPage extends StatefulWidget {
  const firstPage({super.key});

  @override
  State<firstPage> createState() => _firstPageState();
}

class _firstPageState extends State<firstPage> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Welcome to Student Digital Guide',),
       backgroundColor: Color(0xFF176B87),
      
      leading: Image.asset('images/studentdigitalguidelogo.png', height: 40, width: 40),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
          child: Text("Log Out"),
        ),

      ],
      
    );

  }
}