import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Login.dart';
import 'package:flutter_application_1/course.dart';
import 'package:flutter_application_1/proposal.dart';
import 'package:image_picker/image_picker.dart';
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
  String? userProfilePicture; // New field for profile picture
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

  // News-related fields
  final List<Map<String, String>> _newsList = [];
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadEvents();
    _loadCourses();
    _loadNews();
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
    userProfilePicture =
        prefs.getString('userProfilePicture'); // Load profile picture
    if (userRole == null) {
      Navigator.pushNamed(context, '/login');
    }
    setState(() {}); // Update the state after fetching user data
  }

  Future<void> _saveUserProfilePicture(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userProfilePicture', imagePath);
    setState(() {
      userProfilePicture = imagePath;
    });
  }

  Future<void> _loadEvents() async {
    final url = 'https://localhost:7025/api/EventControllercs/GetAllEvent';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> eventsJson = json.decode(response.body);
        setState(() {
          _events = eventsJson.map((e) => Event.fromJson(e)).toList();
          _events.sort((a, b) => a.date.compareTo(b.date));
        });
        _saveEvents();
      } else {
        print('Failed to load events: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while loading events: $e');
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
      final response = await http.get(Uri.parse(
          'https://localhost:7025/api/OfficeHour/GetOfficeHour?TeacherName=$instructor'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _filteredOfficeHours = [OfficeHour.fromJson(data)];
        });
      } else {
        throw Exception(
            'Failed to load office hours. Status code: ${response.statusCode}');
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
          title:
              Text('User Details', style: TextStyle(color: Color(0xFF176B87))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (userProfilePicture != null && userProfilePicture!.isNotEmpty)
                Image.memory(base64Decode(userProfilePicture!),
                    height: 100, fit: BoxFit.cover)
              else
                Icon(Icons.person, size: 100),
              TextButton(
                onPressed: _editProfilePicture,
                child: Text('Edit Picture',
                    style: TextStyle(color: Color(0xFF176B87))),
              ),
              Divider(color: Color(0xFF176B87)),
              Text('Name: $userName',
                  style: TextStyle(color: Color(0xFF176B87))),
              Divider(color: Color(0xFF176B87)),
              Text('Email: $userEmail',
                  style: TextStyle(color: Color(0xFF176B87))),
              Divider(color: Color(0xFF176B87)),
              Text('Role: $userRole',
                  style: TextStyle(color: Color(0xFF176B87))),
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

  Future<void> _editProfilePicture() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final String imagePath = base64Encode(await image.readAsBytes());
      await _saveUserProfilePicture(imagePath);
    }
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

  Future<void> _loadNews() async {
    final String url = 'https://localhost:7025/api/News/GetAllNews';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> newsJson = json.decode(response.body);
        setState(() {
          _newsList.addAll(newsJson.map((e) {
            return {
              'title': e['title']?.toString() ?? '',
              'description': e['description']?.toString() ?? '',
              'imageUrl': e['imagePath']?.toString() ?? '',
            };
          }).toList());
        });
      } else {
        print('Failed to load news: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while loading news: $e');
    }
  }

  Future<void> _addNews(Map<String, String> news) async {
    final String url = 'https://localhost:7025/api/News/AddNews';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(news),
      );
      if (response.statusCode == 201) {
        print('News added successfully');
        setState(() {
          _newsList.add(news);
        });
      } else {
        print('Failed to add news: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while adding news: $e');
    }
  }

  Future<void> _deleteNews(int index) async {
    final String url =
        'https://localhost:7025/api/News/DeleteNews/${_newsList[index]['id']}';
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        print('News deleted successfully');
        setState(() {
          _newsList.removeAt(index);
        });
      } else {
        print('Failed to delete news: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while deleting news: $e');
    }
  }

  void _showSearchResultsDialog() {
    if (_searchController.text.isEmpty) {
      return;
    }

    if (_selectedOption == 1) {
      _filteredCourses = _courses
          .where((course) =>
              course.nameOfCourse.toLowerCase() ==
              _searchController.text.toLowerCase())
          .toList();
    } else {
      _fetchOfficeHours(_searchController.text);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Results'),
          content: _filteredCourses.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    children: _filteredCourses.map((course) {
                      return Column(
                        children: [
                          Text('Section: ${course.sec}',
                              style: TextStyle(fontSize: 16)),
                          Text('Instructor: ${course.nameOfInstructor}',
                              style: TextStyle(fontSize: 16)),
                          Text('Days: ${course.days}',
                              style: TextStyle(fontSize: 16)),
                          Text('Time: ${course.time}',
                              style: TextStyle(fontSize: 16)),
                          Text('Place: ${course.place}',
                              style: TextStyle(fontSize: 16)),
                        ],
                      );
                    }).toList(),
                  ),
                )
              : Text('No course found', style: TextStyle(fontSize: 18)),
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

  void _showAddNewsDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add News'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final XFile? image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        selectedImage = image;
                      });
                    }
                  },
                  child: Text('Attach Image'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    selectedImage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('All fields are required.'),
                    ),
                  );
                  return;
                }

                final String imagePath =
                    base64Encode(await selectedImage!.readAsBytes());

                final news = {
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'imageUrl': imagePath,
                };

                await _addNews(news);

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showNewsDetails(Map<String, String> news) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Uint8List? imageBytes;
        if (news['imageUrl'] != null && news['imageUrl']!.isNotEmpty) {
          try {
            imageBytes = base64Decode(news['imageUrl']!);
          } catch (e) {
            print('Error decoding image: $e');
          }
        }

        return Dialog(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageBytes != null)
                  Image.memory(imageBytes,
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: MediaQuery.of(context).size.width * 0.5,
                      fit: BoxFit.cover)
                else
                  Icon(Icons.image_not_supported,
                      size: 100, color: Colors.white),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    news['title'] ?? '',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    news['description'] ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Uint8List? imageBytes;
        if (event.imagePath != null && event.imagePath!.isNotEmpty) {
          try {
            imageBytes = base64Decode(event.imagePath!);
          } catch (e) {
            print('Error decoding image: $e');
          }
        }

        return Dialog(
          child: Container(
            width: 160,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageBytes != null)
                  Image.memory(
                    imageBytes,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                else
                  Icon(Icons.image_not_supported,
                      size: 100, color: Colors.black),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Table(
                    children: [
                      TableRow(children: [
                        Text('Date:', style: TextStyle(color: Colors.black)),
                        Text(
                          '${event.date.toLocal()}'.split(' ')[0],
                          style: TextStyle(color: Colors.black),
                        ),
                      ]),
                      TableRow(children: [
                        Text('Time:', style: TextStyle(color: Colors.black)),
                        Text(
                          event.time != null
                              ? event.time!.format(context)
                              : 'N/A',
                          style: TextStyle(color: Colors.black),
                        ),
                      ]),
                      TableRow(children: [
                        Text('Location:',
                            style: TextStyle(color: Colors.black)),
                        Text(
                          event.location ?? 'N/A',
                          style: TextStyle(color: Colors.black),
                        ),
                      ]),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
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
        title: Row(
          children: [
            Text('Welcome to Student Digital Guide',
                style: TextStyle(color: Colors.white)),
            Spacer(),
            Expanded(
              child: TextField(
                onSubmitted: (query) {
                  _showSearchResultsDialog();
                },
                textInputAction: TextInputAction.go,
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search courses..',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/propstudent');
              },
              child: Text("Proposals", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      drawer: isMobile
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(0xFF176B87),
                    ),
                    child: GestureDetector(
                      onTap: _showUserDetails,
                      child: Row(
                        children: [
                          if (userProfilePicture != null &&
                              userProfilePicture!.isNotEmpty)
                            Image.memory(base64Decode(userProfilePicture!),
                                height: 50, width: 50, fit: BoxFit.cover)
                          else
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person,
                                  size: 40, color: Colors.black),
                            ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(userName ?? '',
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 255, 254, 254),
                                      fontSize: 18)),
                              Text(userRole ?? '',
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 255, 252, 252),
                                      fontSize: 14)),
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
                  ListTile(
                    leading: Icon(Icons.chat),
                    title: Text('Chatbot'),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/chatbot',
                      arguments: userData,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.map),
                    title: Text('Map'),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/map',
                    ),
                  ),
                  Divider(color: Color(0xFF176B87)),
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
                        onTap: () =>
                            Navigator.pushNamed(context, '/changepassword'),
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
              color: Color.fromARGB(255, 249, 250, 251),
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(0xFF176B87),
                    ),
                    child: GestureDetector(
                      onTap: _showUserDetails,
                      child: Row(
                        children: [
                          if (userProfilePicture != null &&
                              userProfilePicture!.isNotEmpty)
                            Image.memory(base64Decode(userProfilePicture!),
                                height: 50, width: 50, fit: BoxFit.cover)
                          else
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person,
                                  size: 40, color: Colors.black),
                            ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(userName ?? '',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 247, 245, 245),
                                      fontSize: 18)),
                              Text(userRole ?? '',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.info, color: Colors.black),
                    title: Text('Proposals',
                        style: TextStyle(color: Colors.black)),
                    onTap: () => Navigator.pushNamed(context, '/proposal'),
                  ),
                  ListTile(
                    leading: Icon(Icons.chat, color: Colors.black),
                    title: Text('Chat', style: TextStyle(color: Colors.black)),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/Chatpage',
                      arguments: userData,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.book,
                        color: Color.fromARGB(255, 10, 10, 10)),
                    title:
                        Text('Courses', style: TextStyle(color: Colors.black)),
                    onTap: () => Navigator.pushNamed(context, '/course'),
                  ),
                  ListTile(
                    leading: Icon(Icons.calendar_today, color: Colors.black),
                    title:
                        Text('Events', style: TextStyle(color: Colors.black)),
                    onTap: () => Navigator.pushNamed(context, '/Eve'),
                  ),
                  ListTile(
                    leading: Icon(Icons.chat, color: Colors.black),
                    title:
                        Text('Chatbot', style: TextStyle(color: Colors.black)),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/chatbot',
                      arguments: userData,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.map, color: Colors.black),
                    title: Text('Map', style: TextStyle(color: Colors.black)),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/map',
                    ),
                  ),
                  Divider(color: Color(0xFF176B87)),
                  ExpansionTile(
                    leading: Icon(Icons.settings, color: Colors.black),
                    title:
                        Text('Settings', style: TextStyle(color: Colors.black)),
                    children: [
                      ListTile(
                        leading: Icon(Icons.info, color: Colors.black),
                        title: Text('About Us',
                            style: TextStyle(color: Colors.black)),
                        onTap: () => Navigator.pushNamed(context, '/aboutus'),
                      ),
                      ListTile(
                        leading: Icon(Icons.contact_mail, color: Colors.black),
                        title: Text('Contact Us',
                            style: TextStyle(color: Colors.black)),
                        onTap: () => Navigator.pushNamed(context, '/contactus'),
                      ),
                      ListTile(
                        leading: Icon(Icons.lock, color: Colors.black),
                        title: Text('Change Password',
                            style: TextStyle(color: Colors.black)),
                        onTap: () =>
                            Navigator.pushNamed(context, '/changepassword'),
                      ),
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.black),
                        title: Text('Log Out',
                            style: TextStyle(color: Colors.black)),
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
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2021, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
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
                  SizedBox(height: 50),
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
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _events.map((event) {
                        return GestureDetector(
                          onTap: () {
                            _showEventDetails(event);
                          },
                          child: _buildEventCard(
                              event.title, event.imagePath ?? '', Icons.event),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Divider(color: Color(0xFF176B87)),
                  ),
                  SizedBox(height: 50),
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
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _newsList.length,
                      itemBuilder: (context, index) {
                        final news = _newsList[index];
                        return GestureDetector(
                          onTap: () {
                            _showNewsDetails(news);
                          },
                          child: _buildNewsCard(news, index),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(String title, String imageUrl, IconData icon) {
    Uint8List? imageBytes;
    if (imageUrl.isNotEmpty) {
      try {
        imageBytes = base64Decode(imageUrl);
      } catch (e) {
        print('Error decoding image: $e');
      }
    }
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageBytes != null)
            Expanded(
              child: Image.memory(imageBytes, fit: BoxFit.cover),
            )
          else
            Icon(Icons.image_not_supported),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(Map<String, String> news, int index) {
    Uint8List? imageBytes;
    if (news['imageUrl']!.isNotEmpty) {
      try {
        imageBytes = base64Decode(news['imageUrl']!);
      } catch (e) {
        print('Error decoding image: $e');
      }
    }

    return Card(
      child: Column(
        children: [
          if (imageBytes != null)
            Expanded(
              child: Image.memory(imageBytes, fit: BoxFit.cover),
            )
          else
            Icon(Icons.image_not_supported),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              news['title']!,
              style: TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteNews(index),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Event {
  int activityID;
  DateTime date;
  String title;
  String? location;
  String? imagePath;
  TimeOfDay? time;

  Event({
    required this.activityID,
    required this.date,
    required this.title,
    this.location,
    this.imagePath,
    this.time,
  });

  Map<String, dynamic> toJson() => {
        'activityID': activityID,
        'date': date.toIso8601String(),
        'title': title,
        'location': location,
        'imagePath': imagePath,
        'hour': time?.hour,
        'minute': time?.minute,
      };

  static Event fromJson(Map<String, dynamic> json) {
    return Event(
      activityID: json['activityID'] ?? 0,
      date: DateTime.tryParse(json['activityExecutionTime'] ?? '') ??
          DateTime.now(),
      title: json['activityName'] ?? 'Untitled',
      location: json['locationOfActivity'],
      imagePath: json['imagePath'],
      time: json['hour'] != null && json['minute'] != null
          ? TimeOfDay(hour: json['hour'], minute: json['minute'])
          : null,
    );
  }
}
