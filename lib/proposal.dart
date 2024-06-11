import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Proposal extends StatefulWidget {
  final Function(Map<String, dynamic>) onProposalAccepted;
  final minOptions = 2;
  final maxOptions = 5;
  const Proposal({Key? key, required this.onProposalAccepted})
      : super(key: key);

  @override
  State<Proposal> createState() => _ProposalState();
}

class _ProposalState extends State<Proposal> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  late SharedPreferences prefs;
  bool _prefsInitialized = false;

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  Future<void> getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefsInitialized = true;
    });
  }

  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController()
  ]; // Start with two options
  String? _selectedCommittee;
  String? _proposalType;
  String? _selectedVoteOption;

  List<Map<String, dynamic>> _proposals = [
    {
      'type': 'Vote',
      'question': 'What is your favorite color?',
      'options': ['Red', 'Green', 'Blue'],
      'committee': 'اللجنة الثقافية',
      'id': '1202580',
      'votes': 0,
      'comments': [],
      'accepted': false,
    },
    {
      'type': 'Question',
      'question': 'What is the deadline for the project?',
      'committee': 'اللجنة الفنية',
      'id': '1202580',
      'votes': 0,
      'comments': [],
      'accepted': false,
    },
    {
      'type': 'Vote',
      'question': 'What is your favorite color?',
      'options': ['Red', 'Green', 'Blue'],
      'committee': 'اللجنة الثقافية',
      'id': '1202580',
      'votes': 0,
      'comments': [],
      'accepted': false,
    },
    {
      'type': 'Question',
      'question': 'What is the deadline for the project?',
      'committee': 'اللجنة الفنية',
      'id': '1202580',
      'votes': 0,
      'comments': [],
      'accepted': false,
    }
  ];

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

  void _showProposalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                  'Submit your questions or any proposal, we are here to help'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
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
                      items:
                          ['Vote', 'Question', 'Proposal'].map((String type) {
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
                  onPressed: () {
                    _showSubmitConfirmationDialog();
                  },
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
                        if (_optionControllers.length > widget.minOptions) {
                          _optionControllers.removeAt(index);
                        }
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
                if (_optionControllers.length < widget.maxOptions) {
                  _optionControllers.add(TextEditingController());
                }
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
          labelText:
              _proposalType == 'Question' ? 'Your Question' : 'Your Proposal',
          hintText: _proposalType == 'Question'
              ? 'Write your question here...'
              : 'Describe your proposal...',
          border: OutlineInputBorder(),
        ),
        maxLines: 5,
      );
    }
  }

  Widget _buildProposalCard(Map<String, dynamic> proposal) {
    if (proposal['type'] == null || proposal['committee'] == null) {
      return SizedBox(); // Return an empty widget if any essential data is null
    }

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A ${proposal['type']} by ${prefs.getString('userName')}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                proposal['question'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
              SizedBox(height: 20),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () {
                      _showDeleteConfirmationDialog(proposal);
                    },
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: Icon(Icons.check),
                    color: Colors.green,
                    onPressed: () {
                      setState(() {
                        proposal['accepted'] = true;
                        widget.onProposalAccepted(proposal);
                        _proposals.remove(proposal);
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> proposal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this proposal?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _proposals.remove(proposal);
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showSubmitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Submission'),
          content:
              Text('Are you sure you want to submit this ${_proposalType}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitProposal();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _submitProposal() {
    if (_prefsInitialized &&
        _selectedCommittee != null &&
        _questionController.text.isNotEmpty &&
        _proposalType != null &&
        (_proposalType != 'Vote' ||
            _optionControllers
                .every((controller) => controller.text.isNotEmpty))) {
      setState(() {
        List<String> options = _proposalType == 'Vote'
            ? _optionControllers.map((controller) => controller.text).toList()
            : [];
        Map<String, dynamic> proposal = {
          'type': _proposalType!,
          'question': _questionController.text,
          'options': options,
          'committee': _selectedCommittee!,
          'votes': 0,
          'comments': [],
          'accepted': false,
        };
        _proposals.add(proposal);

        widget.onProposalAccepted(
            proposal); // Pass the proposal data to the callback
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
    return _prefsInitialized
        ? Scaffold(
            backgroundColor: Colors.grey[100],
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _showProposalDialog(context);
              },
              child: Icon(Icons.add),
            ),
            appBar: AppBar(
              backgroundColor: Color(0xFF176B87),
              elevation: 0,
              titleSpacing: 0,
              title: Row(
                children: [
                  Text('Proposals'),
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
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Spacer(flex: 1),
                      Expanded(
                        flex: 1,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _proposals.length,
                          itemBuilder: (context, index) {
                            return _buildProposalCard(_proposals[index]);
                          },
                        ),
                      ),
                      Spacer(flex: 1),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          )
        : Center(child: CircularProgressIndicator());
  }
}
