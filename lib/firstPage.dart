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
               backgroundColor: Color(0xFF176B87),

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
                color: Color(0xFF176B87),
              ),
              child: Text(
                'features we Provide ',
                style: TextStyle(
                  color: Colors.white,
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
                Navigator.pushNamed(context, '/EventPage');
                
                // Navigate to event calendar page
              },
            ),
            // Add more ListTile widgets for additional options
          ],
        ),
      ),
      body: Column(
        children: [
        ],
      ),
    );
  }
}