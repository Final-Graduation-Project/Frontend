// chatPage.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/ChatScreen.dart';

class chatPage extends StatefulWidget {
  const chatPage({Key? key, this.userId}) : super(key: key);

  final int? userId;

  @override
  State<chatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<chatPage> {
  TextEditingController idController = TextEditingController();
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final Uri uri = Uri.parse(
        'https://localhost:7025/api/concilMember/GetAllConcilMembers');
    try {
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> userData = jsonDecode(response.body);
        setState(() {
          users = userData;
        });
      } else {
        print('Error fetching users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Enter ID",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.barcode_reader),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    TextField(
                      controller: idController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.arrow_forward),
                        hintText: "Enter ID",
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                      onPressed: () {},
                      child: Center(
                        child: Text("Create Chat"),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Icon(Icons.chat),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFFB4D4FF),
        title: const Text('Chat Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final userName = user['name'] ??
                      'Unknown'; // Get user's name from the user object
                  return Card(
                    color: Color.fromARGB(255, 19, 179, 207),
                    child: ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            currentUser: {
                              'id': widget
                                  .userId, // Use widget.userId as senderId
                              'name': 'Current User',
                            },
                            user: user,
                            userName: userName,
                          ),
                        ),
                      ),
                      title: Text(user['ConcilName'] ?? 'Unknown'),
                      subtitle: Text("Last message"),
                      trailing: Badge(
                        backgroundColor: Color.fromARGB(255, 56, 122, 207),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        label: Text("3"),
                        largeSize: 30,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
