import 'package:flutter/material.dart';

class proposalstudent extends StatefulWidget {
  const proposalstudent({super.key});

  @override
  State<proposalstudent> createState() => _proposalstudentState();
}

class _proposalstudentState extends State<proposalstudent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF176B87),
        title: Text('Proposal'),
      ),
    );
  }
}
