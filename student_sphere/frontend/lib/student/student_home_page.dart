import 'package:flutter/material.dart';
import 'package:student_sphere/user.dart';
import '../auth_service.dart';
import '../degree.dart';
import '../module.dart';
import 'navbarStudent.dart';

class StudentHomePage extends StatelessWidget {
  final SphereUser? user;
  const StudentHomePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Sphere",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StudentHome(user: user),
    );
  }
}

class StudentHome extends StatelessWidget {
  final SphereUser? user;
  const StudentHome({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(user: user),
      appBar: AppBar(
        title: Text('Welcome Student, ${user!.fname} ${user!.lname}'),
      ),
      body: Center(
        child: StudentHomeDashboard(user: user),
      ),
    );
  }
}

class StudentHomeDashboard extends StatefulWidget {
  final SphereUser? user;
  const StudentHomeDashboard({Key? key, this.user}) : super(key: key);

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

  Future<void> fetchRegisteredModules() async {
    try {
      final List<Module>? modules =
          await AuthService.fetchUserModules(widget.user!.id);
      setState(() {
        registeredModules = modules!;
      });
    } catch (error) {
      print('Error fetching registered modules: $error');
    }
  }

  void _deleteModule(Module module) async {
    try {
      // Print user object before deletion
      print('User before deletion: ${widget.user}');

      // Remove the module from the registeredModules list
      setState(() {
        registeredModules.remove(module);
      });

      // Update the user's registeredModules in the database
      await AuthService.deleteUserModule(widget.user!.id, module.id);

      // Manually update the user's registeredModules list
      final updatedUser = widget.user!.copyWith(
        registeredModules: List.from(widget.user!.registeredModules)
          ..remove(module),
      );

      // Print user object after deletion
      print('User after deletion: $updatedUser');

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModuleList('Registered Courses', registeredModules),
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
        DataColumn(label: Text('Module Code')),
        DataColumn(label: Text('Module Title')),
        DataColumn(label: Text('Credits')),
        DataColumn(label: Text('Period')),
        DataColumn(label: Text('Action')),
      ],
      rows: modules.map((module) {
        return DataRow(cells: [
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
