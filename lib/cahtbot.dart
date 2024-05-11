import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatBot extends StatefulWidget {
  @override
  _ChatBotState createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();

  static const String dialogflowToken = 'YOUR_DIALOGFLOW_TOKEN';
  static const String dialogflowUrl =
      'https://dialogflow.googleapis.com/v2/projects/YOUR_PROJECT_ID/agent/sessions/session-id:detectIntent';

  void _handleSubmitted(String text) async {
    _textController.clear();
    ChatMessage message = ChatMessage(
      text: text,
      isUserMessage: true,
    );
    setState(() {
      _messages.insert(0, message);
    });

    String response = await _getDialogFlowResponse(text);

    ChatMessage botReply = ChatMessage(
      text: response,
      isUserMessage: false,
    );
    setState(() {
      _messages.insert(0, botReply);
    });
  }

  Future<String> _getDialogFlowResponse(String query) async {
    final response = await http.post(
      Uri.parse(dialogflowUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'queryInput': {
          'text': {
            'text': query,
            'languageCode': 'en',
          },
        }
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return data['queryResult']['fulfillmentText'];
    } else {
      return 'Error communicating with chatbot';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatBot'),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _messages[index],
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration.collapsed(
                  hintText: "Send a message",
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUserMessage;

  ChatMessage({required this.text, required this.isUserMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      alignment: isUserMessage ? Alignment.topRight : Alignment.topLeft,
      child: Text(
        text,
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }
}
