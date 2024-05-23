import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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
  final String nameOfInstructor;
  final String days;
  final String time;
  final String place;

  OfficeHour({
    required this.nameOfInstructor,
    required this.days,
    required this.time,
    required this.place,
  });

  factory OfficeHour.fromJson(Map<String, dynamic> json) {
    return OfficeHour(
      nameOfInstructor: json['name of instructor'],
      days: json['days'],
      time: json['time'],
      place: json['place'],
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
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final String response = await rootBundle.loadString('files/courses.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      _courses = data.map((json) => Course.fromJson(json)).toList();
    });
  }

  Future<void> _fetchOfficeHours(String instructor) async {
    final response = await http.get(Uri.parse(''));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _filteredOfficeHours = data.map((json) => OfficeHour.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load office hours');
    }
  }

  void _searchCourse(String name) {
    setState(() {
      _filteredCourses = _courses.where((course) =>
      course.nameOfCourse.toLowerCase() == name.toLowerCase()).toList();
    });
  }

  void _searchOfficeHours(String instructor) {
    _fetchOfficeHours(instructor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedOption = 1;
                      _controller.clear();
                      _filteredCourses.clear();
                      _filteredOfficeHours.clear();
                    });
                  },
                  child: Text('Course'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedOption == 1 ? Colors.blue : Colors.grey,
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedOption = 2;
                      _controller.clear();
                      _filteredCourses.clear();
                      _filteredOfficeHours.clear();
                    });
                  },
                  child: Text('Office Hours'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedOption == 2 ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: _selectedOption == 1 ? 'Enter course code like "COMP133"' : 'Enter instructor name',
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
                    title: Text('Instructor: ${officeHour.nameOfInstructor}', style: TextStyle(fontSize: 18)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Days: ${officeHour.days}', style: TextStyle(fontSize: 16)),
                        Text('Time: ${officeHour.time}', style: TextStyle(fontSize: 16)),
                        Text('Place: ${officeHour.place}', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    isThreeLine: true,
                  );
                },
              )
                  : Text('No office hours found', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
