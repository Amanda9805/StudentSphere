import 'package:flutter/material.dart';

class DegreePage extends StatelessWidget {
  const DegreePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Sphere",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DegreeData(),
    );
  }
}

class DegreeData extends StatelessWidget {
  const DegreeData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //body: ManageDegree()
    );
  }
}
