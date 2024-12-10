import 'package:billing/screens/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAe_LGDcXXy1d-E28i1ZyZ57yPLM16-9pM",
      authDomain: "consortium-billing-system.firebaseapp.com",
      projectId: "consortium-billing-system",
      storageBucket: "consortium-billing-system.firebasestorage.app",
      messagingSenderId: "369472321100",
      appId: "1:369472321100:web:5b3fee45140bc6ab90a6e9",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), // Set LoginScreen as the home screen
    );
  }
}
