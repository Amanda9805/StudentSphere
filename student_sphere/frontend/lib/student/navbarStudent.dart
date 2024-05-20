import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_sphere/user.dart';

import '../degree.dart';
import '../main.dart';
import 'student_home_page.dart';
import 'student_modify_courses.dart';

class NavBar extends StatelessWidget {
  final SphereUser? user;
  const NavBar({super.key, required this.user});

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out the user
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainApp()));
    } catch (e) {
      print("Error signing out: $e");
      // Handle any errors, such as displaying an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: const Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.input),
            title: const Text('Home'),
            onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentHomePage(user: user)))
            },
          ),
          /*ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Available Courses'),
            onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AdminAvailableCoursesPage(user: user)))
            },
          ),*/
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Modify Courses'),
            onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          StudentModifyCoursesPage(user: user)))
            },
          ),
          /*ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentHelpPage(user: user)))
            },
          ),*/
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Profile'),
            onTap: () => {Navigator.pushNamed(context, '/profile')},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () => {_logout(context)},
          ),
        ],
      ),
    );
  }
}
