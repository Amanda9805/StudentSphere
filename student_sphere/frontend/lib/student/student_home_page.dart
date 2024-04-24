import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_sphere/main.dart';
import 'package:student_sphere/navbar.dart';
import 'package:student_sphere/user.dart';
import 'auth_service.dart';
import 'navbar.dart';

class StudentHomePage extends StatelessWidget {
  final SphereUser? user; 
  const StudentHomePage({Key? key, required this.user}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Sphere",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StudentHome(user: user),
    );
  }
}

class StudentHome extends StatelessWidget {
  final SphereUser? user;
  const StudentHome({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Welcome Admin, ${user!.fname} ${user!.lname}'),
      ),
      body: Center(
        child: StudentPage(user: user),
      ),
    );
  }
}

Future<void> logout() async {
  try {
    await FirebaseAuth.instance.signOut();
    // Navigate to login screen or any other desired screen after logout

  } catch (e) {
    print("Error logging out: $e");
  }
}

class StudentPage extends StatelessWidget {
  final SphereUser? user;
  const StudentPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 30,
          child: TextField(
          key: const Key('fname'),
            decoration: const InputDecoration(
              labelText: 'First Name',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            logout();
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainApp()),
              );
         },
          child: Text('Logout'),
        )
      ],
    );
  }
}
