import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> requestPermissions() async {
    if (!kIsWeb) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        if (await Permission.storage.request().isGranted) {
          print('Storage permission granted.');
        } else {
          print('Storage permission denied.');
        }
      }
    }
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
          final imageUrl = message['imageUrl'] != null
              ? 'https://localhost:7025/' + message['imageUrl']
              : null;
          fetchedMessages.add({
            'id': message['messageId'],
            'content': message['content'] ?? 'No content',
            'imageUrl': imageUrl,
            'time': DateTime.parse(message['timeSent'])
                .toLocal()
                .toString()
                .substring(11, 16),
            'isSentByMe': (message['senderId'].toString() == currentUser),
            'isImage': message['isImage'] ?? false,
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

  Future<void> sendMessage(String message,
      {String? imageUrl, bool isImage = false}) async {
    final String? receiverId = widget.user['concilID']?.toString() ??
        widget.user['teacherID']?.toString() ??
        widget.user['studentID']?.toString();

    if (receiverId != null) {
      final Uri uri = Uri.parse('https://localhost:7025/api/Messages');

      final Map<String, dynamic> requestData = {
        'senderId': int.parse(widget.currentUser),
        'receiverId': int.parse(receiverId),
        'content': message,
        'imageUrl': imageUrl ?? '',
        'sentAt': DateTime.now().toUtc().toIso8601String(),
        'isImage': isImage,
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
              'imageUrl': imageUrl,
              'time': DateTime.now().toLocal().toString().substring(11, 16),
              'isSentByMe': true,
              'isImage': isImage,
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

  Future<void> pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          // For web, use http package to upload the image
          final uri =
              Uri.parse('https://localhost:7025/api/Messages/UploadImage');
          final request = http.MultipartRequest('POST', uri)
            ..files.add(await http.MultipartFile.fromPath(
              'file',
              pickedFile.path,
              contentType: MediaType('image', 'jpeg'),
            ));

          final streamedResponse = await request.send();
          final response = await http.Response.fromStream(streamedResponse);

          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            final imageUrl = responseData['imageUrl'];
            await sendMessage('', imageUrl: imageUrl, isImage: true);
          } else {
            print('Error uploading image: ${response.statusCode}');
            print('Response body: ${response.body}');
          }
        } else {
          // For mobile and desktop, use dio package to upload the image
          final String fileName = pickedFile.path.split('/').last;
          final FormData formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(pickedFile.path,
                filename: fileName),
          });

          final Response response = await _dio.post(
            'https://localhost:7025/api/Messages/UploadImage',
            data: formData,
          );

          if (response.statusCode == 200) {
            final responseData = response.data;
            final imageUrl = responseData['imageUrl'];
            await sendMessage('', imageUrl: imageUrl, isImage: true);
          } else {
            print('Error uploading image: ${response.statusCode}');
            print('Response body: ${response.data}');
          }
        }
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking or uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userName = widget.user['concilName'] ??
        widget.user['teachername'] ??
        widget.user['studentName'] ??
        'Unknown';
    final String lastSeen = widget.user['lastSeen'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB4D4FF),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userName),
          ],
        ),
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
                                if (message['isImage'] &&
                                    message['imageUrl'] != null)
                                  Image.network(
                                    message['imageUrl'],
                                    fit: BoxFit.cover,
                                    width: 150,
                                    height: 150,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Text(
                                          'Image could not be loaded: $error');
                                    },
                                  )
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
                              onPressed: pickAndUploadImage,
                              icon: Icon(Icons.image),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.camera_alt),
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

  Future<void> showDeleteConfirmationDialog(
      BuildContext context, int messageId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد أنك تريد حذف هذه الرسالة؟'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await deleteMessage(messageId);
    }
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

  Future<void> deleteMessage(int? messageId) async {
    if (messageId == null) {
      print('Error: Cannot delete message with null ID.');
      return;
    }

    final Uri uri = Uri.parse(
        'https://localhost:7025/api/Messages/DeleteMessage/$messageId');

    try {
      final http.Response response = await http.delete(uri);

      if (response.statusCode == 200) {
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

  Future<void> editMessage(int? messageId, String newContent) async {
    if (messageId == null) {
      print('Error: Cannot edit message with null ID.');
      return;
    }

    final Uri uri = Uri.parse(
        'https://localhost:7025/api/Messages/UpdateMessage/$messageId');

    final Map<String, dynamic> requestData = {
      'messageId': messageId,
      'content': newContent,
      'imageUrl':
          '' // Add ImageUrl field with an empty string or appropriate value
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
