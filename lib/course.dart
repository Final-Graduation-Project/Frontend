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
    if(role==null){
      Navigator.pushNamed(context, '/login');
    }
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
        backgroundColor: Color(0xFF86B6F6),
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
                    backgroundColor: _selectedOption == 2 ? Color.fromARGB(255, 106, 144, 176) : Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: _selectedOption == 1 ? 'Enter course code as "COMP133"' : 'Enter instructor name',
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
                    title: Text('Instructor: ${_controller.text}', style: TextStyle(fontSize: 18)),
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
            ),
          ],
        ),
      ),
    );
  }
}