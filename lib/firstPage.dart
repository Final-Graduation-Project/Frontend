import 'package:flutter/material.dart';
import 'package:flutter_application_1/Login.dart';
import 'package:flutter_application_1/proposal.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);
  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  List<Map<String, dynamic>> _acceptedProposals = [];
  Set<String> _userVotes = {}; // Track user votes
  String? userName;
  String? userEmail;
  String? userRole;
  String? userId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void addAcceptedProposal(Map<String, dynamic> proposal) {
    setState(() {
      print('Adding accepted proposal: $proposal');
      _acceptedProposals.add(proposal);
    });
  }

  void toggleVote(int index, String userId) {
    setState(() {
      if (_userVotes.contains('$index$userId')) {
        _userVotes.remove('$index$userId'); // Remove existing vote
      } else {
        _userVotes.add('$index$userId'); // Add new vote
      }
    });
  }

  void addComment(int index, String comment, String userId) {
    setState(() {
      _acceptedProposals[index]['comments']
          .add({'id': userId, 'text': comment});
    });
  }

  Future<void> clearSpecificPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName');
    userEmail = prefs.getString('userEmail');
    userRole = prefs.getString('userRole');
    userId = prefs.getString('userId');
    if (userRole == null) {
      Navigator.pushNamed(context, '/login');
    }
  }

  void _showUserDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: $userName'),
              Text('Email: $userEmail'),
              Text('Role: $userRole'),
              Text('ID: $userId'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    final url = Uri.parse('http://localhost:5050/api/Student/logout');
    final response = await http.get(
      url,
      headers: {'accept': '*/*'},
    );

    if (response.statusCode == 200) {
      // Logout successful, navigate to login page or show a success message
      print('Logout successful');
      clearSpecificPreference();
      Navigator.pushNamed(
          context, '/'); // Adjust the route name to your login page
    } else {
      print(response.body);
      // Logout failed, show error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Logout Failed'),
          content: Text(response.body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserData userData =
        ModalRoute.of(context)!.settings.arguments as UserData;
    return Scaffold(
      backgroundColor: Color(0xFFB4D4FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFEEF5FF),
        title: Text('Welcome to Student Digital Guide'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_2_outlined),
            onPressed: _showUserDetails,
          ),
          TextButton(
            onPressed: () {
              _logout();
              Navigator.pushNamed(context, '/login');
            },
            child: Text("Log Out", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
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
              leading: Icon(Icons.calendar_today),
              title: Text('Event Calendar'),
              onTap: () => Navigator.pushNamed(context, '/Eve'),
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chatbot'),
              onTap: () => Navigator.pushNamed(context, '/chatbot'),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Chat'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(
                    context, '/Chatpage' // Assuming userData is of type UserData
                    );
              },
            ),
            ListTile(
              leading: Icon(Icons.post_add),
              title: Text('Proposal'),
              onTap: () => Navigator.pushNamed(context, '/proposal'),
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Courses'),
              onTap: () => Navigator.pushNamed(context, '/course'),
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Groups'),
              onTap: () => Navigator.pushNamed(context, '/groups'),
            ),
            ListTile(
              leading: Icon(Icons.contact_mail),
              title: Text('Contact Us'),
              onTap: () => Navigator.pushNamed(context, '/contact'),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About Us'),
              onTap: () => Navigator.pushNamed(context, '/about'),
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
                return ProposalCard(
                  proposal: proposal,
                  hasVoted:
                      _userVotes.contains('$index'), // Check if user has voted
                  onVote: () => toggleVote(
                      index, 'userId'), // Replace 'userId' with actual user ID
                  onComment: (comment) => addComment(index, comment,
                      'userId'), // Replace 'userId' with actual user ID
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProposalCard extends StatelessWidget {
  final Map<String, dynamic>? proposal; // Change the type to allow null
  final bool hasVoted;
  final Function() onVote;
  final Function(String) onComment;

  const ProposalCard({
    Key? key,
    required this.proposal,
    required this.hasVoted,
    required this.onVote,
    required this.onComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _commentController = TextEditingController();

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(proposal?['text'] ??
                'Question missing'), // Null check added here
            subtitle: Text(proposal?['id']?.toString() ??
                'ID missing'), // Null check added here
          ),
          if (proposal != null &&
              proposal!.containsKey('options')) // Null check added here
            Column(
              children: proposal!['options'].map<Widget>((option) {
                return ListTile(
                  title: Text(option),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.thumb_up),
                        onPressed: hasVoted
                            ? null
                            : onVote, // Disable voting if already voted
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          if (proposal != null &&
              proposal!.containsKey('comments')) // Null check added here
            Column(
              children: proposal!['comments'].map<Widget>((comment) {
                return ListTile(
                  title: Text(comment[
                      'text']), // Assuming the key for comment text is 'text'
                  subtitle: Text(
                      'User ID: ${comment['id']}'), // Assuming the key for user ID is 'id'
                );
              }).toList(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: 'Add a comment',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_commentController.text.isNotEmpty) {
                      onComment(_commentController.text);
                      _commentController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
