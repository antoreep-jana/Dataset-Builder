import 'package:dataset_builder/screens/home_screen.dart';
import 'package:dataset_builder/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  try{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  }catch (e){
    print("Failed to initialized Firebase : $e");
  }

  runApp(DatasetBuilderApp());
}

class DatasetBuilderApp extends StatelessWidget {
  const DatasetBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dataset Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
