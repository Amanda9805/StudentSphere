import 'package:flutter/material.dart';
import 'package:student_sphere/user.dart';
import 'navbarAdmin.dart';

class AdminProfilePage extends StatelessWidget {
  final SphereUser? user;
  const AdminProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Sphere",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AdminProfile(user: user),
    );
  }
}

class AdminProfile extends StatelessWidget {
  final SphereUser? user;
  const AdminProfile({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(user: user),
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
        child: ProfilePage(user: user),
      )
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
              'images/profile.png',
              width: 100.0,
              height: 100.0,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Basic Information',
              style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold),
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
                    'Staff ID: ${user?.username ?? 'N/A'}',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Email Address: ${user?.email ?? 'N/A'}',
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
