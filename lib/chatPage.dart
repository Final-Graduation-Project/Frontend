import 'package:flutter/material.dart';
import 'package:flutter_application_1/Login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/ChatScreen.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController idController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  Map<String, int> unreadMessagesCount = {};

  Future<void> fetchUsersAndStaff(String currentUser) async {
    final Uri councilUri = Uri.parse(
        'https://localhost:7025/api/concilMember/GetAllConcilMembers');
    final Uri staffUri =
        Uri.parse('https://localhost:7025/api/StaffMember/GetAllStaffMember');

    try {
      final councilResponse = await http.get(councilUri);
      final staffResponse = await http.get(staffUri);

      if (councilResponse.statusCode == 200 &&
          staffResponse.statusCode == 200) {
        final List<dynamic> councilData = jsonDecode(councilResponse.body);
        final List<dynamic> staffData = jsonDecode(staffResponse.body);

        final List<dynamic> allUsersData = [...councilData, ...staffData];

        bool isCouncilOrTeacher = allUsersData.any((user) =>
            user['concilID'].toString() == currentUser ||
            user['teacherID'].toString() == currentUser);

        List<dynamic> updatedUsers = [];

        if (isCouncilOrTeacher) {
          // Fetch users who sent messages to the current user
          final Uri messagesUri = Uri.parse(
              'https://localhost:7025/api/Messages/GetSendersByReceiverId/$currentUser');

          try {
            final messagesResponse = await http.get(messagesUri);
            final List<dynamic> messagesData =
                jsonDecode(messagesResponse.body);

            print("Messages Data: $messagesData");

            for (var senderId in messagesData) {
              if (senderId != null) {
                senderId = senderId.toString();
                print("Processing senderId: $senderId");

                // Check if the sender is not a council member or teacher
                if (!allUsersData.any((user) =>
                    user['concilID'].toString() == senderId ||
                    user['teacherID'].toString() == senderId)) {
                  // Fetch information of the sender
                  final Uri senderUri = Uri.parse(
                      'https://localhost:7025/api/Student/GetStudent/$senderId');
                  try {
                    final senderResponse = await http.get(senderUri);

                    if (senderResponse.statusCode == 200) {
                      final Map<String, dynamic> senderData =
                          jsonDecode(senderResponse.body);
                      updatedUsers.add(senderData);
                    } else {
                      print(
                          'Error fetching sender data: ${senderResponse.statusCode}');
                    }
                  } catch (e) {
                    print('Error fetching sender data: $e');
                  }
                }
              } else {
                print('SenderId is null');
              }
            }
          } catch (e) {
            print('Error fetching messages: $e');
          }
        }

        // Add council members and teachers to the list
        updatedUsers.addAll(allUsersData);

        // Filter out the current user from the list
        updatedUsers = updatedUsers
            .where((user) =>
                user['concilID']?.toString() != currentUser &&
                user['teacherID']?.toString() != currentUser &&
                user['studentID']?.toString() != currentUser)
            .toList();

        setState(() {
          users = updatedUsers;
          filteredUsers = users;
        });
      } else {
        print(
            'Error fetching users: ${councilResponse.statusCode}, ${staffResponse.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Defer fetching users until currentUser is obtained
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final UserData userData =
          ModalRoute.of(context)!.settings.arguments as UserData;
      fetchUsersAndStaff(userData.id);
    });
  }

  void filterUsers(String query) {
    setState(() {
      filteredUsers = users
          .where((user) => (user['concilName'] ??
                  user['teachername'] ??
                  user['studentName'] ??
                  'Unknown')
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserData? userData =
        ModalRoute.of(context)?.settings.arguments as UserData?;
    if (userData == null) {
      // Navigate to login page if userData is null
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
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
                        Text("Enter ID",
                            style: Theme.of(context).textTheme.bodyText1),
                        Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.qr_code_scanner),
                          color: Theme.of(context).primaryColor,
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
                        backgroundColor: Theme.of(context).primaryColorLight,
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
            TextField(
              controller: searchController,
              onChanged: filterUsers,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search users...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  final userName = user['concilName'] ??
                      user['teachername'] ??
                      user['studentName'] ??
                      'Unknown';
                  return Card(
                    color: Color.fromARGB(255, 19, 179, 207),
                    child: ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            currentUser: userData.id,
                            user: user,
                            userName: userName,
                          ),
                        ),
                      ),
                      title: Text(userName),
                      trailing: Badge(
                        backgroundColor: Color.fromARGB(255, 56, 122, 207),
                        padding: EdgeInsets.symmetric(horizontal: 12),
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
