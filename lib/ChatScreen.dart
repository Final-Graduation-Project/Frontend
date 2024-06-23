import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final String currentUser;
  final String userName;

  const ChatScreen({
    Key? key,
    required this.user,
    required this.currentUser,
    required this.userName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _webImage; // For web image handling

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final String currentUser = widget.currentUser;
    final String? councilId = widget.user['concilID']?.toString();
    final String? teacherId = widget.user['teacherID']?.toString();
    final String? studentId = widget.user['studentID']?.toString();

    Uri uri;
    if (councilId != null) {
      uri = Uri.parse(
          'https://localhost:7025/api/Messages/$currentUser/$councilId');
    } else if (teacherId != null) {
      uri = Uri.parse(
          'https://localhost:7025/api/Messages/$currentUser/$teacherId');
    } else if (studentId != null) {
      uri = Uri.parse(
          'https://localhost:7025/api/Messages/$currentUser/$studentId');
    } else {
      print('User type is not specified correctly.');
      return;
    }

    try {
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        List<Map<String, dynamic>> fetchedMessages = [];
        for (var message in responseData) {
          fetchedMessages.add({
            'id': message['messageId'],
            'content': message['content'] ?? 'No content',
            'imagePath': message['imageUrl'],
            'time': DateTime.parse(message['timeSent'])
                .toLocal()
                .toString()
                .substring(11, 16),
            'isSentByMe': (message['senderId'].toString() == currentUser),
          });
        }

        setState(() {
          messages = fetchedMessages;
        });
      } else {
        print('Error fetching messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> sendMessage(String message, {String? imagePath}) async {
    final String? receiverId = widget.user['concilID']?.toString() ??
        widget.user['teacherID']?.toString() ??
        widget.user['studentID']?.toString();

    if (receiverId != null) {
      final Uri uri = Uri.parse('https://localhost:7025/api/Messages');

      final Map<String, dynamic> requestData = {
        'senderId': int.parse(widget.currentUser),
        'receiverId': int.parse(receiverId),
        'content': message,
        'imageUrl': imagePath ?? '',
        'sentAt': DateTime.now().toUtc().toIso8601String(),
      };

      try {
        final http.Response response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );

        if (response.statusCode == 200) {
          setState(() {
            messages.insert(0, {
              'id': jsonDecode(response.body)['messageId'],
              'content': message,
              'imagePath': imagePath,
              'time': DateTime.now().toLocal().toString().substring(11, 16),
              'isSentByMe': true,
            });
          });
          messageController.clear();
        } else {
          print('Error sending message: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('Receiver ID is null');
    }
  }

  Future<void> deleteMessage(int messageId) async {
    final Uri uri = Uri.parse(
        'https://localhost:7025/api/Messages/DeleteMessage/$messageId');

    try {
      final http.Response response = await http.delete(uri);

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          messages.removeWhere((message) => message['id'] == messageId);
        });
      } else {
        print('Error deleting message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> showDeleteConfirmationDialog(
      BuildContext context, int messageId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this message?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await deleteMessage(messageId);
    }
  }

  Future<void> pickAndSelectImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
          });
          await sendMessage('', imagePath: base64Encode(bytes));
        } else {
          setState(() {
            _selectedImage = pickedFile;
          });
          await sendMessage('', imagePath: pickedFile.path);
        }
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Widget _handlePreview(String? imagePath) {
    if (imagePath != null && imagePath.isNotEmpty) {
      if (kIsWeb) {
        try {
          return Image.memory(
            base64Decode(imagePath),
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          );
        } catch (e) {
          return const Text('Failed to load image.');
        }
      } else {
        return Image.file(
          File(imagePath),
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        );
      }
    } else {
      return const Text('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userName = widget.user['concilName'] ??
        widget.user['teachername'] ??
        widget.user['studentName'] ??
        'Unknown';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                        if (message['isSentByMe'])
                          Row(
                            mainAxisAlignment: message['isSentByMe']
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              if (message['isSentByMe'])
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: Text("Edit"),
                                      value: "edit",
                                    ),
                                    PopupMenuItem(
                                      child: Text("Delete"),
                                      value: "delete",
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == "edit") {
                                      showEditMessageDialog(
                                          context, message['id']);
                                    } else if (value == "delete") {
                                      showDeleteConfirmationDialog(
                                          context, message['id']);
                                    }
                                  },
                                  icon: Icon(Icons.more_vert),
                                ),
                            ],
                          ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(
                                  message['isSentByMe'] ? 16 : 0),
                              bottomRight: Radius.circular(
                                  message['isSentByMe'] ? 0 : 16),
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          color: message['isSentByMe']
                              ? Color(0xFF4F9BFF)
                              : Colors.grey[400],
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width / 2,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (message['imagePath'] != null &&
                                      message['imagePath']!.isNotEmpty)
                                    _handlePreview(message['imagePath'])
                                  else
                                    Text(
                                      message['content'] ?? 'No Content',
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
                                      if (message['isSentByMe'])
                                        Icon(
                                          Icons.done_outline_outlined,
                                          color: Colors.blueAccent,
                                          size: 18,
                                        ),
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
                                onPressed: pickAndSelectImage,
                                icon: Icon(Icons.image),
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
      ),
    );
  }

  Future<void> showEditMessageDialog(
      BuildContext context, int messageId) async {
    final TextEditingController editController = TextEditingController();
    editController.text =
        messages.firstWhere((msg) => msg['id'] == messageId)['content'];

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Message'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: 'Enter your message...'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await editMessage(messageId, editController.text);
    }
  }

  Future<void> editMessage(int messageId, String newContent) async {
    final Uri uri = Uri.parse(
        'https://localhost:7025/api/Messages/UpdateMessage/$messageId');

    final Map<String, dynamic> requestData = {
      'messageId': messageId,
      'content': newContent,
      'imageUrl': '' // Ensure imageUrl field is set appropriately
    };

    try {
      final http.Response response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        setState(() {
          final index =
              messages.indexWhere((message) => message['id'] == messageId);
          if (index != -1) {
            messages[index]['content'] = newContent;
          } else {
            print(
                'Error: Message with ID $messageId not found in local state.');
          }
        });
        print('Message updated successfully.');
      } else {
        print(
            'Error editing message: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
