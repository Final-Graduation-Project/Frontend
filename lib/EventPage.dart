import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

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

class EventService {
  static const String _baseUrl = 'https://localhost:7025/api/EventControllercs';

  Future<bool> addEvent(EventAddEntity event) async {
    final url = '$_baseUrl/AddEvent';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(event.toJson()),
      );

      if (response.statusCode == 200) {
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

  Future<String> uploadImage(File imageFile) async {
    final url = '$_baseUrl/UploadImage';
    final mimeType = lookupMimeType(imageFile.path);
    final imageUploadRequest = http.MultipartRequest('POST', Uri.parse(url));
    final file = await http.MultipartFile.fromPath('file', imageFile.path,
        contentType: MediaType.parse(mimeType!));

    imageUploadRequest.files.add(file);
    final response = await imageUploadRequest.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);
      return jsonResponse[
          'imageUrl']; // Adjust according to your backend response
    } else {
      throw Exception('Failed to upload image');
    }
  }
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
  final EventService _eventService = EventService();
  String? userId;
  String? userRole;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadEvents();
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
    final prefs = await SharedPreferences.getInstance();
    final String? eventsJson = prefs.getString('events');
    if (eventsJson != null) {
      setState(() {
        _events = (json.decode(eventsJson) as List)
            .map((e) => Event.fromJson(e as Map<String, dynamic>))
            .toList();
        _events.sort((a, b) => a.date.compareTo(b.date)); // Sort events by date
      });
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String eventsJson =
        json.encode(_events.map((e) => e.toJson()).toList());
    await prefs.setString('events', eventsJson);
  }

  Widget _handlePreview() {
    if (_selectedImage != null) {
      final String? mime = lookupMimeType(_selectedImage!.path);
      return Container(
        width: 80,
        height: 80,
        child: kIsWeb
            ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
            : (mime == null || mime.startsWith('image/')
                ? Image.file(
                    File(_selectedImage!.path),
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) {
                      return const Center(
                          child: Text('This image type is not supported'));
                    },
                  )
                : Container()),
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _selectedImage = response.file;
      });
    } else {}
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
                      border: Border.all(color: Colors.grey, width: 2),
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
                        if (userRole == "student" || userRole == null) {
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
                                color: const Color(0xFF86B6F6).withOpacity(0.5),
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
            VerticalDivider(
                width: 1, color: Color.fromARGB(255, 255, 255, 255)),
            Expanded(
              flex: 3,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'UPCOMING EVENTS for ${_formatCalendarHeader()}!',
                      style: const TextStyle(
                        fontSize: 24, // Increased font size
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF176B87),
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _visibleEvents().length,
                      itemBuilder: (context, index) {
                        final event = _visibleEvents()[index];

                        return Card(
                          color: Color.fromARGB(
                              255, 164, 197, 241), // Set the card color to blue
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ListTile(
                            leading: _handlePreview(),
                            title: Text(
                              event.title,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18), // Font size increased
                            ),
                            subtitle: _buildEventSubtitle(event),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.black),
                                  onPressed: () {
                                    _selectedDay = event.date;
                                    _selectedTime = event.time;
                                    _showAddEventDialog(
                                        isEdit: true, editEvent: event);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.black),
                                  onPressed: () {
                                    setState(() {
                                      _events.removeAt(_events.indexOf(event));
                                    });
                                    _saveEvents(); // Save changes to the persistent storage
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
            Text('Date: ${event.date.toString().split(' ')[0]}',
                style: const TextStyle(color: Colors.black, fontSize: 16)),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: Colors.black),
            const SizedBox(width: 4),
            Text('Time: ${event.time?.format(context) ?? 'Not Set'}',
                style: const TextStyle(color: Colors.black, fontSize: 16)),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.place, size: 16, color: Colors.black),
            const SizedBox(width: 4),
            Text('Place: ${event.location ?? 'No location'}',
                style: const TextStyle(color: Colors.black, fontSize: 16)),
          ],
        ),
      ],
    );
  }

  void _showAddEventDialog({bool isEdit = false, Event? editEvent}) {
    final TextEditingController titleController =
        TextEditingController(text: isEdit ? editEvent?.title : '');
    final TextEditingController locationController =
        TextEditingController(text: isEdit ? editEvent?.location : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? "Edit Event" : "Add New Event"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Event Name"),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Location"),
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
                child: Text(_selectedTime == null
                    ? "Select Time"
                    : 'Time: ${_selectedTime!.format(context)}'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _selectedImage = image;
                    });
                  }
                },
                child: const Text("Add Picture"),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Save"),
            onPressed: () async {
              if (userId == null) {
                print("Failed to get userId");
                return;
              }

              if (userRole == null) {
                print("Failed to get userRole");
                return;
              }

              String imagePath = '';
              if (_selectedImage != null) {
                try {
                  final file = File(_selectedImage!.path);
                  imagePath = await _eventService.uploadImage(file);
                } catch (e) {
                  print('Error uploading image: $e');
                }
              }

              final newEvent = EventAddEntity(
                activityID: 0, // Replace with actual ID if needed
                activityName: titleController.text,
                locationOfActivity: locationController.text,
                activityExecutionTime: _selectedDay,
                time: _selectedDay, // Adjust if separate time needed
                entityResponsibleActivity: userRole!, // Replace as needed
                concilMemberID: int.parse(userId!), // Use retrieved ID
                imagePath: imagePath, // Use uploaded image path
              );

              bool success = await _eventService.addEvent(newEvent);
              if (success) {
                setState(() {
                  if (isEdit) {
                    editEvent!.title = titleController.text;
                    editEvent!.location = locationController.text;
                    editEvent!.time = _selectedTime;
                    editEvent!.imagePath = imagePath;
                  } else {
                    _events.add(Event(
                      title: titleController.text,
                      location: locationController.text,
                      imagePath: imagePath,
                      date: _selectedDay,
                      time: _selectedTime,
                    ));
                    _events.sort((a, b) =>
                        a.date.compareTo(b.date)); // Sort events by date
                  }
                });
                Navigator.pop(context);
                _saveEvents(); // Persist data after adding/updating an event
              } else {
                // Handle error
                print("Failed to add event");
              }
            },
          ),
        ],
        backgroundColor: const Color(0xFF86B6F6),
      ),
    );
  }
}
