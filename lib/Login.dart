import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class UserData {
  final String id;

  UserData(this.id);
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _idControllers = TextEditingController();
  final _tokenController = TextEditingController();
  bool _isPasswordVisible = false;
  late String _generatedCode;
  String _message = '';

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final id = int.tryParse(_idController.text);
    final password = _passwordController.text;

    final url = Uri.parse('https://localhost:7025/api/Student/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'password': password}),
    );

    if (response.statusCode == 200) {
      final user = json.decode(response.body);
      await _storeUserDetailsInSession(user);
      // Login successful, navigate to next page
      String userId = _idController.text;
      // TODO: remove this
      userId = "$id";
      Navigator.pushNamed(
        context,
        '/firstPage',
        arguments: UserData(userId),
      );
    } else {
      // Login failed, show error message
      _showErrorDialog(context, response.body);
    }
  }

  Future<void> _storeUserDetailsInSession(
      Map<String, dynamic> userDetails) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Store user details in shared preferences
    await prefs.setString('userId', userDetails['Id']);
    await prefs.setString('userName', userDetails['Name']);
    await prefs.setString('userEmail', userDetails['Email']);
    await prefs.setString('userPhone', userDetails['Phone']);
    await prefs.setString('userRole', userDetails['Role']);
  }

  String _generateRandomCode() {
    final random = Random();
    final code = List.generate(5, (_) => random.nextInt(10)).join();
    return code;
  }

  Future<void> _sendCodeToEmail(String email, String code) async {
    final response = await http.get(
      Uri.parse('https://localhost:7025/api/Account?email=$email&token=$code'),
    );

    if (response.statusCode != 200) {
      _showErrorDialog(context, "Error sending code. Please try again.");
    } else {
      Navigator.of(context).pop();
      _showVerifyDialog(context);
    }
  }

  void _sendCode() async {
    final id = _idControllers.text;
    final response = await http.get(
      Uri.parse('https://localhost:7025/api/Student/GetStudent/$id'),
    );
    if (response.statusCode == 200) {
      String email = "$id@student.birzeit.edu";
      if (email != null) {
        _generatedCode = _generateRandomCode();
        await _sendCodeToEmail(email, _generatedCode);
      } else {
        _showErrorDialog(context, 'Email not found for the given ID.');
      }
    } else {
      _showErrorDialog(context, "ID not found, try signing up first");
    }
  }

  void _verifyCode() {
    if (_tokenController.text == _generatedCode) {
      // Code verified
      Navigator.of(context).pop();
      _enterPassword(context);
    } else {
      // Code verification failed
      _showErrorDialog(context, 'Invalid code. Please try again.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Error', style: TextStyle(color: Colors.red)),
            ],
          ),
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

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Forgot Password'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _idControllers,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter your 7-digit ID',
                    ),
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _sendCode();
              },
              child: const Text('Send Code'),
            ),
          ],
        );
      },
    );
  }

  void _showVerifyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Confirm Code'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _tokenController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter 5-digit code',
                    ),
                  ),
                  Text(_message),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _verifyCode();
              },
              child: const Text('Verify Code'),
            ),
          ],
        );
      },
    );
  }

  void _enterPassword(BuildContext context) {
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    final _passwordFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Enter New Password'),
          content: Form(
            key: _passwordFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter a password";
                    }
                    if (value.length < 8) {
                      return "Password must be at least 8 characters";
                    }
                    if (!RegExp(
                            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                        .hasMatch(value)) {
                      return 'Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "New Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please confirm your password";
                    }
                    if (value != _newPasswordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_passwordFormKey.currentState!.validate()) {
                  _changePassword(
                      _idControllers.text, _newPasswordController.text);
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _changePassword(String id, String newPassword) async {
    final url = Uri.parse(
        'https://localhost:7025/api/Student/forgetpassword?id=$id&newPassword=$newPassword');

    final response = await http.put(
      url,
      headers: {'accept': '*/*'},
    );

    if (response.statusCode == 200) {
      _showErrorDialog(context, 'Password Changed Successfully');
    } else {
      _showErrorDialog(context, 'Failed to change password. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Log in"),
        backgroundColor: Color(0xFF176B87), // Lighter Blue
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(),
            flex: 1,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "images/studentdigitalguidelogo.png",
                      height: 200,
                      width: 200,
                    ),
                    TextFormField(
                      controller: _idController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your ID number";
                        }
                        if (!RegExp(r'^[0-9]*$').hasMatch(value)) {
                          return "ID number should only contain numbers";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "ID Number",
                        suffixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16), // Adjust the content padding
                      ),
                    ),
                    const SizedBox(
                        height:
                            16), // Reduce the space between the ID number and password fields
                    TextFormField(
                      obscureText: !_isPasswordVisible,
                      controller: _passwordController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your password";
                        }
                        if (value.length < 8) {
                          return "Password must be at least 8 characters";
                        }
                        if (!RegExp(
                                r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                            .hasMatch(value)) {
                          return 'Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Password",
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16), // Adjust the content padding
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              _showForgotPasswordDialog(context);
                            },
                            child: Text(
                              "forgot your password?",
                              style: TextStyle(color: Color(0xFF176B87)),
                            ))
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton(
                            color: Color(0xFF176B87),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _login();
                              }
                            },
                            child: Text("Log in"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            flex: 1,
          ),
          Expanded(
            child: SizedBox(),
            flex: 1,
          )
        ],
      ),
    );
  }
}
