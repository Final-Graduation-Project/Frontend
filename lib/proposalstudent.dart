import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProposalStudent extends StatefulWidget {
  const ProposalStudent({Key? key}) : super(key: key);

  @override
  State<ProposalStudent> createState() => _ProposalStudentState();
}

class _ProposalStudentState extends State<ProposalStudent> {
  List<Map<String, dynamic>> _proposals = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    _fetchAcceptedProposals();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  Future<void> _fetchAcceptedProposals() async {
    try {
      final response = await http.get(
        Uri.parse('https://localhost:7025/api/Proposal/GetAcceptedProposals'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _proposals = responseData.map((proposal) {
            Map<String, int> votes = {};
            if (proposal['optionText'] != null &&
                proposal['optionText'].isNotEmpty) {
              proposal['optionText'].split(',').forEach((element) {
                var parts = element.split(':');
                if (parts.length == 2) {
                  votes[parts[0]] = int.tryParse(parts[1]) ?? 0;
                }
              });
            }
            return {
              'proposalID': proposal['proposalID'],
              'type': proposal['type'],
              'question': proposal['question'],
              'committee': proposal['committee'],
              'userID': proposal['userID'],
              'userName': proposal['name'],
              'optionText': proposal['optionText'] ?? '',
              'commentText': proposal['commentText'] ?? '',
              'comments': proposal['commentText'] != null
                  ? proposal['commentText'].split(';')
                  : [],
              'votes': votes,
            };
          }).toList();
        });
      } else {
        print('Failed to fetch proposals: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch proposals: ${response.statusCode}'),
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch proposals')),
      );
    }
  }

  Future<void> _addComment(int proposalID, String comment) async {
    try {
      final response = await http.post(
        Uri.parse('https://localhost:7025/api/Proposal/AddComment'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'proposalID': proposalID,
          'comment': comment,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _proposals = _proposals.map((proposal) {
            if (proposal['proposalID'] == proposalID) {
              proposal['comments'].add(comment);
            }
            return proposal;
          }).toList();
        });
      } else {
        print('Failed to add comment: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: ${response.statusCode}'),
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment')),
      );
    }
  }

  Future<void> _addVote(int proposalID, String option) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://localhost:7025/api/Proposal/AddVote'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'proposalID': proposalID,
          'option': option,
          'userID': int.parse(userId!), // Passing userId with the request
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _proposals = _proposals.map((proposal) {
            if (proposal['proposalID'] == proposalID) {
              proposal['votes'][option] = (proposal['votes'][option] ?? 0) + 1;
            }
            return proposal;
          }).toList();
        });
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User has already voted')),
        );
      } else {
        print('Failed to add vote: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add vote: ${response.statusCode}'),
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add vote')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF176B87),
        title: Text('Proposals'),
      ),
      body: _proposals.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: _proposals.length,
            itemBuilder: (context, index) {
              return ProposalCard(
                proposal: _proposals[index],
                onCommentAdded: _addComment,
                onVoteAdded: _addVote,
              );
            },
          ),
        ),
      ),
    );
  }
}

class ProposalCard extends StatelessWidget {
  final Map<String, dynamic> proposal;
  final Function(int, String) onCommentAdded;
  final Function(int, String) onVoteAdded;

  const ProposalCard({
    Key? key,
    required this.proposal,
    required this.onCommentAdded,
    required this.onVoteAdded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, int> votes = proposal['votes'] ?? {};

    int totalVotes = votes.values.fold(0, (a, b) => a + b);

    final List<String> options = proposal['optionText']?.split(',') ?? [];
    final List<String> uniqueOptions =
    options.map((option) => option.split(':')[0].trim()).toSet().toList();

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${proposal['type']} by ${proposal['userName']}_${proposal['userID']}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              proposal['question'],
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            if (proposal['type'] == 'Vote') ...[
              SizedBox(height: 8),
              Text('Options:', style: TextStyle(fontSize: 14)),
              for (var option in uniqueOptions) ...[
                InkWell(
                  onTap: () {
                    onVoteAdded(proposal['proposalID'], option);
                  },
                  child: Row(
                    children: [
                      Radio<String>(
                        value: option,
                        groupValue: null,
                        onChanged: (value) {
                          if (value != null) {
                            onVoteAdded(proposal['proposalID'], value);
                          }
                        },
                      ),
                      Text(option, style: TextStyle(fontSize: 14)),
                      SizedBox(width: 8),
                      Text(
                        '${votes[option] ?? 0} votes (${totalVotes > 0 ? ((votes[option] ?? 0) / totalVotes * 100).toStringAsFixed(1) : 0}%)',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Comments:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => CommentDialog(
                        proposalID: proposal['proposalID'],
                        comments: proposal['comments'],
                        onCommentAdded: (proposalID, comment) {
                          onCommentAdded(proposalID, comment);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CommentDialog extends StatefulWidget {
  final int proposalID;
  final List<String> comments;
  final Function(int, String) onCommentAdded;

  const CommentDialog({
    Key? key,
    required this.proposalID,
    required this.comments,
    required this.onCommentAdded,
  }) : super(key: key);

  @override
  _CommentDialogState createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  final TextEditingController _dialogCommentController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Comments'),
      content: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._buildCommentWidgets(),
            SizedBox(height: 12),
            TextField(
              controller: _dialogCommentController,
              decoration: InputDecoration(
                labelText: 'Add a comment',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    _submitComment();
                  },
                ),
              ),
              onSubmitted: (value) {
                _submitComment();
              },
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  List<Widget> _buildCommentWidgets() {
    List<Widget> widgets = [];

    for (int i = 0; i < widget.comments.length; i++) {
      widgets.add(
        ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.account_circle),
            backgroundColor: Color(0xFF176B87),
          ),
          subtitle: Text(
            widget.comments[i],
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );

      if (i < widget.comments.length - 1) {
        widgets.add(
          Divider(
            color: Color(0xFF176B87),
            thickness: 0.5,
          ),
        );
      }
    }

    return widgets;
  }

  void _submitComment() async {
    String comment = _dialogCommentController.text.trim();
    if (comment.isNotEmpty) {
      await widget.onCommentAdded(widget.proposalID, comment);
      setState(() {
        widget.comments.add(comment);
      });
      _dialogCommentController.clear();
    }
  }
}
