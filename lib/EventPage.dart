import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  DateTime date;
  String title;
  String? location;
  String? imagePath;
  TimeOfDay? time;
//aa
  Event(
      {required this.date,
      required this.title,
      this.location,
      this.imagePath,
      this.time});

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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadEvents();
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

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole');
    if (role == null) {
      Navigator.pushNamed(context, '/login');
    }
  }

  Future<String?> _getRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole');
    if (role == "student") {}
    return role;
  }

  List<XFile>? _mediaFileList;

  void _setImageFileListFromFile(XFile? value) {
    _mediaFileList = value == null ? null : <XFile>[value];
  }

  dynamic _pickImageError;
  bool isVideo = false;

  String? _retrieveDataError;

  Future<void> _onImageButtonPressed(
    ImageSource source, {
    required BuildContext context,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
      );
      setState(() {
        _setImageFileListFromFile(pickedFile);
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

// The widget that displays the image
  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_mediaFileList != null) {
      final String? mime = lookupMimeType(_mediaFileList![0].path);
      return ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 30, 30, 30),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          width: 50,
          height: 50,
          child: Semantics(
            label: 'image_picker_example_picked_image',
            // for web browsers, can be ignored
            child: kIsWeb
                ? Image.network(_mediaFileList![0].path)
                : (mime == null || mime.startsWith('image/')
                    ?
                    // The image is a file on the device, this is what we are interested in
                    // you can wrap this with a Container and add decoration accordingly
                    Image.file(
                        File(_mediaFileList![0].path),
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          return const Center(
                              child: Text('This image type is not supported'));
                        },
                      )
                    : Container()),
          ),
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _handlePreview() {
    return _previewImages();
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      isVideo = false;
      setState(() {
        if (response.files == null) {
          _setImageFileListFromFile(response.file);
        } else {
          _mediaFileList = response.files;
        }
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF176B87),
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            SizedBox(width: 10),
            Text('Event Calendar '),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          TableCalendar(
            firstDay: DateTime.utc(2021, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) async {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
               if (await _getRole() == "student" || await _getRole() == null) {
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'UPCOMING EVENTS for ${_formatCalendarHeader()}!',
              style: TextStyle(
                fontSize: 20,
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

                return ListTile(
                  title: Row(
                    children: [
                      Center(
                        child: !kIsWeb &&
                                defaultTargetPlatform == TargetPlatform.android
                            ? FutureBuilder<void>(
                                future: retrieveLostData(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<void> snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.none:
                                    case ConnectionState.waiting:
                                      return const Text(
                                        'You have not yet picked an image.',
                                        textAlign: TextAlign.center,
                                      );
                                    case ConnectionState.done:
                                      return _handlePreview();
                                    case ConnectionState.active:
                                      if (snapshot.hasError) {
                                        return Text(
                                          'Pick image/video error: ${snapshot.error}}',
                                          textAlign: TextAlign.center,
                                        );
                                      } else {
                                        return const Text(
                                          'You have not yet picked an image.',
                                          textAlign: TextAlign.center,
                                        );
                                      }
                                  }
                                },
                              )
                            : _handlePreview(),
                      ),
                      Text(event.title),
                    ],
                  ),
                  subtitle: _buildEventSubtitle(event),
                  onTap: () {},
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _selectedDay = event.date;
                          _selectedTime = event.time;
                          _showAddEventDialog(isEdit: true, editEvent: event);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _events.removeAt(_events.indexOf(event));
                          });
                          _saveEvents(); // Save changes to the persistent storage
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
            Icon(Icons.calendar_today, size: 16),
            SizedBox(width: 4),
            Text('Date: ${event.date.toString().split(' ')[0]}'),
          ],
        ),
        Row(
          children: [
            Icon(Icons.access_time, size: 16),
            SizedBox(width: 4),
            Text('Time: ${event.time?.format(context) ?? 'Not Set'}'),
          ],
        ),
        Row(
          children: [
            Icon(Icons.place, size: 16),
            SizedBox(width: 4),
            Text('Place: ${event.location ?? 'No location'}'),
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
                decoration: InputDecoration(labelText: "Event Name"),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: "Location"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime ?? TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
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
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      if (isEdit) {
                        editEvent!.imagePath = image.path;
                      }
                    });
                  }
                },
                child: Text("Add Picture"),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Save"),
            onPressed: () {
              if (isEdit) {
                editEvent!.title = titleController.text;
                editEvent!.location = locationController.text;
                editEvent!.time = _selectedTime;
              } else {
                _events.add(Event(
                  title: titleController.text,
                  location: locationController.text,
                  imagePath: "",
                  date: _selectedDay!,
                  time: _selectedTime,
                ));
              }
              Navigator.pop(context);
              _saveEvents(); // Persist data after adding/updating an event
              setState(() {});
            },
          ),
        ],
        backgroundColor: Color(0xFF86B6F6),
      ),
    );
  }
}
