/*
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Validate extends StatefulWidget {

  const Validate({Key? key}) : super(key: key);

  @override
  _ValidateState createState() => _ValidateState();
}

class _ValidateState extends State<Validate> {
  final List<TextEditingController> _controllers =
  List.generate(5, (index) => TextEditingController());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 50.0),
                        child: ElevatedButton(
                          onPressed: null, // Add your onPressed logic here
                          child: Text('Validate'),
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

  void _validateCode(BuildContext context) async {
    String userInputToken =
    _controllers.map((controller) => controller.text).join();

    final response = await http.get(
      Uri.parse(
          'https://localhost:7025/api/Account?email=${widget.email}&token=$userInputToken'),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['isValid']) {

        Navigator.pushNamed(context, '/firstPage');
      } else {
        _showErrorDialog(context, 'Invalid code. Please try again.');
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
}
*/
