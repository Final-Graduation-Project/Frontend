import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Node {
  String name;
  double x;
  double y;
  Node(this.name, this.x, this.y);
  @override
  String toString() {
    // TODO: implement toString
    return "Name: $name, x: $x, y: $y";
  }
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
  final GlobalKey<_MapPaneState> _mapPaneKey = GlobalKey<_MapPaneState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB4D4FF),
      
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
                  child: MapPane(key: _mapPaneKey),
                ),
                Expanded(
                  child: RightSide(mapPaneKey: _mapPaneKey),
                ),
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(
                  child: MapPane(key: _mapPaneKey),
                  flex: 2,
                ),
                Expanded(
                  child: RightSide(mapPaneKey: _mapPaneKey),
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
  const MapPane({Key? key}) : super(key: key);

  @override
  _MapPaneState createState() => _MapPaneState();
}

class _MapPaneState extends State<MapPane> {
  List<Node> _pathNodes = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          List<Node> nodes = [
            Node("AL.Juraysi", 0.8304687738418579, 0.43378863241920135),
            Node("SCI", 0.530468761920929, 0.6974465629757611),
            Node("Aggad", 0.28046876192092896, 0.6178741497800614),
            Node("N.Shaheen", 0.749218761920929, 0.5228622698518756),
            Node("Bahrain", 0.37109375, 0.15250596261669032),
            Node("Khoury", 0.41484376788139343, 0.14519003354577845),
            Node("Masruji", 0.36593751192092896, 0.11837292554308696),
            Node("PNH", 0.2671875059604645, 0.1402541715664235),
            Node("Aweidah", 0.1437500397364299, 0.21051074630160102),
            Node("GYM", 0.26031251788139343, 0.2803919470197427),
            Node("Masri", 0.477083412806193, 0.03967934387567095),
            Node("Bamieh", 0.48593738079071, 0.1330047610323133),
            Node("Alsadik", 0.46593738079071, 0.19625893259873678),
            Node("IOL", 0.45781251788139343, 0.36590262536355154),
            Node("KNH", 0.52734375, 0.4896081209380495),
            Node("Alghanim", 0.6343750357627869, 0.4872328148788059),
            Node("NSA", 0.35625001788139343, 0.07155582886669418),
            Node("المجمع", 0.39765626192092896, 0.48010689670107504),
            Node("العمادة", 0.4007812440395355, 0.38628269245510843),
            Node("الرئاسة", 0.620312511920929, 0.292458442903947),
            Node("العيادة", 0.6640625, 0.601247052670551),
            Node("zane", 0.47921876192092896, 0.0924941053411019),
            Node("البوك ستور", 0.4164062440395355, 0.2983966853994586),
            Node("A.Shaheen", 0.3215625, 0.22119953295780764)
          ];

          List<Widget> positionedWidgets = [];
          for (var node in nodes) {
            double left = node.x * constraints.maxWidth;
            double top = node.y * constraints.maxHeight;
            positionedWidgets.add(
              Positioned(
                left: left,
                top: top,
                child: HoverableBuildingPoint(
                  node: node,
                  onClick: (String nodeName) {
                    _updateDropdown(nodeName);
                  },
                ),
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
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: PathPainter(pathNodes: _pathNodes),
              ),
              ...positionedWidgets,
            ],
          );
        },
      ),
    );
  }

  void _updateDropdown(String nodeName) {
    final rightSideState = context.findAncestorStateOfType<_RightSideState>();
    if (rightSideState != null) {
      rightSideState.updateDropdowns(nodeName);
    }
  }

  void updatePath(List<Node> pathNodes) {
    setState(() {
      _pathNodes = pathNodes;
    });
  }
}

class PathPainter extends CustomPainter {
  final List<Node> pathNodes;

  PathPainter({required this.pathNodes});

  @override
  void paint(Canvas canvas, Size size) {
    if (pathNodes.length < 2) return;

    Paint linePaint = Paint()
      ..color = Colors.red // Color of the line
      ..strokeWidth = 2.0 // Width of the line
      ..style = PaintingStyle.stroke; // Style of the line (stroke)

    Path path = Path();
    path.moveTo(pathNodes[0].x * size.width, pathNodes[0].y * size.height);
    for (int i = 1; i < pathNodes.length; i++) {
      path.lineTo(pathNodes[i].x * size.width, pathNodes[i].y * size.height);
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class HoverableBuildingPoint extends StatefulWidget {
  final Node node;
  final ValueChanged<String> onClick;

  HoverableBuildingPoint({required this.node, required this.onClick});

  @override
  _HoverableBuildingPointState createState() => _HoverableBuildingPointState();
}

class _HoverableBuildingPointState extends State<HoverableBuildingPoint> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: () {
          widget.onClick(widget.node.name);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 10.0,
              height: 10.0,
              decoration: BoxDecoration(
                color: _isHovered ? Colors.green : Colors.red, // Change color based on hover
                shape: BoxShape.circle,
              ),
            ),
            if (_isHovered)
              Positioned(
                left: 10,
                top: -20,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Text(
                      widget.node.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RightSide extends StatefulWidget {
  final GlobalKey<_MapPaneState> mapPaneKey;

  RightSide({required this.mapPaneKey});

  @override
  _RightSideState createState() => _RightSideState();
}

class _RightSideState extends State<RightSide> {
  String? _selectedFrom;
  String? _selectedTo;
  String _path = "";
  double _distance = 0.0;

  final List<String> _locations = [
    "AL.Juraysi",
    "SCI",
    "Aggad",
    "N.Shaheen",
    "Bahrain",
    "Khoury",
    "Masruji",
    "PNH",
    "Aweidah",
    "GYM",
    "Masri",
    "Bamieh",
    "Alsadik",
    "IOL",
    "KNH",
    "Alghanim",
    "NSA",
    "المجمع",
    "العمادة",
    "الرئاسة",
    "العيادة",
    "zane",
    "البوك ستور",
    "A.Shaheen",
  ];
  List<Node> nodes = [
    Node("AL.Juraysi", 0.8304687738418579, 0.43378863241920135),
    Node("SCI", 0.530468761920929, 0.6974465629757611),
    Node("Aggad", 0.28046876192092896, 0.6178741497800614),
    Node("N.Shaheen", 0.749218761920929, 0.5228622698518756),
    Node("Bahrain", 0.37109375, 0.15250596261669032),
    Node("Khoury", 0.41484376788139343, 0.14519003354577845),
    Node("Masruji", 0.36593751192092896, 0.11837292554308696),
    Node("PNH", 0.2671875059604645, 0.1402541715664235),
    Node("Aweidah", 0.1437500397364299, 0.21051074630160102),
    Node("GYM", 0.26031251788139343, 0.2803919470197427),
    Node("Masri", 0.477083412806193, 0.03967934387567095),
    Node("Bamieh", 0.48593738079071, 0.1330047610323133),
    Node("Alsadik", 0.46593738079071, 0.19625893259873678),
    Node("IOL", 0.45781251788139343, 0.36590262536355154),
    Node("KNH", 0.52734375, 0.4896081209380495),
    Node("Alghanim", 0.6343750357627869, 0.4872328148788059),
    Node("NSA", 0.35625001788139343, 0.07155582886669418),
    Node("المجمع", 0.39765626192092896, 0.48010689670107504),
    Node("العمادة", 0.4007812440395355, 0.38628269245510843),
    Node("الرئاسة", 0.620312511920929, 0.292458442903947),
    Node("العيادة", 0.6640625, 0.601247052670551),
    Node("zane", 0.47921876192092896, 0.0924941053411019),
    Node("البوك ستور", 0.4164062440395355, 0.2983966853994586),
    Node("A.Shaheen", 0.3215625, 0.22119953295780764)
  ];

  Future<void> _findPath() async {
    if (_selectedFrom != null && _selectedTo != null) {
      final response = await http.get(
        Uri.parse('http://localhost:5050/api/building-distance/BuildingDistance?from=$_selectedFrom&to=$_selectedTo'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> path = List<String>.from(data['path']); // Correctly parse the path as a list of strings

        List<Node> pathNodes = [];
        for (var nodeName in path) {
          for (var node in nodes) {
            if (node.name == nodeName) {
              pathNodes.add(node);
              break;
            }
          }
        }

        // Add the selected nodes (from and to) if they are not already in the path
        for (var node in nodes) {
          if (node.name == _selectedFrom && !pathNodes.contains(node)) {
            pathNodes.insert(0, node); // Ensure the starting node is at the beginning
          } else if (node.name == _selectedTo && !pathNodes.contains(node)) {
            pathNodes.add(node); // Ensure the destination node is at the end
          }
        }

        // Use mounted to ensure setState is called only when the widget is still in the widget tree
        if (mounted) {
          setState(() {
            _path = _selectedFrom! + " -> " + path.join(' -> ');
            _distance = data['distance'];
            widget.mapPaneKey.currentState?.updatePath(pathNodes);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _path = "Error: Unable to find path.";
            _distance = 0.0;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _path = "Please select both starting and destination buildings.";
          _distance = 0.0;
        });
      }
    }
  }

  void _clear() {
    setState(() {
      _selectedFrom = null;
      _selectedTo = null;
      _path = "";
      _distance = 0.0;
      widget.mapPaneKey.currentState?.updatePath([]);
    });
  }

  void updateDropdowns(String nodeName) {
    setState(() {
      if (_selectedFrom == null) {
        _selectedFrom = nodeName;
      } else if (_selectedTo == null) {
        _selectedTo = nodeName;
      } else {
        _selectedFrom = nodeName;
        _selectedTo = null;
      }
    });
  }

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

// void main() {
//   runApp(map());
// }
