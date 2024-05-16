import 'package:flutter/material.dart';
import 'package:student_sphere/user.dart';

import '../degree.dart';
import 'admin_home_page.dart';
import 'admin_modify_courses.dart';
import 'available_courses.dart';

class NavBar extends StatelessWidget {
  final SphereUser? user;
  const NavBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary),
            child: const Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.input),
            title: const Text('Home'),
            onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => AdminHomePage(user: user)))},
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Profile'),
            onTap: () => {Navigator.pushNamed(context, '/profile')},
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Available Courses'),
            onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => AdminAvailableCoursesPage(user: user)))},
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Modify Courses'),
            onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => AdminModifyPage(user: user)))},
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            onTap: () => {Navigator.pushNamed(context, '/help')},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () => {Navigator.popUntil(context, ModalRoute.withName("/"))},
          ),
        ],
      ),
    );
  }
}