import 'package:flutter/material.dart';
import 'proposal.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  List<Map<String, dynamic>> _acceptedProposals = [];

  void addAcceptedProposal(Map<String, dynamic> proposal) {
    setState(() {
      _acceptedProposals.add(proposal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB4D4FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFEEF5FF),
        title: Text('Welcome to Student Digital Guide'),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFEEF5FF),
              ),
              child: Text(
                'Features We Provide',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: Icon(Icons.calendar_month),
              title: Text('Event Calendar'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/Eve');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: Icon(Icons.person),
              title: Text('Chatbot'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/chatbot');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: Icon(Icons.chat),
              title: Text('Chat'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/chat');
              },
              //course 
            
            ),
             ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: Icon(Icons.post_add),
              title: Text('Proposal'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/proposal');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: Icon(Icons.book),
              title: Text('Courses'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/course');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: Icon(Icons.group),
              title: Text('Groups'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/groups');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: Icon(Icons.contact_mail),
              title: Text('Contact Us'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/contactus');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: Icon(Icons.info),
              title: Text('About Us'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/aboutus');
              },
            ),
          ],
        ),
        ),
   body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "You can share anything with us if you want! Let's hear your ideas",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Proposal(
                          onProposalAccepted: addAcceptedProposal,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _acceptedProposals.length,
              itemBuilder: (context, index) {
                final proposal = _acceptedProposals[index];
                return ProposalCard(proposal: proposal);
              },
            ),
          ),
        ],
      ),
    ); 
    
  }
}

class ProposalCard extends StatelessWidget {
  final Map<String, dynamic> proposal;

  const ProposalCard({Key? key, required this.proposal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('${proposal['type']} by ${proposal['id']}'),
            subtitle: Text(proposal['committee']),
            trailing: Text(proposal['text']),
          ),
          CommentsSection(proposal: proposal),
        ],
      ),
    );
  }
}

class CommentsSection extends StatefulWidget {
  final Map<String, dynamic> proposal;

  const CommentsSection({Key? key, required this.proposal}) : super(key: key);

  @override
  _CommentsSectionState createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.proposal['comments'].length,
          itemBuilder: (context, index) {
            final comment = widget.proposal['comments'][index];
            return ListTile(
              title: Text(comment['id']),
              subtitle: Text(comment['text']),
            );
          },
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Add a comment',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (text) {
                  setState(() {
                    widget.proposal['comments'].add({
                      'id': 'currentUser', // Replace with actual user ID
                      'text': text,
                    });
                  });
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                setState(() {
                  widget.proposal['comments'].add({
                    'id': 'currentUser', // Replace with actual user ID
                    'text': _commentController.text,
                  });
                  _commentController.clear();
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
