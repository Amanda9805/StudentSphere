import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

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
            onTap: () => {},
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Profile'),
            onTap: () => {Navigator.pushNamed(context, '/profile')},
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('My Courses'),
            onTap: () => {Navigator.pushNamed(context, '/my_courses')},
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Modify Courses'),
            onTap: () => {Navigator.pushNamed(context, '/modify_courses')},
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