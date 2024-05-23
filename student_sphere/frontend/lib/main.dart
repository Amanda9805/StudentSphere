import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_sphere/register.dart';
import 'admin/admin_home_page.dart';
import 'admin/admin_modify_courses.dart';
import 'module.dart';
import 'student/student_home_page.dart';
import 'user_role.dart';
import 'user.dart';
import 'auth_service.dart';
import 'package:idle_detector_wrapper/idle_detector_wrapper.dart';
import 'package:flutter_logs/flutter_logs.dart';

void main() {
  AuthService.initializeFirebase();
  runApp(MaterialApp(
    home: MainApp(),
  ));
}


class MainApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out the user
      navigatorKey.currentState!.pushReplacement(MaterialPageRoute(builder: (context) => MainApp()));
    } catch (e) {
      print("Error signing out: $e");
      // Handle any errors, such as displaying an error message to the user
    }
  }

  void _showSessionExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Session Expired"),
          content: Text("Your session has expired after 5 minutes of inactivity."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                _logout(); // Log out the user after dismissing the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Sphere",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorKey: navigatorKey,
      home: IdleDetector(
        idleTime: const Duration(minutes: 5),
        onIdle: () {
          // Show session expired dialog when the user becomes idle
          _showSessionExpiredDialog(context);
        },
        child: InitialPage(),
      ),
    );
  }
}

class InitialPage extends StatelessWidget {
  const InitialPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Heading
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Welcome to Student Sphere',
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
                      image: AssetImage('images/bg2.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Center(
                  child: LoginForm(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool showErrorMessage = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Card(
        elevation: 3,
        margin: EdgeInsets.all(20),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 250,
                height: 90,
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                ),
              ),
              SizedBox(
                width: 250,
                height: 90,
                child: TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  obscureText: true,
                ),
              ),
              if (showErrorMessage)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Email or password is incorrect',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      showErrorMessage = false;
                    });

                    // Perform login logic here
                    SphereUser? user = await AuthService.loginUser(
                        emailController.text, passwordController.text);
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          // Navigate to appropriate screen based on user role
                          return user.role == UserRole.student
                              ? StudentHomePage(initialUser: user)
                              : AdminHomePage(user: user);
                        }),
                      );
                    } else {
                      // Handle invalid login
                      setState(() {
                        showErrorMessage = true;
                      });
                    }
                  },
                  child: const Text('Login'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegistrationPage()),
                    );
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
