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

class _MapAppState extends State<map> {
  final Color color1 = Color(0xFF176B87); // Dark Blue
  final Color color2 = Color(0xFFB4D4FF); // Lighter Blue
  final Color color3 = Color(0xFF86B6F6); // Even Lighter Blue
  final Color color4 = Color(0xFFEEF5FF); // Very Light Blue

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Digital Guide",
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: color4,
        primaryColor: color1,
        hintColor: color3,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB4D4FF),
        leading: Image.asset('images/studentdigitalguidelogo.png', height: 40, width: 40),
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
                  child: MapPane(),
                  flex: 2,
                ),
                Expanded(
                  child: RightSide(),
                ),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(
                  child: MapPane(),
                  flex: 2,
                ),
                Expanded(
                  child: RightSide(),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class MapPane extends StatefulWidget {
  @override
  _MapPaneState createState() => _MapPaneState();
}

class _MapPaneState extends State<MapPane> {
  Offset? _tapPosition;
  double? normalizedX;
  double? normalizedY;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset localOffset = box.globalToLocal(details.globalPosition);

        setState(() {
          _tapPosition = localOffset;
          normalizedX = localOffset.dx / box.size.width;
          normalizedY = localOffset.dy / box.size.height;
          print("Normalized X: $normalizedX, Normalized Y: $normalizedY");
        });
      },
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Example of placing points at specified coordinates on the map image
            List<Node> nodes = [
              Node("it", 0.4895833333333333, 0.21526129046229603),
              Node("building2", 0.2, 0.4)
            ];

            // Create a list of Positioned widgets based on nodes
            List<Widget> positionedWidgets = [];

            // Loop through nodes and create Positioned widgets for each building
            for (var node in nodes) {
              // Calculate the left and top positions based on node coordinates and scaling factors
              double left = node.x * constraints.maxWidth;
              double top = node.y * constraints.maxHeight;

              // Create a Positioned widget for the building point
              positionedWidgets.add(
                Positioned(
                  left: left,
                  top: top,
                  child: _BuildingPoint(),
                ),
              );
            }

            // Return a Stack widget to overlay the map image with building points
            return Stack(
              children: [
                // Map image as the background, scaled to fit the container
                Image.asset(
                  "images/birziet.jpg",
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  //fit: BoxFit.contain,
                ),
                // Overlay the building points on top of the map image
                ...positionedWidgets,
                if (_tapPosition != null)
                  Positioned(
                    left: _tapPosition!.dx,
                    top: _tapPosition!.dy,
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 24.0,
                    ),
                  ),
              ],
            );
          },
        ),
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
          PathBox(),
          SrcDestBox(),
          Buttons(),
        ],
      ),
    );
  }
}

class PathBox extends StatelessWidget {
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
          PathTable(),
          SizedBox(height: 10.0),
          TotalDistance(),
        ],
      ),
    );
  }
}

class PathTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.0,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('From'),
            subtitle: Text('To'),
          );
        },
      ),
    );
  }
}

class TotalDistance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Total Distance: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
        Text(
          '100 m',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class SrcDestBox extends StatelessWidget {
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
              onChanged: (value) {},
              items: [
                DropdownMenuItem(
                  child: Text('Building 1'),
                  value: 'Building 1',
                ),
              ],
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
              onChanged: (value) {},
              items: [
                DropdownMenuItem(
                  child: Text('Building 2'),
                  value: 'Building 2',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class Buttons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Implement find path functionality
          },
          child: Text('Find Path'),
        ),
        SizedBox(height: 10.0),
        ElevatedButton(
          onPressed: () {
            // Implement clear path functionality
          },
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

