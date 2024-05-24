import 'package:flutter/material.dart';
import 'package:student_sphere/user.dart';
import '../auth_service.dart';
import '../degree.dart';
import '../module.dart';
import 'navbarStudent.dart';
import 'student_module_page.dart';

class StudentHomePage extends StatefulWidget {
  final SphereUser? initialUser;

  const StudentHomePage({Key? key, required this.initialUser})
      : super(key: key);

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  SphereUser? user;

  @override
  void initState() {
    super.initState();
    user = widget.initialUser;
  }

  void updateUser(SphereUser newUser) {
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
      home: StudentHome(user: user, updateUser: updateUser),
    );
  }
}

class StudentHome extends StatelessWidget {
  final SphereUser? user;
  final Function(SphereUser) updateUser;

  const StudentHome({Key? key, required this.user, required this.updateUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(user: user, updateUser: updateUser),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Set the desired height
        child: AppBar(
          title: Text('Welcome Student, ${user!.fname} ${user!.lname}',
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
      body: Center(
        child: StudentHomeDashboard(user: user, updateUser: updateUser),
      ),
    );
  }
}

class StudentHomeDashboard extends StatefulWidget {
  final SphereUser? user;
  final Function(SphereUser) updateUser;

  const StudentHomeDashboard(
      {Key? key, required this.user, required this.updateUser})
      : super(key: key);

  @override
  _StudentHomeDashboardState createState() => _StudentHomeDashboardState();
}

class _StudentHomeDashboardState extends State<StudentHomeDashboard> {
  List<Module> registeredModules = [];

  @override
  void initState() {
    super.initState();
    fetchRegisteredModules();
  }

  int calculateTotalCredits() {
    return registeredModules.fold(0, (total, module) => total + module.credits);
  }

  Future<void> fetchRegisteredModules() async {
    try {
      final List<Module>? modules =
          await AuthService.fetchUserModules(widget.user!.id);
      setState(() {
        registeredModules = modules!;
      });

      print('Registered Modules:');
      for (Module module in registeredModules) {
        print('Code: ${module.code}');
        print('-----------------------');
      }
    } catch (error) {
      print('Error fetching registered modules: $error');
    }
  }

  void _deleteModule(Module module) async {
    try {
      // Remove the module from the registeredModules list
      setState(() {
        registeredModules.remove(module);
      });

      // Update the user's registeredModules in the database
      await AuthService.deleteUserModule(widget.user!.id, module.id);

      // Manually update the user's registeredModules list
      final updatedUser = widget.user!.copyWith(
        registeredModules: registeredModules,
      );

      // Update the state with the new user object via the callback
      widget.updateUser(updatedUser);

      print('Updated Modules:');
      for (Module module in registeredModules) {
        print('Code: ${module.code}');
        print('-----------------------');
      }

      // Display success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Module deleted successfully')),
      );
    } catch (error) {
      print('Error deleting module: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete module: $error')),
      );
    }
  }

  void _navigateToModuleAnnouncements(BuildContext context, Module module) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModuleAnnouncements(
            module: module, user: widget.user, updateUser: widget.updateUser),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModuleList('Registered Courses', registeredModules),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Total Credits:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  calculateTotalCredits().toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleList(String title, List<Module> modules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  buildModuleCard(context, modules),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildModuleCard(BuildContext context, List<Module> modules) {
    return DataTable(
      columns: [
        DataColumn(label: Text(' ')),
        DataColumn(label: Text('Module Code')),
        DataColumn(label: Text('Module Title')),
        DataColumn(label: Text('Credits')),
        DataColumn(label: Text('Period')),
        DataColumn(label: Text('Action')),
      ],
      rows: modules.map((module) {
        return DataRow(cells: [
          DataCell(
            Tooltip(
              message: 'Announcements',
              child: IconButton(
                icon: Icon(Icons.arrow_circle_right),
                onPressed: () {
                  _navigateToModuleAnnouncements(context, module);
                },
              ),
            ),
          ),
          DataCell(Text(module.code)),
          DataCell(Text(module.title)),
          DataCell(Text(module.credits.toString())),
          DataCell(Text(module.period)),
          DataCell(Tooltip(
            message: "Delete Module",
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteModule(module);
              },
            ),
          )),
        ]);
      }).toList(),
    );
  }
}
