import 'package:flutter/material.dart';
import 'admin/admin_home_page.dart';
import 'module.dart';
import 'student/student_home_page.dart';
import 'user_role.dart';
import 'user.dart';
import 'auth_service.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Sphere",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Register(),
    );
  }
}

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Heading
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Background image and login form
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('bg.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Center(child: RegisterForm()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

UserRole checkSnum(BuildContext context, String snum) {
  if (snum.length == 7) {
    if (snum[0] == 'A' || snum[0] == 'a') {
      return UserRole.administrator;
    } else if (snum[0] == 'S' || snum[0] == 's') {
      return UserRole.student;
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Invalid Student Number'),
            content: const Text('Student number should begin with "a" or "s".'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Student Number'),
          content: const Text(
              'Student number should be 7 characters long and begin with "a" or "s".'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  return UserRole.unknown;
}

bool validPassword(BuildContext context, String pass1, String pass2) {
  if (pass1 == pass2) {
    return true;
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error: Passwords do not match'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  return false;
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  final TextEditingController snumController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController password1Controller = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();

  UserRole _userRole = UserRole.unknown;
  String? _selectedDegree;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 3, // Adjust the elevation as needed
        margin: const EdgeInsets.all(20), // Adjust the margin as needed
        child: Padding(
          padding: const EdgeInsets.all(20), // Adjust the padding as needed
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 290,
                height: 60,
                child: TextField(
                  key: const Key('fname'),
                  controller: fnameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                ),
              ),
              SizedBox(
                width: 290,
                height: 60,
                child: TextField(
                  key: const Key('lname'),
                  controller: lnameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                ),
              ),
              SizedBox(
                width: 290,
                height: 60,
                child: TextField(
                  key: const Key('snum'),
                  controller: snumController,
                  decoration: const InputDecoration(
                      labelText: 'Student or Staff Number',
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      hintText: 'e.g s123456 or a123456'),
                  onChanged: (value) {
                    if (value.length == 7) {
                      setState(() {
                        _userRole = checkSnum(context, value);
                      });
                    }
                  },
                ),
              ),
              if (_userRole == UserRole.student)
                SizedBox(
                  width: 290,
                  height: 60,
                  child: DropdownButtonFormField<String>(
                    key: const Key('degree'),
                    decoration: const InputDecoration(
                      labelText: 'Select Your Degree Program',
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                    items: [
                      'BSc Computer Science',
                      'BIS Multimedia',
                      'BSc(Hons) Computer Science',
                      'BIS(Hons) Multimedia',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDegree = newValue;
                      });
                    },
                    value: _selectedDegree,
                  ),
                ),
              SizedBox(
                width: 290,
                height: 60,
                child: TextField(
                  key: const Key('email'),
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                ),
              ),
              SizedBox(
                width: 290,
                height: 60,
                child: TextField(
                  key: const Key('password1'),
                  controller: password1Controller,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(
                width: 290,
                height: 60,
                child: TextField(
                  key: const Key('password2'),
                  controller: password2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  obscureText: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () async {
                    // Perform registration logic here
                    String fname = fnameController.text;
                    String lname = lnameController.text;
                    String username = snumController.text;
                    UserRole role = checkSnum(context, snumController.text);
                    String email = emailController.text;
                    String pass = "";

                    SphereUser? user;

                    if (role != UserRole.unknown &&
                        validPassword(context, password1Controller.text,
                            password2Controller.text)) {
                      pass = password1Controller.text;
                      user = await AuthService.registerUser(
                          fname, lname, email, pass, username, role,
                          degree: role == UserRole.student
                              ? _selectedDegree
                              : null);
                    }

                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          // Navigate to appropriate screen based on user role
                          return user!.role == UserRole.student
                              ? StudentHomePage(user: user)
                              : AdminHomePage(user: user);
                        }),
                      );
                    } else {
                      // Handle invalid registration
                    }
                  },
                  child: const Text('Register'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
