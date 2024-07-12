import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

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

class EventAddEntity {
  int activityID;
  String activityName;
  String locationOfActivity;
  DateTime activityExecutionTime;
  DateTime time;
  String entityResponsibleActivity;
  int concilMemberID;
  String imagePath;

  EventAddEntity({
    required this.activityID,
    required this.activityName,
    required this.locationOfActivity,
    required this.activityExecutionTime,
    required this.time,
    required this.entityResponsibleActivity,
    required this.concilMemberID,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        'activityID': activityID,
        'activityName': activityName,
        'locationOfActivity': locationOfActivity,
        'activityExecutionTime': activityExecutionTime.toIso8601String(),
        'time': time.toIso8601String(),
        'entityResponsibleActivity': entityResponsibleActivity,
        'concilMemberID': concilMemberID,
        'imagePath': imagePath,
      };
}

class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  List<Event> _events = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final ImagePicker _picker = ImagePicker();
  TimeOfDay? _selectedTime;
  String? userId;
  String? userRole;
  XFile? _selectedImage;
  Uint8List? _webImage; // For web image handling

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadEvents();
    _loadImagePath();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
      userRole = prefs.getString('userRole');
    });

    if (userId == null || userRole == null) {
      Navigator.pushNamed(context, '/login');
    }
  }

  Future<void> _loadEvents() async {
    final String url =
        'https://localhost:7025/api/EventControllercs/GetAllEvent';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        //backend is not working !
        final String responseBody = response.body;
        try {
          // Check if the response body is a valid JSON
          final List<dynamic> eventsJson = json.decode(responseBody);
          setState(() {
            _events = eventsJson.map((e) => Event.fromJson(e)).toList();
            _events.sort((a, b) => a.date.compareTo(b.date));
          });
          _saveEvents();
        } catch (e) {
          print('Error occurred while decoding JSON: $e');
          print('Response body: $responseBody');
        }
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

  Future<void> _loadImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final imagePath = prefs.getString('selectedImagePath');
      if (imagePath != null) {
        if (kIsWeb) {
          _webImage = base64Decode(imagePath);
        } else {
          _selectedImage = XFile(imagePath);
        }
      }
    });
  }

  Future<void> _saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedImagePath', path);
  }

  Future<void> _deleteevent(int id) async{
    final String url = 'https://localhost:7025/api/EventControllercs/DeleteEvent/$id';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _events.removeWhere((element) => element.activityID == id);
        });
        _saveEvents();
        showDialog(context: context, builder: (context) => AlertDialog(
          title: const Text('Delete Event'),
          content: const Text('Event deleted successfully'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ));
      } else {
        showDialog(context: context, builder: (context) => AlertDialog(
          title: const Text('Delete Event'),
          content: Text('Failed to delete event: ${response.body}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ));
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }
  void _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _webImage = bytes;
          _selectedImage = image;
        });
        await _saveImagePath(base64Encode(bytes));
      } else {
        setState(() {
          _selectedImage = image;
        });
        await _saveImagePath(image.path);
      }
      print("Image picked: ${image.path}");
    }
  }

  Widget _handlePreview(Event event) {
    if (event.imagePath != null && event.imagePath!.isNotEmpty) {
      if (kIsWeb) {
        return Image.memory(
          base64Decode(event.imagePath!),

              height: 120,
              width: 120,
              fit: BoxFit.fill,

          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
            return const Center(
                child: Text('This image type is not supported'));
          },
        );
      } else {
        return Image.file(
          File(event.imagePath!),
          width: 100,
          height: 100,
          fit:BoxFit.fill,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
            return const Center(
                child: Text('This image type is not supported'));
          },
        );
      }
    } else {
      return const Text(
        '',
        // 'You have not yet picked an image.',
        // textAlign: TextAlign.center,
      );
    }
  }

  Future<bool> addEventToServer(EventAddEntity event) async {
    final String url = 'https://localhost:7025/api/EventControllercs/AddEvent';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(event.toJson()),
      );
      if (response.statusCode == 200) {
        print('Event added successfully');
        return true;
      } else {
        print('Failed to add event: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error occurred: $e');
      return false;
    }
  }

  Future<void> _editevent(int id , EventAddEntity event) async {
    final String url = 'https://localhost:7025/api/EventControllercs/UpdateEvent?id=$id';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(event.toJson()),
      );
      if (response.statusCode == 200) {
        print('Event edited successfully');
      } else {
        print('Failed to edit event: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }
  void _showAddEventDialog({bool isEdit = false, Event? editEvent}) {
    final TextEditingController titleController =
        TextEditingController(text: isEdit ? editEvent?.title : '');
    final TextEditingController locationController =
        TextEditingController(text: isEdit ? editEvent?.location : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Text(
            isEdit ? "Edit Event" : "Add New Event",
            style: const TextStyle(color: Colors.white),
          ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Event Name",
                    labelStyle: TextStyle(color: Colors.white),
                  ),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                    labelText: "Location",
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime ?? TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF86B6F6),
                            onPrimary: Colors.white,
                            onSurface: Color(0xFF176B87),
                          ),
                          dialogBackgroundColor: Colors.white,
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTime = time;
                    });
                  }
                },
                child: Text(
                  _selectedTime == null
                      ? "Select Time"

                      : 'Time: ${_selectedTime!.format(context)}',
                  style: TextStyle(
                    color:  Colors.black,
                  ),// Change this to the desired color
                  ),
                ),

              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text(
                  "Add Picture",
                  style: TextStyle(
                    color:  Colors.black,
                  ),
                ),
                ),

              Padding(
                padding: const EdgeInsets.all(6.0),
                child: _selectedImage != null
                    ? _handlePreview(Event(
                    activityID: 0, // Temporary ID
                    date: DateTime.now(),
                    title: '',
                    imagePath: _selectedImage!.path))
                    : const Text(
                  '',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              if (userId == null) {
                print("Failed to get userId");
                return;
              }

              if (userRole == null) {
                print("Failed to get userRole");
                return;
              }

              String imagePath = "";
              if (kIsWeb && _webImage != null) {
                imagePath = base64Encode(_webImage!);
              } else if (_selectedImage != null) {
                imagePath = _selectedImage!.path;
              }

              final newEvent = EventAddEntity(
                activityID:
                    isEdit && editEvent != null ? editEvent.activityID : 0,
                activityName: titleController.text,
                locationOfActivity: locationController.text,
                activityExecutionTime: _selectedDay,
                time: _selectedDay, // Adjust if separate time needed
                entityResponsibleActivity: userRole!, // Replace as needed
                concilMemberID: int.parse(userId!), // Use retrieved ID
                imagePath: imagePath, // Use selected image path
              );


                setState(()  {
                  if (isEdit && editEvent != null) {
                     _editevent(editEvent.activityID, newEvent);
                  } else {
                    addEventToServer(newEvent);
                    _events.add(Event(
                      activityID: newEvent.activityID,
                      title: titleController.text,
                      location: locationController.text,
                      imagePath: imagePath,
                      date: _selectedDay,
                      time: _selectedTime,
                    ));
                    _events.sort((a, b) => a.date.compareTo(b.date));
                  }
                });
                Navigator.pop(context);
                _saveEvents();
                _selectedImage = null; // Clear selected image
                _webImage = null; // Clear web image data

            },
          ),
        ],
        backgroundColor: const Color(0xFF176B87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF176B87),
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: const [
            SizedBox(width: 10),
            Text('Event Calendar '),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      border: Border.all(color:Color.fromARGB(255, 106, 144, 176), width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2021, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      calendarFormat: _calendarFormat,
                      onDaySelected: (selectedDay, focusedDay) async {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        if (userRole == "student" || userRole=="teacher" ||userRole == null) {
                          return;
                        } else {
                          _showAddEventDialog(isEdit: false);
                        }
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
                                color: const Color(0xFF176B87).withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                date.day.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const VerticalDivider(width: 1, color: Colors.white10),
            Expanded(
              flex: 3,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'UPCOMING EVENTS for ${_formatCalendarHeader()}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF176B87),
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  Expanded(
                      child: _events.isEmpty
                          ? const Center(child: Text('No events found.'))
                          : ListView.builder(
                              itemCount: _events.length,
                              itemBuilder: (context, index) {
                                final event = _events[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  child: Card(
                                    color: const Color(0xFF176B87),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    child: ListTile(
                                      leading: _handlePreview(event),
                                      title: Text(
                                        event.title,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 24,  fontWeight: FontWeight.bold,),
                                      ),
                                      subtitle: _buildEventSubtitle(event),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          if (userRole != "student" &&
                                              userRole!= "teacher" &&
                                              userRole != null)
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.black),
                                              onPressed: () {
                                                _selectedDay = event.date;
                                                _selectedTime = event.time;
                                                _showAddEventDialog(
                                                    isEdit: true,
                                                    editEvent: event);
                                              },
                                            ),
                                          if (userRole != "student" &&
                                              userRole!= "teacher" &&
                                              userRole != null)
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.black),
                                              onPressed: () {
                                                _deleteevent(event.activityID);
                                                _saveEvents();
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _dateHasEvent(DateTime date) {
    return _events.any((event) => isSameDay(event.date, date));
  }

  List<Event> _visibleEvents() {
    return _events.where((event) {
      if (_calendarFormat == CalendarFormat.week) {
        return event.date.difference(_focusedDay).inDays.abs() < 7 &&
            event.date.weekday == _focusedDay.weekday;
      } else if (_calendarFormat == CalendarFormat.twoWeeks) {
        return event.date.difference(_focusedDay).inDays.abs() < 14 &&
            event.date.weekday == _focusedDay.weekday;
      } else {
        return event.date.month == _focusedDay.month;
      }
    }).toList();
  }

  String _formatCalendarHeader() {
    switch (_calendarFormat) {
      case CalendarFormat.week:
        return "this Week";
      case CalendarFormat.twoWeeks:
        return "next Two Weeks";
      case CalendarFormat.month:
        return "this Month";
      default:
        return "this Period";
    }
  }

  Widget _buildEventSubtitle(Event event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.black),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Date: ${event.date.toString().split(' ')[0]}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: Colors.black),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Time: ${event.time?.format(context) ?? 'Not Set'}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.place, size: 16, color: Colors.black),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Place: ${event.location ?? 'No location'}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
