import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../announcement.dart';
import '../auth_service.dart';
import '../module.dart';
import '../user.dart';
import 'navbarStudent.dart';

class ModuleAnnouncements extends StatelessWidget {
  final SphereUser? user;
  final Module module;
  final Function(SphereUser) updateUser;
  const ModuleAnnouncements(
      {Key? key,
      required this.user,
      required this.module,
      required this.updateUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Sphere",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ManageAnnouncements(
          module: module, user: user, updateUser: updateUser),
    );
  }
}

class ManageAnnouncements extends StatelessWidget {
  final SphereUser? user;
  final Module module;
  final Function(SphereUser) updateUser;
  const ManageAnnouncements(
      {Key? key,
      required this.user,
      required this.module,
      required this.updateUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavBar(user: user, updateUser: updateUser),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60), // Set the desired height
          child: AppBar(
            title: Text('${module.code}: Announcements',
                style: TextStyle(color: Colors.white)),
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
        body: Announcements(module: module, user: user));
  }
}

class Announcements extends StatefulWidget {
  final SphereUser? user;
  final Module module;
  const Announcements({Key? key, this.user, required this.module})
      : super(key: key);

  @override
  _AnnouncementsState createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  List<Announcement> announcements = [];

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    try {
      List<Announcement>? fetchedAnnouncements =
          await AuthService.fetchAnnouncements(widget.module);
      setState(() {
        if (fetchedAnnouncements != null) {
          print('Fetched Announcements: $fetchedAnnouncements');
          announcements = fetchedAnnouncements.reversed.toList();
        } else {
          announcements = [];
        }
      });
    } catch (error) {
      print('Failed to fetch announcements: $error');
    }
  }

  void _addAnnouncement(String title, String description) {
    AuthService.addAnnouncement(widget.module, title, description);
    setState(() {
      var updatedAnnouncements = List.from(announcements)
        ..insert(
          0, // Insert at the beginning of the list
          Announcement(
            title: title,
            description: description,
            date: DateTime.now(),
          ),
        );
      widget.module.announcements = updatedAnnouncements.cast<Announcement>();
      announcements = updatedAnnouncements.cast<Announcement>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final announcement = announcements[index];
          // Format the date to exclude milliseconds
          String formattedDate =
              DateFormat.yMd().add_Hms().format(announcement.date);
          return Card(
            child: ListTile(
              title: Text(announcement.title),
              subtitle: Text(
                '${announcement.description}\n$formattedDate', // Use the formatted date
              ),
            ),
          );
        },
      ),
    );
  }
}
