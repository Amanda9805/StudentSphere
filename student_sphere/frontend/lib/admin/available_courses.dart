import 'package:flutter/material.dart';
import 'package:student_sphere/user.dart';
import '../auth_service.dart';
import '../degree.dart';
import 'navbarAdmin.dart';
import 'degree_page.dart';

class AdminAvailableCoursesPage extends StatelessWidget {
  final SphereUser? user;
  const AdminAvailableCoursesPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        title: Text('Modify Degrees and Courses'),
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
  _AdminAvailableCoursesDashboardState createState() => _AdminAvailableCoursesDashboardState();
}

class _AdminAvailableCoursesDashboardState extends State<AdminAvailableCoursesDashboard> {
  List<Degree> undergraduateDegrees = [];
  List<Degree> postgraduateDegrees = [];

  @override
  void initState() {
    super.initState();
    fetchDegrees();
  }

  Future<void> fetchDegrees() async {
    List<Degree>? allDegrees = (await AuthService.fetchDegrees()).cast<Degree>();

    setState(() {
      undergraduateDegrees = allDegrees!.where((degree) => degree.level == 'undergraduate').toList();
      postgraduateDegrees = allDegrees.where((degree) => degree.level == 'postgraduate').toList();
    });
  }

  void _showAddModuleModal(BuildContext context, Degree degree) {
    TextEditingController codeController = TextEditingController();
    TextEditingController titleController = TextEditingController();
    TextEditingController periodController = TextEditingController();
    TextEditingController creditsController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String code = codeController.text;
                String title = titleController.text;
                String period = periodController.text;
                int credits = int.tryParse(creditsController.text) ?? 0;

                await AuthService.addModuleToDegree(degree, code, title, period, credits);
                
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddDegreeModal(BuildContext context, String level) {
    TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Degree'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String title = titleController.text;
                Degree newDegree = Degree(title: title, level: level);

                await AuthService.addDegree(newDegree);
                await fetchDegrees(); // Refresh the list after adding a degree
                
                Navigator.of(context).pop();
              },
              child: Text('Save'),
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
          _buildDegreeList('Undergraduate', undergraduateDegrees),
          _buildDegreeList('Postgraduate', postgraduateDegrees),
        ],
      ),
    );
  }

  Widget _buildDegreeList(String title, List<Degree> degrees) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _showAddDegreeModal(context, title.toLowerCase()); // Show the modal dialog for adding a degree
              },
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: degrees.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildDegreeCard(context, degrees[index]);
          },
        ),
      ],
    );
  }

  Widget _buildDegreeCard(BuildContext context, Degree degree) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DegreePage(degree: degree),
            ),
          );
        },
        child: Card(
          child: ListTile(
            title: Text(degree.title),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showAddModuleModal(context, degree); // Show the modal dialog for adding a module
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      if (degree.level == 'undergraduate') {
                        undergraduateDegrees.remove(degree);
                      } else if (degree.level == 'postgraduate') {
                        postgraduateDegrees.remove(degree);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
