import 'dart:html';

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Validate extends StatefulWidget {
  const Validate({Key? key}) : super(key: key);

  @override
  _ValidateState createState() => _ValidateState();
}

class _ValidateState extends State<Validate> {
  final List<TextEditingController> _controllers =
  List.generate(5, (index) => TextEditingController());
  late String _generatedCode;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _show(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('email'),
          content: Text("the code sent to: "+message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _getUserData() async {
    final preferences = await SharedPreferences.getInstance();
    String? _email = preferences.getString('email');
    _generatedCode = _generateRandomCode();
    if (_email != null) {
      await _sendCodeToEmail(_email, _generatedCode);
      _show(context, _email);
    } else {
      print('email null');
    }
  }

  String _generateRandomCode() {
    final random = Random();
    final code = List.generate(5, (_) => random.nextInt(10)).join();
    return code;
  }

  Future<void> _sendCodeToEmail(String email, String code) async {
    print(email + "" + code);
    final response = await http.get(
      Uri.parse('https://localhost:7025/api/Account?email=$email&token=$code'),
    );

    if (response.statusCode != 200) {
      _showErrorDialog(context, response.body);
    }
  }

  void _validateCode(BuildContext context) async {
    String userInputToken =
    _controllers.map((controller) => controller.text).join();
    if (_generatedCode == userInputToken) {
      final preferences = await SharedPreferences.getInstance();
      String? universityID = preferences.getString('universityID');
      String? password = preferences.getString('password');
      String? confirmPassword = preferences.getString('confirmPassword');
      String? name = preferences.getString('name');
      String? major = preferences.getString('major');
      String? _email = preferences.getString('email');
      final url = Uri.parse('https://localhost:7025/api/Student/AddStudent');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': int.parse(universityID!),
          'email': _email,
          'password': password,
          'confpassword': confirmPassword,
          'name': name,
          'phone': 591234567,
          'universityMajor': major,
        }),
      );
      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sign Up done  '),
            content: Text('you can login to system'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        preferences.clear();
      } else {
        // Sign-up failed, show error message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sign Up Failed'),
            content: Text(response.body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      _showErrorDialog(context, 'Error validating code. Please try again.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validate'),
        backgroundColor: const Color(0xFF176B87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate to the previous page (Sign Up)
          },
        ),
      ),
      backgroundColor: const Color(0xFFB4D4FF),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Please enter the 5-digit code sent to your email:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 25),
                Form(
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          5,
                              (index) => SizedBox(
                            width: 40,
                            child: TextFormField(
                              controller: _controllers[index],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintStyle: TextStyle(fontSize: 24),
                                fillColor: Color(0xFF86B6F6),
                              ),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              onChanged: (value) {
                                if (value.length == 1 && index < 4) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 50.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _validateCode(context);
                          },
                          child: const Text('Validate'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
