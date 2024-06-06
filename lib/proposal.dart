import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firstPage.dart';

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
            Text('Proposals'),
            Icon(Icons.post_add),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Submit your questions or proposals, we are here to help you",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => _showProposalDialog(context),
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _proposals.length,
              itemBuilder: (context, index) {
                return _buildProposalCard(_proposals[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
