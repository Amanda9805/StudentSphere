import 'package:flutter/material.dart';
import 'package:student_sphere/user.dart';
import 'navbarStudent.dart';

class StudentProfilePage extends StatefulWidget {
  final SphereUser? user;
  const StudentProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  SphereUser? user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  void updateUser(SphereUser? newUser) {
    setState(() {
      user = newUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Sphere",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StudentProfile(user: user, updateUser: updateUser),
    );
  }
}

class StudentProfile extends StatefulWidget {
  final SphereUser? user;
  final Function(SphereUser?) updateUser;

  const StudentProfile({Key? key, required this.user, required this.updateUser}) : super(key: key);

  @override
  _StudentProfileState createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(user: widget.user, updateUser: widget.updateUser),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Set the desired height
        child: AppBar(
          backgroundColor: Color(0xFF01324D),
          elevation: 0, // Remove the shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20), // Adjust the value as needed
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      body: Center(
        child: ProfilePage(user: widget.user),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final SphereUser? user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String fullName = '${user?.fname ?? ''} ${user?.lname ?? ''}';

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/images/profile.png',
              width: 100.0,
              height: 100.0,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Basic Information',
              style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center, // Center the heading text
            ),
          ),
          SizedBox(height: 16.0),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: $fullName',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Student ID: ${user?.username ?? 'N/A'}',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Email Address: ${user?.email ?? 'N/A'}',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Degree: ${user?.degree ?? 'N/A'}',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const HelpItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40.0, color: Theme.of(context).primaryColor),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  description,
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
