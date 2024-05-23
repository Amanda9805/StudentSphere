import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_sphere/user.dart';
import '../auth_service.dart';
import '../degree.dart';
import '../main.dart';
import '../module.dart';
import '../user_role.dart';
import 'navbarAdmin.dart';
import 'degree_page.dart';

class AccessDeniedDialog extends StatelessWidget {
  final Function() onOkayPressed;

  const AccessDeniedDialog({Key? key, required this.onOkayPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Access Denied'),
      content: Text('You need to be an admin to access this page.'),
      actions: <Widget>[
        ElevatedButton(
          onPressed: onOkayPressed,
          child: Text('Okay', style: TextStyle(color: Color(0xFF01324D))),
        ),
      ],
    );
  }
}


class AdminHomePage extends StatelessWidget {
  final SphereUser? user;
  const AdminHomePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     // Check if the user is an admin before allowing access
    if (user?.role != UserRole.administrator) {
      // Render an access denied page or redirect the user to another page
      return Scaffold(
        body: Center(
          child: AccessDeniedDialog(
            onOkayPressed: () async {
              // Log out the user when "Okay" is clicked
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainApp()),
                );
              } catch (e) {
                print("Error signing out: $e");
                // Handle any errors, such as displaying an error message to the user
              }
            },
          ),
        ),
      );
    }
    return MaterialApp(
      title: "Student Sphere",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AdminAvailableCourses(user: user),
    );
  }
}

class AdminAvailableCourses extends StatelessWidget {
  final SphereUser? user;
  const AdminAvailableCourses({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(user: user),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Set the desired height
        child: AppBar(
          title: Text(
            'Welcome Admin, ${user!.fname} ${user!.lname}', 
            style: TextStyle(color: Colors.white)
            ),
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
        child: AdminAvailableCoursesDashboard(user: user),
      ),
    );
  }
}

class AdminAvailableCoursesDashboard extends StatefulWidget {
  final SphereUser? user;
  const AdminAvailableCoursesDashboard({Key? key, this.user}) : super(key: key);

  @override
  _AdminAvailableCoursesDashboardState createState() =>
      _AdminAvailableCoursesDashboardState();
}

class _AdminAvailableCoursesDashboardState
    extends State<AdminAvailableCoursesDashboard> {
  List<Module> undergraduateModules = [];
  List<Module> postgraduateModules = [];

  @override
  void initState() {
    super.initState();
    fetchModules();
  }

  Future<void> fetchModules() async {
    final Map<String, List<Module>> categorizedModules =
        await AuthService.fetchModules();

    print(
        "Fetched undergraduate modules: ${categorizedModules['undergraduate']}");
    print(
        "Fetched postgraduate modules: ${categorizedModules['postgraduate']}");

    setState(() {
      undergraduateModules = categorizedModules['undergraduate'] ?? [];
      postgraduateModules = categorizedModules['postgraduate'] ?? [];
    });
  }

  /*Future<void> fetchDegrees() async {
    List<Degree>? allDegrees =
        (await AuthService.fetchDegrees()).cast<Degree>();

    setState(() {
      undergraduateModules = allDegrees!
          .where((degree) => degree.level == 'undergraduate')
          .toList();
      postgraduateModules =
          allDegrees.where((degree) => degree.level == 'postgraduate').toList();
    });
  }*/

  void _showAddModuleModal(BuildContext context) {
  TextEditingController codeController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController periodController = TextEditingController();
  TextEditingController creditsController = TextEditingController();
  String? selectedLevel;
  bool published = false; // Initialize with false

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text('Add Module'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: codeController,
                  decoration: InputDecoration(labelText: 'Module Code'),
                ),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextFormField(
                  controller: periodController,
                  decoration: InputDecoration(labelText: 'Period'),
                ),
                TextFormField(
                  controller: creditsController,
                  decoration: InputDecoration(labelText: 'Credits'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedLevel,
                  hint: Text('Select Level'),
                  items: ['Undergraduate', 'Postgraduate']
                      .map((level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLevel = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Level'),
                ),
                DropdownButtonFormField<bool>(
                  value: published,
                  hint: Text('Published'),
                  items: [
                    DropdownMenuItem(
                      value: true,
                      child: Text('Yes'),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Text('No'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      published = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Publish'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Color(0xFF01324D))),
            ),
            ElevatedButton(
              onPressed: () async {
                String code = codeController.text;
                String title = titleController.text;
                String period = periodController.text;
                String credits = creditsController.text;
                String level = selectedLevel ?? '';

                if (code.isEmpty ||
                    title.isEmpty ||
                    period.isEmpty ||
                    credits.isEmpty ||
                    level.isEmpty) {
                  _showResultDialog(context, "All fields must be completed.");
                } else {
                  // Check if the module already exists
                  bool isDuplicateUndergrad = undergraduateModules.any((module) =>
                      (module.code).toLowerCase() == code.toLowerCase());

                  bool isDuplicatePostgrad = postgraduateModules.any((module) =>
                      (module.code).toLowerCase() == code.toLowerCase());

                  if (isDuplicateUndergrad || isDuplicatePostgrad) {
                    _showResultDialog(
                        context, "Module already exists.");
                  } else {
                    int creditsValue = int.tryParse(credits) ?? 0;
                    String result = await AuthService.addModule(
                      code,
                      title,
                      period,
                      creditsValue,
                      level,
                      published, // Pass the selected value
                    );

                    Navigator.of(context).pop();
                    _showResultDialog(context, result);
                    fetchModules();
                  }
                }
              },
              child: Text('Save', style: TextStyle(color: Color(0xFF01324D))),
            ),
          ],
        );
      });
    },
  );
}


  void _showEditModuleModal(BuildContext context, Module module) {
    TextEditingController codeController =
        TextEditingController(text: module.code);
    TextEditingController titleController =
        TextEditingController(text: module.title);
    TextEditingController periodController =
        TextEditingController(text: module.period);
    TextEditingController creditsController =
        TextEditingController(text: module.credits.toString());
    String? selectedLevel =
        module.level; // Initialize selected level with module's current level
    bool published = module.published; // Initialize with false

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Module'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: codeController,
                  decoration: InputDecoration(labelText: 'Module Code'),
                ),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextFormField(
                  controller: periodController,
                  decoration: InputDecoration(labelText: 'Period'),
                ),
                TextFormField(
                  controller: creditsController,
                  decoration: InputDecoration(labelText: 'Credits'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedLevel,
                  hint: Text('Select Level'),
                  items: ['Undergraduate', 'Postgraduate']
                      .map((level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLevel = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Level'),
                ),
                DropdownButtonFormField<bool>(
                  value: published,
                  hint: Text('Published'),
                  items: [
                    DropdownMenuItem(
                      value: true,
                      child: Text('Yes'),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Text('No'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      published = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Publish'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Color(0xFF01324D))),
            ),
            ElevatedButton(
              onPressed: () async {
                String code = codeController.text;
                String title = titleController.text;
                String period = periodController.text;
                int credits = int.tryParse(creditsController.text) ?? 0;
                String level = selectedLevel ?? '';

                Module updatedModule = Module(
                    id: module.id,
                    code: code,
                    title: title,
                    period: period,
                    credits: credits,
                    level: level,
                    published: published);

                String result = await AuthService.updateModule(updatedModule);

                Navigator.of(context).pop();
                _showResultDialog(context, result); // Show result alert dialog
                fetchModules();
              },
              child: Text('Save Changes', style: TextStyle(color: Color(0xFF01324D))),
            ),
          ],
        );
      },
    );
  }

  void _showResultDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Result'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Color(0xFF01324D))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModuleList('Undergraduate Courses', undergraduateModules),
          _buildModuleList('Postgraduate Courses', postgraduateModules),
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
                crossAxisAlignment: CrossAxisAlignment.center, // Adjusted
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: IconButton(
                          icon: Icon(Icons.add_box),
                          onPressed: () {
                            _showAddModuleModal(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  buildModuleCard(context, modules), // Pass modules directly
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
        DataColumn(
          label: Text('Actions'), // Column for Edit and Delete buttons
        ),
      ],
      rows: modules.map((module) {
        return DataRow(cells: [
          DataCell(Text(module.code)),
          DataCell(Text(module.title)),
          DataCell(Text(module.credits.toString())),
          DataCell(Text(module.period)),
          DataCell(
            Row(
              children: [
                Tooltip(
                  message: 'Edit',
                  child: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditModuleModal(context, module);
                    },
                  ),
                ),
                Tooltip(
                  message: 'Delete',
                  child: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      _showDeleteModuleModal(context, module);
                    },
                  ),
                ),
                Tooltip(
                  message: 'Publish',
                  child: IconButton(
                    icon: Icon(Icons.publish_rounded),
                    onPressed: () {
                      _showPublishModuleModal(context, module);
                    },
                  ),
                ),
                Tooltip(
                  message: 'Unpublish',
                  child: IconButton(
                    icon: Icon(Icons.visibility_off_outlined),
                    onPressed: () {
                      _showHideModuleModal(context, module);
                    },
                  ),
                ),
              ],
            ),
          ),
        ]);
      }).toList(),
    );
  }

  void _showDeleteModuleModal(BuildContext context, Module module) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Module'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to delete this module?'),
                SizedBox(height: 10),
                Text('Module Code: ${module.code}'),
                Text('Title: ${module.title}'),
                Text('Period: ${module.period}'),
                Text('Credits: ${module.credits}'),
                Text('Level: ${module.level}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel', style: TextStyle(color: Color(0xFF01324D))),
            ),
            ElevatedButton(
              onPressed: () async {
                String result = await AuthService.deleteModule(module.id);
                Navigator.of(context).pop(); // Close the dialog
                _showResultDialog(context, result); // Show result alert dialog
                if (result == 'Module deleted successfully') {
                  fetchModules(); // Refresh the modules list
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showPublishModuleModal(BuildContext context, Module module) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Publish Module', style: TextStyle(color: Color(0xFF01324D))),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Module Code: ${module.code}'),
                Text('Title: ${module.title}'),
                Text('Period: ${module.period}'),
                Text('Credits: ${module.credits}'),
                Text('Level: ${module.level}'),
                Text('Published: ${module.published}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel', style: TextStyle(color: Color(0xFF01324D))),
            ),
            ElevatedButton(
              onPressed: () async {
                String result =
                    await AuthService.setModulePublishStatus(module.id, true);
                Navigator.of(context).pop(); // Close the dialog
                _showResultDialog(context, result); // Show result alert dialog
                fetchModules(); // Refresh the modules list
              },
              child: Text('Publish', style: TextStyle(color: Color(0xFF01324D))),
            ),
          ],
        );
      },
    );
  }

  void _showHideModuleModal(BuildContext context, Module module) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unpublish Module'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Module Code: ${module.code}'),
                Text('Title: ${module.title}'),
                Text('Period: ${module.period}'),
                Text('Credits: ${module.credits}'),
                Text('Level: ${module.level}'),
                Text('Published: ${module.published}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel', style: TextStyle(color: Color(0xFF01324D))),
            ),
            ElevatedButton(
              onPressed: () async {
                String result =
                    await AuthService.setModulePublishStatus(module.id, false);
                Navigator.of(context).pop(); // Close the dialog
                _showResultDialog(context, result); // Show result alert dialog
                fetchModules(); // Refresh the modules list
              },
              child: Text('Unpublish', style: TextStyle(color: Color(0xFF01324D))),
            ),
          ],
        );
      },
    );
  }
}
