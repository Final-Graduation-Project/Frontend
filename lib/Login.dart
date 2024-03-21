import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}
class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final id = _idController.text;
    final password = _passwordController.text;

    final  url = Uri.parse('http://localhost:5050/api/Student/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'password': password}),
      );

      if (response.statusCode == 200) {
        // Login successful, navigate to next page
        Navigator.pushNamed(context, '/firstPage');
      } else {
        // Login failed, show error message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Login Failed'),
            content: Text('Invalid ID or password'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }

  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Log in"),
        backgroundColor: Color(0xFFB4D4FF), // Lighter Blue
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
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
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Adjust the content padding
                ),
              ),
              const SizedBox(height: 16), // Reduce the space between the ID number and password fields
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
                  if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(value)) {
                    return 'Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Adjust the content padding
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgotpassword');
                    },
                    child: Text("forgot your password?")
                  )
                ],
              ),
              ElevatedButton(
                onPressed: () {
                   if (_formKey.currentState!.validate()) {
                     _login();
                   }
                },
                child: Text("Log in")
              ),
            ],
          ),
        ),
      ),
    );
  }
}

