import 'package:flutter/material.dart';
import 'package:school_erp/screens/login_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  // 1. Mandatory for async setup
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SchoolApp());
}

class SchoolApp extends StatelessWidget {
  const SchoolApp({super.key});

  @override
  Widget build(BuildContext context) {return MaterialApp(
    debugShowCheckedModeBanner: false, // This removes the "Debug" banner
    title: 'School ERP',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true, // This gives it a modern look
    ),
    // This is the first screen login screen :
    home: const LoginScreen(),
  );}
}
