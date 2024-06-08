import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatBot extends StatefulWidget {
  @override
  _ChatBotState createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  @override
  void initState() {
    super.initState();
   _fetchUserData();
  }

  final List<ChatMessage> _messages = <ChatMessage>[
    ChatMessage(
      text: "Hi, I am here to help you.",
      isUserMessage: false,
    )
  ];
  final TextEditingController _textController = TextEditingController();

  static const apiKey = "AIzaSyDz8eKOlC7M0H6CQuwFWxpoL0SRnibD-aw";
  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  void _handleSubmitted(String text) async {
    _textController.clear();
    ChatMessage message = ChatMessage(
      text: text,
      isUserMessage: true,
    );
    setState(() {
      _messages.insert(0, message);
      _messages.insert(
          0,
          ChatMessage(
            text:
                "I am looking for the best answer for you, please wait.......",
            isUserMessage: false,
          ));
    });

    String response = await _getGenerativeAIResponse(text);

    setState(() {
      // Remove the "Please wait..." message
      _messages.removeAt(0);
      // Add the bot's response
      _messages.insert(
          0,
          ChatMessage(
            text: response,
            isUserMessage: false,
          ));
    });
  }

  Future<String> _getGenerativeAIResponse(String query) async {
    try {
      final content = [Content.text(query)];
      final response = await model.generateContent(content);
      return response.text ?? 'No response from the AI';
    } catch (error) {
      print('Error generating content: $error');
      return 'Error: Unable to generate response';
    }
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole');
    if (role == null) {
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Color(0xFF176B87),
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [SizedBox(width: 10), Text('ChatBot')],
        ),
      ),
      body:  Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(flex: 1,),
            Expanded(
              flex: 2,
              child: Row(
                
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(flex: 1,),
                  Expanded(
                    flex: 2,
                child: ListView.builder(
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (_, int index) => _messages[index],
                ),
              ),
              Spacer(flex: 1,),
                ],
              ),
            ),
           
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
              child: Row(
                children: [
                  Spacer(flex: 1,),
                  Expanded(
                    flex: 2,
                    child: Container(
                      
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: _buildTextComposer(),
                    ),
                  ),
                  Spacer(flex: 1,),
                ],
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
       
        height: 60,
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8),
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  hintText: "Send a message"),
                  
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
      child: Container(
        decoration: BoxDecoration(
          color: isUserMessage ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.all(10.0),
        child: Text(
          text,
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
