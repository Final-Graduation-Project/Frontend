import 'package:flutter/material.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
               backgroundColor: Color(0xFFB4D4FF),

      appBar: AppBar(
               backgroundColor: Color(0xFFEEF5FF),

        title: Text('Welcome to Student Digital Guide'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              // Handle search action
            },
            icon: Icon(Icons.search),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
            child: Text("Log Out"),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFEEF5FF),
              ),
              child: Text(
                'features we Provide ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: Icon(Icons.calendar_month),
              title: Text('Event Calendar'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/Eve');
              },
            ),
            // for chatbot 
            ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: Icon(Icons.person),
              title: Text('Chatbot'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/chatbot');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: Icon(Icons.post_add),
              title: Text('Proposal'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/proposal');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: Icon(Icons.chat),
              title: Text('Chat'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/Chat');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: Icon(Icons.group),
              title: Text('Groups'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/groups');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: Icon(Icons.contact_mail),
              title: Text('Contact Us'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/contactus');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: Icon(Icons.info),
              title: Text('About Us'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/aboutus');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [ 
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/Chat');
            },
            child: Text("Chat"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/groups');
            },
            child: Text("Groups"),
          ),
        ],
      ),
    );
  }
}