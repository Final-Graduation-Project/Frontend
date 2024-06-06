import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Node {
  String name;
  double x;
  double y;
  Node(this.name, this.x, this.y);
}

class map extends StatefulWidget {
  const map({Key? key}) : super(key: key);

  @override
  _MapAppState createState() => _MapAppState();
}

class _mapstate extends State<map> {
  final Color color1 = Color(0xFF176B87); // Dark Blue
  final Color color2 = Color(0xFFB4D4FF); // Lighter Blue
  final Color color3 = Color(0xFF86B6F6); // Even Lighter Blue
  final Color color4 = Color(0xFFEEF5FF); // Very Light Blue

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "student digital guide",
        home: MyHomePage(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: color4,
          primaryColor: color1,
          hintColor: color3,
        ));
  }
}

class MyHomePage extends StatelessWidget {
  final GlobalKey<_RightSideState> _rightSideKey = GlobalKey<_RightSideState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB4D4FF),
        leading: Image.asset('images/studentdigitalguidelogo.png',
            height: 40, width: 40),
        title: Text("Student Digital Guide"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/aboutus');
            },
            child: Text("About us"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/contactus');
            },
            child: Text("Contact us"),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 700) {
            return Column(
              children: [
                Expanded(
                  child: MapPane(rightSideKey: _rightSideKey),
                ),
                Expanded(
                  child: RightSide(key: _rightSideKey),
                ),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(
                  child: MapPane(rightSideKey: _rightSideKey),
                  flex: 2,
                ),
                Expanded(
                  child: RightSide(key: _rightSideKey),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class MapPane extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple, width: 3.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate the scale factor based on the map image size
          double imageWidth = 800; // Update with actual width of your map image
          double imageHeight =
              600; // Update with actual height of your map image

          double scaleX = constraints.maxWidth / imageWidth;
          double scaleY = constraints.maxHeight / imageHeight;

          // Example of placing points at specified coordinates on the map image
          List<node> nodes = [
            node("building1", 100, 100),
            node("building2", 200, 400),
            node("building3", 300, 300),
            node("test", 250, 300),
          ];

          // Create a list of Positioned widgets based on nodes
          List<Widget> positionedWidgets = [];

          // Loop through nodes and create Positioned widgets for each building
          for (var node in nodes) {
            // Calculate the left and top positions based on node coordinates and scaling factors
            double left = node.x * scaleX;
            double top = node.y * scaleY;

            // Create a Positioned widget for the building point
            positionedWidgets.add(
              Positioned(
                left: left,
                top: top,
                child: _BuildingPoint(),
              ),
            );
          }

          return Stack(
            children: [
              Image.asset(
                "images/birziet.jpg",
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                fit: BoxFit.cover,
              ),
              ...positionedWidgets,
            ],
          );
        },
      ),
    );
  }
}

class RightSide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 20.0,
        runSpacing: 20.0,
        children: [
          PathBox(path: _path, distance: _distance),
          SrcDestBox(
            locations: _locations,
            selectedFrom: _selectedFrom,
            selectedTo: _selectedTo,
            onFromChanged: (value) => setState(() => _selectedFrom = value),
            onToChanged: (value) => setState(() => _selectedTo = value),
          ),
          Buttons(
            onFindPath: _findPath,
            onClear: _clear,
          ),
        ],
      ),
    );
  }
}

class PathBox extends StatelessWidget {
  final String path;
  final double distance;

  PathBox({required this.path, required this.distance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          Text(
            'Path Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            'Path: $path',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            'Total Distance: ${distance.toStringAsFixed(2)} m',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class SrcDestBox extends StatelessWidget {
  final List<String> locations;
  final String? selectedFrom;
  final String? selectedTo;
  final ValueChanged<String?> onFromChanged;
  final ValueChanged<String?> onToChanged;

  SrcDestBox({
    required this.locations,
    this.selectedFrom,
    this.selectedTo,
    required this.onFromChanged,
    required this.onToChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'From:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(width: 10.0),
            DropdownButton<String>(
              value: selectedFrom,
              hint: Text('Select Location'),
              onChanged: onFromChanged,
              items: locations.map((location) {
                return DropdownMenuItem<String>(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
            ),
          ],
        ),
        SizedBox(height: 10.0),
        Row(
          children: [
            Text(
              'To:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(width: 10.0),
            DropdownButton<String>(
              value: selectedTo,
              hint: Text('Select Location'),
              onChanged: onToChanged,
              items: locations.map((location) {
                return DropdownMenuItem<String>(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}

class Buttons extends StatelessWidget {
  final VoidCallback onFindPath;
  final VoidCallback onClear;

  Buttons({required this.onFindPath, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onFindPath,
          child: Text('Find Path'),
        ),
        SizedBox(height: 10.0),
        ElevatedButton(
          onPressed: onClear,
          child: Text('Clear'),
        ),
      ],
    );
  }
}

class _BuildingPoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.0,
      height: 10.0,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}
