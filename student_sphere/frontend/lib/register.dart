// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'admin_home_page.dart';
import 'student_home_page.dart';
import 'user_role.dart';
import 'user.dart';
import 'auth_service.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Sphere",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Register(),
    );
  }
}

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: const Center(
        child: RegisterForm(),
      ),
    );
  }
}


UserRole checkSnum(BuildContext context, String snum) {
  if (snum.length == 7) {
    if (snum[0] == 'A' || snum[0] =='a') {
      return UserRole.administrator;
    } else if (snum[0] == 'S' || snum[0] =='s') {
      return UserRole.student;
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Invalid Student Number'),
            content: Text('Student number should begin with "a" or "s".'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invalid Student Number'),
          content: Text('Student number should be 7 characters long and begin with "a" or "s".'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  return UserRole.unknown;
}

bool validPassword(BuildContext context, String pass1, String pass2) {
  if(pass1 == pass2) {
    return true;
  }
  else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error: Passwords do not match'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  return false;
}
class RegisterForm extends StatelessWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController fnameController = TextEditingController();
    TextEditingController lnameController = TextEditingController();
    TextEditingController snumController = TextEditingController();
    TextEditingController usernameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController password1Controller = TextEditingController();
    TextEditingController password2Controller = TextEditingController();
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 400,
          height: 30,
          child: TextField(
          key: const Key('fname'),
          controller: fnameController,
            decoration: const InputDecoration(
              labelText: 'First Name',
            ),
          ),
        ),
        SizedBox(
          width: 400,
          height: 30,
          child: TextField(
          key: const Key('lname'),
          controller: lnameController,
            decoration: const InputDecoration(
              labelText: 'Last Name',
            ),
          ),
        ),
        SizedBox(
          width: 400,
          height: 30,
          child: TextField(
          key: const Key('snum'),
          controller: snumController,
            decoration: const InputDecoration(
              labelText: 'Student or Staff Number',
              hintText: 'e.g s123456 or a123456'
            ),
          ),
        ),
        SizedBox(
          width: 400,
          height: 30,
          child: TextField(
          key: const Key('email'),
          controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
          ),
        ),
        SizedBox(
          width: 400,
          height: 30,
          child: TextField(
          key: const Key('password1'),
          controller: password1Controller,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
            obscureText: true,
          ),
        ),
        SizedBox(
          width: 400,
          height: 30,
          child: TextField(
          key: const Key('password2'),
          controller: password2Controller,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
            ),
            obscureText: true,
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            // Perform registration logic here
            String fname = fnameController.text;
            String lname = lnameController.text;
            String username = snumController.text;
            UserRole role = checkSnum(context, snumController.text);
            String email = emailController.text;
            String pass = "";
            
            SphereUser? user;
            
            if(role != UserRole.unknown && validPassword(context, password1Controller.text, password2Controller.text)) {
              pass = password1Controller.text;
              user = await AuthService.registerUser(fname, lname, email, pass, username, role);
            }

            if (user != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  // Navigate to appropriate screen based on user role
                  return user?.role == UserRole.student
                      ? StudentHomePage(user: user)
                      : AdminHomePage(user: user);
                }),
              );
            } else {
              // Handle invalid login
            }
          },
          child: Text('Register'),

        ),
      ],
    );
  }
}