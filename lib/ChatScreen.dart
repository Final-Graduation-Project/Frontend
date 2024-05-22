import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final dynamic currentUser; // Add currentUser parameter to hold sender info
  final dynamic user;
  final String userName; // Add userName parameter to hold the name of the user

  const ChatScreen({
    Key? key,
    required this.currentUser,
    required this.user,
    required this.userName, // Define userName as a required parameter
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = []; // List to store messages

  Future<void> sendMessage(String message) async {
    if (widget.user != null && widget.user['concilID'] != null) {
      final Uri uri = Uri.parse('https://localhost:7025/api/Messages');

      final Map<String, dynamic> requestData = {
        'senderId': widget.currentUser['id'], // Use senderId from currentUser
        'receiverId':
            widget.user['concilID'], // Use the ID of the selected user
        'content': message,
      };

      try {
        final http.Response response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );

        if (response.statusCode == 200) {
          // Message sent successfully
          print('Message sent successfully');

          // Add the message to the list and update the state
          setState(() {
            messages.insert(0, {
              'content': message,
              'time': DateTime.now().toLocal().toString().substring(11, 16),
              'isSentByMe': true
            });
          });

          // Clear the message input field
          messageController.clear();
        } else {
          // Handle errors
          print('Error sending message: ${response.statusCode}');
        }
      } catch (e) {
        // Handle network or other errors
        print('Error: $e');
      }
    } else {
      print('User is null or user ID is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userName =
        widget.user != null && widget.user['ConcilMemberName'] != null
            ? widget.user['ConcilMemberName']
            : 'Unknown';
    final String lastSeen =
        widget.user != null && widget.user['lastSeen'] != null
            ? widget.user['lastSeen']
            : 'Unknown';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB4D4FF),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userName),
            Text(
              "Last Seen $lastSeen",
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.copy)),
          IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Row(
                    mainAxisAlignment: message['isSentByMe']
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      message['isSentByMe']
                          ? IconButton(onPressed: () {}, icon: Icon(Icons.edit))
                          : SizedBox(),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft:
                                Radius.circular(message['isSentByMe'] ? 16 : 0),
                            bottomRight:
                                Radius.circular(message['isSentByMe'] ? 0 : 16),
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        color: message['isSentByMe']
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width / 2,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['content'],
                                  style: TextStyle(color: Colors.white),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      message['time'],
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                    SizedBox(width: 6),
                                    message['isSentByMe']
                                        ? Icon(
                                            Icons.done_outline_outlined,
                                            color: Colors.blueAccent,
                                            size: 18,
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: TextField(
                      controller: messageController,
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.emoji_emotions),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.attach_file),
                            ),
                          ],
                        ),
                        contentPadding: EdgeInsets.all(16),
                        hintText: "Type your message",
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Color(0xFFB4D4FF),
                  child: IconButton(
                    onPressed: () {
                      final message = messageController.text;
                      if (message.isNotEmpty) {
                        sendMessage(message);
                      }
                    },
                    icon: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
