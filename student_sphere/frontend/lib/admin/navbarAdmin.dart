import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_sphere/user.dart';

import '../degree.dart';
import '../main.dart';
import 'admin_help.dart';
import 'admin_home_page.dart';
import 'admin_modify_courses.dart';
import 'admin_profile.dart';
import 'available_courses.dart';

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
          const DrawerHeader(
            decoration:
                BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('images/bg.jpeg'),
                      fit: BoxFit.cover,
                    ),
                ),
            child: Text(
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
                      builder: (context) => AdminHomePage(user: user)))
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
          /*ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Modify Courses'),
            onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdminModifyPage(user: user)))
            },
          ),*/
          ListTile(
            leading: const Icon(Icons.person_2_rounded),
            title: const Text('Profile'),
            onTap: () => { Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdminProfilePage(user: user)))
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdminHelpPage(user: user)))
            },
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
