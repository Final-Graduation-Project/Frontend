import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Course {
  final String nameOfCourse;
  final int sec;
  final String nameOfInstructor;
  final String days;
  final String time;
  final String place;

  Course({
    required this.nameOfCourse,
    required this.sec,
    required this.nameOfInstructor,
    required this.days,
    required this.time,
    required this.place,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      nameOfCourse: json['name of course'],
      sec: json['sec'],
      nameOfInstructor: json['name of instructor'],
      days: json['days'],
      time: json['time'],
      place: json['place'],
    );
  }
}

class OfficeHour {
  final int officeHourId;
  final int teacherId;
  final String teacherFreeDay;
  final String teacherStartFreeTime;
  final String teacherEndFreeTime;
  final String buildingName;
  final String roomNumber;

  OfficeHour({
    required this.officeHourId,
    required this.teacherId,
    required this.teacherFreeDay,
    required this.teacherStartFreeTime,
    required this.teacherEndFreeTime,
    required this.buildingName,
    required this.roomNumber,
  });

  factory OfficeHour.fromJson(Map<String, dynamic> json) {
    return OfficeHour(
      officeHourId: json['officeHourid'],
      teacherId: json['teacherid'],
      teacherFreeDay: json['tehcherFreeDay'],
      teacherStartFreeTime: json['tehcerstartFreeTime'],
      teacherEndFreeTime: json['tehcerEndFreeTime'],
      buildingName: json['buildingName'],
      roomNumber: json['rommNumber'],
    );
  }
}

class CourseSearchScreen extends StatefulWidget {
  @override
  _CourseSearchScreenState createState() => _CourseSearchScreenState();
}

class _CourseSearchScreenState extends State<CourseSearchScreen> {
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  List<OfficeHour> _filteredOfficeHours = [];
  TextEditingController _controller = TextEditingController();
  int _selectedOption = 1;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadCourses();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole');
    if (role == null) {
      Navigator.pushNamed(context, '/login');
    }
  }

  Future<void> _loadCourses() async {
    final String response =
    await rootBundle.loadString('files/courses.json');
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
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _filteredOfficeHours =
              data.map((json) => OfficeHour.fromJson(json)).toList();
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

  void _searchCourse(String name) {
    setState(() {
      _filteredCourses = _courses
          .where((course) =>
      course.nameOfCourse.toLowerCase() == name.toLowerCase())
          .toList();
    });
  }

  void _searchOfficeHours(String instructor) {
    _fetchOfficeHours(instructor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF176B87),
        title: Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left column for buttons and image
            Container(
              width: MediaQuery.of(context).size.width * 0.25,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/search.png',
                    height: 150,
                    width: 150,
                  ),
                  SizedBox(height: 40), // Adjusted height for spacing
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedOption = 1;
                        _controller.clear();
                        _filteredCourses.clear();
                        _filteredOfficeHours.clear();
                      });
                    },
                    child: Text(
                      'Course',
                      style: TextStyle(
                        color: _selectedOption == 1 ? Colors.white : Colors.black,
                        fontSize: 24, // Adjusted font size
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20), // Adjusted padding
                      backgroundColor: _selectedOption == 1
                          ? Color.fromARGB(255, 106, 144, 176)
                          : Colors.grey,
                    ),
                  ),
                  SizedBox(height: 20), // Adjusted height for spacing
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedOption = 2;
                        _controller.clear();
                        _filteredCourses.clear();
                        _filteredOfficeHours.clear();
                      });
                    },
                    child: Text(
                      'Office Hours',
                      style: TextStyle(
                        color: _selectedOption == 2 ? Colors.white : Colors.black,
                        fontSize: 24, // Adjusted font size
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20), // Adjusted padding
                      backgroundColor: _selectedOption == 2
                          ? Color.fromARGB(255, 106, 144, 176)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  TextFormField(
                    controller: _controller,
                    onFieldSubmitted: (value) {
                      if (_selectedOption == 1) {
                        _searchCourse(value);
                      } else {
                        _searchOfficeHours(value);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: _selectedOption == 1
                          ? 'Enter course code as "COMP133"'
                          : 'Enter instructor name',
                      labelStyle: TextStyle(
                        color: _selectedOption == 1
                            ? Color.fromARGB(255, 106, 144, 176)
                            : Color.fromARGB(255, 106, 144, 176),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          if (_selectedOption == 1) {
                            _searchCourse(_controller.text);
                          } else {
                            _searchOfficeHours(_controller.text);
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: _selectedOption == 1
                        ? _filteredCourses.isNotEmpty
                        ? ListView.builder(
                      itemCount: _filteredCourses.length,
                      itemBuilder: (context, index) {
                        final course = _filteredCourses[index];
                        return Center(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: MediaQuery.of(context)
                                    .size
                                    .width *
                                    0.5,
                                child: Table(
                                  columnWidths: {
                                    0: FlexColumnWidth(),
                                    1: FlexColumnWidth(),
                                  },
                                  children: [
                                    TableRow(children: [
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            'Course Name:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            course.nameOfCourse,
                                            style: TextStyle(
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            'Section:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            course.sec.toString(),
                                            style: TextStyle(
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            'Instructor:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            course.nameOfInstructor,
                                            style: TextStyle(
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            'Days:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            course.days,
                                            style: TextStyle(
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            'Time:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            course.time,
                                            style: TextStyle(
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            'Place:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            course.place,
                                            style: TextStyle(
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                        : Center(child: Text('No courses found'))
                        : _filteredOfficeHours.isNotEmpty
                        ? ListView.builder(
                      itemCount: _filteredOfficeHours.length,
                      itemBuilder: (context, index) {
                        final officeHour = _filteredOfficeHours[index];
                        return Center(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: MediaQuery.of(context)
                                    .size
                                    .width *
                                    0.5,
                                child: Table(
                                  columnWidths: {
                                    0: FlexColumnWidth(),
                                    1: FlexColumnWidth(),
                                  },
                                  children: [
                                    TableRow(children: [
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            'Day:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            officeHour.teacherFreeDay,
                                            style: TextStyle(
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            'Start Time:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            officeHour
                                                .teacherStartFreeTime,
                                            style: TextStyle(
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            'End Time:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            officeHour.teacherEndFreeTime,
                                            style: TextStyle(
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            'Building:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            officeHour.buildingName,
                                            style: TextStyle(
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            'Room:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            officeHour.roomNumber,
                                            style: TextStyle(
                                                fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                        : Center(child: Text('No office hours found')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}