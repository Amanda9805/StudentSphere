import 'package:student_sphere/user_role.dart';
import 'package:firebase_database/firebase_database.dart'; 
import 'user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  
  static void initializeFirebase() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
  }
  
  static UserRole getRole(String role){
    if(role == "UserRole.student"){
      return UserRole.student;
    }
    else if(role == "UserRole.administrator"){
      return UserRole.administrator;
    }
    else{
      return UserRole.unknown;
    }
  }

  static Future<SphereUser?> registerUser(String fname, String lname, String email, String password,String username, UserRole role) async {
     try {
      // Initialize Firebase if not already initialized.
      initializeFirebase();

      // Register the user with Firebase Authentication.
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user's unique ID (UID)
      String userId = userCredential.user!.uid;

      DatabaseReference ref = FirebaseDatabase.instance.ref('users/$userId');

      // Create a map representing the user data
      await ref.set({
        'firstName': fname,
        'lastName': lname,
        'email': email,
        'username': username,
        'role': role.toString()
      });

      print('User data saved successfully.');

      SphereUser user = SphereUser(fname: fname, lname: lname, username: username, email: email, role: role);//id: userCredential.user?.uid, email: userCredential.user?.email);

      // Return the registered user.
      return user;
    } catch (error) {
      // Handle registration errors here.
      print("Registration failed: $error");
      return null; // Return null if registration fails.
    }
  }
  
  static Future<SphereUser?> loginUser(String email, String password) async {
    try {
      // Initialize Firebase if not already initialized.
      initializeFirebase();

      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      SphereUser? user;

      String userId = userCredential.user!.uid;
      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('users/$userId').get();

      if (snapshot.exists) {
          final userData = snapshot.value as Map<dynamic, dynamic>;

          final String fname = userData['firstName'];
          final String lname = userData['lastName'];
          final String username = userData['username'];
          final String email = userData['email'];
          final UserRole role = getRole(userData['role']);

          user = SphereUser(fname: fname, lname: lname, email: email, username: username, role: role);

      } else {
          print('No data available.');
      }

    return user;
    } catch(error) {
      print("Login failed: $error");
      return null;
    }
  }
  // Add more methods as needed
}