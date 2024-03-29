// ignore_for_file: unused_field

import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _universityIDController = TextEditingController();
  String? _selectedMajor;

  bool _passwordVisible = false;
  bool _lastNameEnabled = false;
  bool _universityIDEnabled = false;
  bool _passwordEnabled = false;
  bool _passwordMatch = false;

  final List<String> majors = [
    "Arabic Language and Literature",
    "Cultural Studies",
    "English Language",
    "Hebrew Language",
    "Italian Language",
    "Spanish Language",
    "Turkish Language",
    "German Language",
    "Translation",
    "English Language and Literature",
    "Geography",
    "Geoinformatics",
    "Palestinian Archaeology",
    "History",
    "Journalism",
    "Media",
    "Radio Broadcasting",
    "Television",
    "Media",
    "Strategic Communication",
    "Palestine and Arabic Studies",
    "Women's Studies",
    "Fine Arts",
    "French Language",
    "Teaching French Language",
    "French Translation and Interpreting",
    "Sociology",
    "Anthropology",
    "Social Work",
    "Psychology",
    "International Academy of Art Palestine",
    "Accounting",
    "Business Administration",
    "Marketing",
    "Economics",
    "Finance and Banking",
    "Actuarial Finance",
    "Cooperative Education",
    "Biology",
    "General Science Courses GENS",
    "Chemistry",
    "Applied Chemistry",
    "Forensic Sciences",
    "Mathematics Applied To Economics",
    "Mathematics",
    "Physics",
    "Public Administration",
    "Law",
    "Political Science",
    "International Relations",
    "Nursing",
    "Nutrition and Dietetics",
    "Doctor of Pharmacy",
    "Pharmacy",
    "Audiology and Speech Therapy",
    "Medical Laboratory Science",
    "Education",
    "Inclusive and Special Education",
    "Physical Education",
    "Architectural Engineering",
    "Engineering in Urban Planning and Design",
    "Civil Engineering",
    "Environmental Engineering",
    "Construction Engineering",
    "Mechanical Engineering",
    "Mechatronics Engineering",
    "Modern Automotive Engineering",
    "Computer Science",
    "Cyber Security",
    "Cooperative Education",
    "Electrical Engineering",
    "Computer Systems Engineering",
    "Music",
    "Contemporary Visual Art",
    "Design",
    "Interior Design",
    "Leadership and Civic Engagement"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
        backgroundColor: Color(0xFFB4D4FF),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildInstructionsText(),
                SizedBox(height: 16),
                buildFirstNameField(),
                SizedBox(height: 16),
                buildMajorField(),
                SizedBox(height: 16),
                buildUniversityIDField(),
                SizedBox(height: 16),
                buildPasswordField(),
                SizedBox(height: 16),
                buildConfirmPasswordField(),
                SizedBox(height: 16),
                buildSignUpButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Text buildInstructionsText() {
    return Text(
      "To sign up, you have to answer this form first",
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Row buildFirstNameField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _firstNameController,
            keyboardType: TextInputType.text,
            onChanged: (value) {
              setState(() {
                _lastNameEnabled = value.isNotEmpty;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your first name";
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "First Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: Icon(Icons.person),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(child: buildLastNameField()),
      ],
    );
  }

  TextFormField buildLastNameField() {
    return TextFormField(
      controller: _lastNameController,
      keyboardType: TextInputType.text,
      enabled: _lastNameEnabled,
      onChanged: (value) {
        // Update the state based on last name input if needed
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your last name";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Last Name",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(Icons.person),
      ),
    );
  }

  Widget buildMajorField() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return majors.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        setState(() {
          _selectedMajor = selection;
          _universityIDEnabled = true; // Enable the next field based on the selection
        });
      },
      fieldViewBuilder: (
          BuildContext context,
          TextEditingController fieldController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted,
          ) {
        return TextFormField(
          controller: fieldController,
          focusNode: fieldFocusNode,
          decoration: InputDecoration(
            labelText: "Major",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: Icon(Icons.school),
          ),
        );
      },
    );
  }

  TextFormField buildUniversityIDField() {
    return TextFormField(
      controller: _universityIDController,
      keyboardType: TextInputType.number,
      enabled: _universityIDEnabled,
      onChanged: (value) {
        setState(() {
          _passwordEnabled = value.isNotEmpty;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please write your university ID";
        }
        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
          return "Please enter a valid university ID";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "University ID",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(Icons.confirmation_num),
      ),
    );
  }

  Widget buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      enabled: _passwordEnabled,
      obscureText: !_passwordVisible,
      onChanged: (value) {
        setState(() {
          _passwordMatch = _confirmPasswordController.text == value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your password";
        }
        if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(value)) {
          return "Password should contain at least one uppercase letter, one lowercase letter, one digit, and one special character";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Password",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
      ),
    );
  }

  Widget buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      enabled: _passwordEnabled,
      obscureText: !_passwordVisible,
      onChanged: (value) {
        setState(() {
          _passwordMatch = _passwordController.text == value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please confirm your password";
        }
        if (!_passwordMatch) {
          return "Passwords do not match";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Confirm Password",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
      ),
    );
  }

  Center buildSignUpButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Implement your sign-up logic here
            Navigator.pushNamed(context, '/validate');
          }
        },
        child: Text("Validate your email !"),
      ),
    );
  }
}
