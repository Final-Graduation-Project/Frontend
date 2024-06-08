import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Login.dart';
import 'package:flutter_application_1/course.dart';
import 'package:flutter_application_1/proposal.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);
  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  String? userName;
  String? userEmail;
  String? userRole;
  String? userId;
  List<Event> _events = [];
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool isMobile = false;
  TextEditingController _searchController = TextEditingController();
  int _selectedOption = 1;
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  List<OfficeHour> _filteredOfficeHours = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadEvents();
    _loadCourses();
  }

  Future<void> clearSpecificPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName');
    userEmail = prefs.getString('userEmail');
    userRole = prefs.getString('userRole');
    userId = prefs.getString('userId');
    if (userRole == null) {
      Navigator.pushNamed(context, '/login');
    }
    setState(() {}); // Update the state after fetching user data
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsJson = prefs.getString('events');
    if (eventsJson != null) {
      setState(() {
        _events = (json.decode(eventsJson) as List)
            .map((e) => Event.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String eventsJson =
        json.encode(_events.map((e) => e.toJson()).toList());
    await prefs.setString('events', eventsJson);
  }

  Future<void> _loadCourses() async {
    final String response = await rootBundle.loadString('files/courses.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      _courses = data.map((json) => Course.fromJson(json)).toList();
    });
  }

  Future<void> _fetchOfficeHours(String instructor) async {
    try {
      final response = await http.get(Uri.parse('https://localhost:7025/api/OfficeHour/GetOfficeHour?TeacherName=$instructor'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _filteredOfficeHours = [OfficeHour.fromJson(data)];
        });
      } else {
        throw Exception('Failed to load office hours. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching office hours: $e');
      throw Exception('Error fetching office hours');
    }
  }

  void _showUserDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFEEF5FF),
          title: Text('User Details', style: TextStyle(color: Color(0xFF176B87))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: Color(0xFF176B87)),
              Text('Name: $userName', style: TextStyle(color: Color(0xFF176B87))),
              Divider(color: Color(0xFF176B87)),
              Text('Email: $userEmail', style: TextStyle(color: Color(0xFF176B87))),
              Divider(color: Color(0xFF176B87)),
              Text('Role: $userRole', style: TextStyle(color: Color(0xFF176B87))),
              Divider(color: Color(0xFF176B87)),
              Text('ID: $userId', style: TextStyle(color: Color(0xFF176B87))),
              Divider(color: Color(0xFF176B87)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: TextStyle(color: Color(0xFF176B87))),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    final url = Uri.parse('https://localhost:7025/api/Student/logout');
    final response = await http.get(
      url,
      headers: {'accept': '*/*'},
    );

    if (response.statusCode == 200) {
      print('Logout successful');
      clearSpecificPreference();
      Navigator.pushNamed(context, '/');
    } else {
      print(response.body);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Logout Failed'),
          content: Text(response.body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  bool _dateHasEvent(DateTime date) {
    return _events.any((event) => isSameDay(event.date, date));
  }

  List<Event> _visibleEvents() {
    return _events.where((event) {
      return event.date.difference(_focusedDay).inDays.abs() < 7;
    }).toList();
  }

  void _showSearchResultsDialog() {
    if (_searchController.text.isEmpty) {
      return;
    }

    if (_selectedOption == 1) {
      _filteredCourses = _courses.where((course) =>
          course.nameOfCourse.toLowerCase() == _searchController.text.toLowerCase()).toList();
    } else {
      _fetchOfficeHours(_searchController.text);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Results'),
          content: _selectedOption == 1
              ? _filteredCourses.isNotEmpty
              ? ListView.builder(
            itemCount: _filteredCourses.length,
            itemBuilder: (context, index) {
              final course = _filteredCourses[index];
              return ListTile(
                title: Text('Course Name: ${course.nameOfCourse}', style: TextStyle(fontSize: 18)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Section: ${course.sec}', style: TextStyle(fontSize: 16)),
                    Text('Instructor: ${course.nameOfInstructor}', style: TextStyle(fontSize: 16)),
                    Text('Days: ${course.days}', style: TextStyle(fontSize: 16)),
                    Text('Time: ${course.time}', style: TextStyle(fontSize: 16)),
                    Text('Place: ${course.place}', style: TextStyle(fontSize: 16)),
                  ],
                ),
                isThreeLine: true,
              );
            },
          )
              : Text('No course found', style: TextStyle(fontSize: 18))
              : _filteredOfficeHours.isNotEmpty
              ? ListView.builder(
            itemCount: _filteredOfficeHours.length,
            itemBuilder: (context, index) {
              final officeHour = _filteredOfficeHours[index];
              return ListTile(
                title: Text('Instructor: ${_searchController.text}', style: TextStyle(fontSize: 18)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Days: ${officeHour.teacherFreeDay}', style: TextStyle(fontSize: 16)),
                    Text('Start Time: ${officeHour.teacherStartFreeTime}', style: TextStyle(fontSize: 16)),
                    Text('End Time: ${officeHour.teacherEndFreeTime}', style: TextStyle(fontSize: 16)),
                    Text('Building: ${officeHour.buildingName}', style: TextStyle(fontSize: 16)),
                    Text('Room: ${officeHour.roomNumber}', style: TextStyle(fontSize: 16)),
                  ],
                ),
                isThreeLine: true,
              );
            },
          )
              : Text('No office hours found', style: TextStyle(fontSize: 18)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserData? userData =
        ModalRoute.of(context)!.settings.arguments as UserData?;
    if (userData == null) {
      // Navigate to login page if userData is null
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
    isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF176B87),
        automaticallyImplyLeading: false, // Remove the back button
        title: Text('Welcome to Student Digital Guide', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/hotnews');
            },
            child: Text("Hot News", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/proposal');
            },
            child: Text("Proposals", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      drawer: isMobile
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 152, 178, 213),
                    ),
                    child: GestureDetector(
                      onTap: _showUserDetails,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, size: 40, color: Colors.black),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(userName ?? '', style: TextStyle(color: Colors.black, fontSize: 18)),
                              Text(userRole ?? '', style: TextStyle(color: Colors.black, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text('Proposals'),
                    onTap: () => Navigator.pushNamed(context, '/proposal'),
                  ),
                  ListTile(
                    leading: Icon(Icons.chat),
                    title: Text('Chat'),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/Chatpage',
                      arguments: userData,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.book),
                    title: Text('Courses'),
                    onTap: () => Navigator.pushNamed(context, '/course'),
                  ),
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Events'),
                    onTap: () => Navigator.pushNamed(context, '/Eve'),
                  ),
                  //chatbot 
                  ListTile(
                    leading: Icon(Icons.chat),
                    title: Text('Chatbot'),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/chatbot',
                    ),
                  ),
                  //map
                  ListTile(
                    leading: Icon(Icons.map),
                    title: Text('Map'),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/map',
                    ),
                  ),

                  Divider(),
                  ExpansionTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    children: [
                      ListTile(
                        leading: Icon(Icons.info),
                        title: Text('About Us'),
                        onTap: () => Navigator.pushNamed(context, '/aboutus'),
                      ),
                      ListTile(
                        leading: Icon(Icons.contact_mail),
                        title: Text('Contact Us'),
                        onTap: () => Navigator.pushNamed(context, '/contactus'),
                      ),
                      ListTile(
                        leading: Icon(Icons.lock),
                        title: Text('Change Password'),
                        onTap: () => Navigator.pushNamed(context, '/changepassword'),
                      ),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Log Out'),
                        onTap: () {
                          _logout();
                          Navigator.pushNamed(context, '/');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 250,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(0xFFEEF5FF),
                    ),
                    child: GestureDetector(
                      onTap: _showUserDetails,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, size: 40, color: Colors.black),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(userName ?? '', style: TextStyle(color: Colors.black, fontSize: 18)),
                              Text(userRole ?? '', style: TextStyle(color: Colors.black, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  
                  
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text('Proposals'),
                    onTap: () => Navigator.pushNamed(context, '/proposal'),
                  ),
                  ListTile(
                    leading: Icon(Icons.chat),
                    title: Text('Chat'),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/Chatpage',
                      arguments: userData,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.book),
                    title: Text('Courses'),
                    onTap: () => Navigator.pushNamed(context, '/course'),
                  ),
                 // event calendar 
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Events'),
                    onTap: () => Navigator.pushNamed(context, '/Eve'),
                  ),
                  //chatbot 
                  ListTile(
                    leading: Icon(Icons.chat),
                    title: Text('Chatbot'),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/chatbot',
                      arguments: userData,
                    ),
                  ),
                  //map 
                  ListTile(
                    leading: Icon(Icons.map),
                    title: Text('Map'),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/map',
                    ),
                  ),
                 
                  Divider(),
                  ExpansionTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    children: [
                      ListTile(
                        leading: Icon(Icons.info),
                        title: Text('About Us'),
                        onTap: () => Navigator.pushNamed(context, '/aboutus'),
                      ),
                      ListTile(
                        leading: Icon(Icons.contact_mail),
                        title: Text('Contact Us'),
                        onTap: () => Navigator.pushNamed(context, '/contactus'),
                      ),
                      ListTile(
                        leading: Icon(Icons.lock),
                        title: Text('Change Password'),
                        onTap: () => Navigator.pushNamed(context, '/changepassword'),
                      ),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Log Out'),
                        onTap: () {
                          _logout();
                          Navigator.pushNamed(context, '/');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search courses, office hours...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            _showSearchResultsDialog();
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2021, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      calendarFormat: _calendarFormat,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                        setState(() {});
                      },
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (_dateHasEvent(date)) {
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xFF86B6F6).withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                date.day.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'UPCOMING EVENTS for this week!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF176B87),
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  Container(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _visibleEvents().map((event) {
                        return _buildEventCard(event.title, Icons.event);
                      }).toList(),
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'HOT NEWS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF176B87),
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  Container(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildNewsCard('News 1', Icons.newspaper),
                        _buildNewsCard('News 2', Icons.newspaper),
                        _buildNewsCard('News 3', Icons.newspaper),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(String title, IconData icon) {
    return Card(
      child: Container(
        width: 160,
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
        ),
      ),
    );
  }

  Widget _buildNewsCard(String title, IconData icon) {
    return Card(
      child: Container(
        width: 160,
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
        ),
      ),
    );
  }
}

class Event {
  DateTime date;
  String title;
  String? location;
  String? imagePath;
  TimeOfDay? time;

  Event({
    required this.date,
    required this.title,
    this.location,
    this.imagePath,
    this.time,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'title': title,
        'location': location,
        'imagePath': imagePath,
        'hour': time?.hour,
        'minute': time?.minute,
      };

  static Event fromJson(Map<String, dynamic> json) => Event(
        date: DateTime.parse(json['date']),
        title: json['title'],
        location: json['location'],
        imagePath: json['imagePath'],
        time: json['hour'] != null
            ? TimeOfDay(hour: json['hour'], minute: json['minute'])
            : null,
      );
}
