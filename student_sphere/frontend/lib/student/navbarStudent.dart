import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_sphere/user.dart';
import '../main.dart';
import 'student_home_page.dart';
import 'student_modify_courses.dart';
import 'student_profile.dart';

class NavBar extends StatelessWidget {
  final SphereUser? user;
  final Function(SphereUser) updateUser; // Add updateUser as a parameter

  const NavBar({Key? key, required this.user, required this.updateUser})
      : super(key: key);

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
                      image: AssetImage('assets/images/bg2.jpg'),
                      fit: BoxFit.cover,
                    ),
                ),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_filled),
            title: const Text('Home'),
            onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentHomePage(initialUser: user)))
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Modify Courses'),
            onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentModifyCoursesPage(
                          user: user, updateUser: updateUser)))
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_2_rounded),
            title: const Text('Profile'),
            onTap: () => {Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentProfilePage(
                          user: user)))
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
