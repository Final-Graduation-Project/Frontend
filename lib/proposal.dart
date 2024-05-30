import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firstPage.dart';

class Proposal extends StatefulWidget {
  final Function(Map<String, dynamic>) onProposalAccepted;

  const Proposal({Key? key, required this.onProposalAccepted}) : super(key: key);

  @override
  State<Proposal> createState() => _ProposalState();
}

class _ProposalState extends State<Proposal> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController()
  ]; // Start with two options
  String? _selectedCommittee;
  String? _proposalType;
  String? _selectedVoteOption;

  List<Map<String, dynamic>> _proposals = [];

  final List<String> _committees = [
    'رئاسة المجلس',
    'اللجنة المالية',
    'لجنة التخصصات',
    'لجنة العمل التعاوني',
    'اللجنة الفنية',
    'اللجنة الثقافية',
    'اللجنة الرياضية',
    'لجنة الكافتيريات',
    'اللجنة الاجتماعية',
    'اللجنة الصحية',
    'لجنة العلاقات العامة',
    'الجميع',
  ];

  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    _commentController.dispose();
    super.dispose();
  }
  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole');
    if(role==null){
      Navigator.pushNamed(context, '/login');
    }
  }
  void _showProposalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Submit your questions or any proposal, we are here to help'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _idController,
                      decoration: InputDecoration(
                        labelText: 'University ID',
                        hintText: 'Enter your 7-digit university ID',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 7,
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Committee',
                        border: OutlineInputBorder(),
                      ),
                      items: _committees.map((String committee) {
                        return DropdownMenuItem<String>(
                          value: committee,
                          child: Text(committee),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCommittee = newValue;
                        });
                      },
                      value: _selectedCommittee,
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Proposal Type',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Vote', 'Question', 'Proposal'].map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _proposalType = newValue;
                        });
                      },
                      value: _proposalType,
                    ),
                    SizedBox(height: 20),
                    _proposalInputField(setState),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _submitProposal,
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _proposalInputField(StateSetter setState) {
    if (_proposalType == 'Vote') {
      return Column(
        children: [
          TextField(
            controller: _questionController,
            decoration: InputDecoration(
              labelText: 'Your Question',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          SizedBox(height: 20),
          ..._optionControllers.map((controller) {
            int index = _optionControllers.indexOf(controller);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Option ${index + 1}',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _optionControllers.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            );
          }).toList(),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _optionControllers.add(TextEditingController());
              });
            },
            icon: Icon(Icons.add),
            label: Text('Add Option'),
          ),
        ],
      );
    } else {
      return TextField(
        controller: _questionController,
        decoration: InputDecoration(
          labelText: _proposalType == 'Question' ? 'Your Question' : 'Your Proposal',
          hintText: _proposalType == 'Question' ? 'Write your question here...' : 'Describe your proposal...',
          border: OutlineInputBorder(),
        ),
        maxLines: 5,
      );
    }
  }

 Widget _buildProposalCard(Map<String, dynamic> proposal) {
  if (proposal['type'] == null || proposal['id'] == null || proposal['committee'] == null) {
    return SizedBox(); // Return an empty widget if any essential data is null
  }
  
  return Card(
    child: Column(
      children: [
        ListTile(
          title: Text('${proposal['type']} by ${proposal['id']}'),
          subtitle: Text(proposal['committee']),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(proposal['text'] ?? ''), // Add a null check for 'text'
        ),
        if (proposal['type'] == 'Vote') ...[
          for (var option in proposal['options'])
            RadioListTile<String>(
              title: Text(option.trim()),
              value: option.trim(),
              groupValue: _selectedVoteOption,
              onChanged: (value) {
                setState(() {
                  _selectedVoteOption = value;
                  proposal['votes'] += 1;
                });
              },
            ),
          Text('Total Votes: ${proposal['votes'] ?? 0}')
        ] else ...[
          _buildCommentsSection(proposal)
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _proposals.remove(proposal);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                setState(() {
                  proposal['accepted'] = true;
                  widget.onProposalAccepted(proposal);
                  _proposals.remove(proposal);
                });
              },
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildCommentsSection(Map<String, dynamic> proposal) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: proposal['comments'].length,
          itemBuilder: (context, index) {
            final comment = proposal['comments'][index];
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
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                setState(() {
                  proposal['comments'].add({
                    'id': _idController.text,
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

 void _submitProposal() {
  print("_proposalType: $_proposalType");
  print("_selectedCommittee: $_selectedCommittee");

  if (_idController.text.length == 7 &&
      _selectedCommittee != null &&
      _questionController.text.isNotEmpty &&
      _proposalType != null &&
      (_proposalType != 'Vote' ||
          _optionControllers.every((controller) => controller.text.isNotEmpty))) {
    setState(() {
      List<String> options = _proposalType == 'Vote'
          ? _optionControllers.map((controller) => controller.text).toList()
          : [];
      Map<String, dynamic> proposal = {
        'type': _proposalType!,
        'question': _questionController.text,
        'options': options,
        'committee': _selectedCommittee!,
        'id': _idController.text,
        'votes': 0,
        'comments': [],
        'accepted': false,
      };
      _proposals.add(proposal);
      widget.onProposalAccepted(proposal); // Pass the proposal data to the callback
      _questionController.clear();
      _idController.clear();
      _selectedCommittee = null;
      _proposalType = null;
      _optionControllers.clear();
      _optionControllers.add(TextEditingController());
      _optionControllers.add(TextEditingController());
    });
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Proposal submitted successfully!')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please complete all fields correctly')),
    );
  }
}

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
