import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:socio_care/core/navigation/app_route.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter is initialized before using platform channels
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with the default options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SocioCare',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: appRouter,
    );
  }
}