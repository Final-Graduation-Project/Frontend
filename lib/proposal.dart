import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Proposal extends StatefulWidget {
  const Proposal({super.key});

  @override
  State<Proposal> createState() => _ProposalState();
}

class _ProposalState extends State<Proposal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
        backgroundColor: Color(0xFFB4D4FF),
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            SizedBox(width: 10),
            Text('Submit your Proposal '),
            Icon(CupertinoIcons.smiley)

          ],
        ),
    )
    
    );
  }
}