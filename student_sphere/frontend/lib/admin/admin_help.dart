import 'package:flutter/material.dart';
import 'package:student_sphere/user.dart';
import 'navbarAdmin.dart';

class AdminHelpPage extends StatelessWidget {
  final SphereUser? user;
  const AdminHelpPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Sphere",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AdminHelp(user: user),
    );
  }
}

class AdminHelp extends StatelessWidget {
  final SphereUser? user;
  const AdminHelp({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(user: user),
      appBar: AppBar(
        title: Text('Help'),
      ),
      body: Center(
        child: HelpPage(),
      ),
    );
  }
}

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          HelpItem(
            icon: Icons.edit,
            title: 'Edit Module',
            description: 'Modify the details of an existing module.',
          ),
          HelpItem(
            icon: Icons.delete,
            title: 'Delete Module',
            description: 'Remove the module from the list.',
          ),
          HelpItem(
            icon: Icons.publish_rounded,
            title: 'Publish Module',
            description: 'Make the module available for students to enroll.',
          ),
          HelpItem(
            icon: Icons.visibility_off_outlined,
            title: 'Unpublish Module',
            description: 'Hide the module from student view.',
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
