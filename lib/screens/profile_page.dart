import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? kaggleUsername;
  String? kaggleKey;

  // Firebase user data
  User? firebaseUser;
  final TextEditingController _displayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadKaggleCredentials();
    _loadFirebaseUser();
  }

  // Load Firebase User
  Future<void> _loadFirebaseUser() async {
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      firebaseUser = user;
      _displayNameController.text = user?.displayName ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ------------------ FIREBASE USER ----------------------
              Text(
                "User Information",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),

              firebaseUser == null
                  ? Text("No Firebase user logged in.")
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Email: ${firebaseUser!.email ?? 'No email'}"),
                  SizedBox(height: 10),

                  TextField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Display Name",
                    ),
                  ),

                  SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await firebaseUser!.updateDisplayName(
                            _displayNameController.text.trim());
                        await firebaseUser!.reload();
                        _loadFirebaseUser();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Display name updated"),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    },
                    child: Text("Save Display Name"),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // ------------------ KAGGLE SECTION ----------------------
              Text("Kaggle Credentials",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),

              kaggleUsername != null
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Username: $kaggleUsername"),
                  Text("API Key: ${kaggleKey!.substring(0, 4)}****"),
                ],
              )
                  : Text("No Kaggle Credentials saved."),

              SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () {
                  _pickKaggleJson();
                },
                icon: Icon(Icons.upload_file),
                label: Text("Upload kaggle.json"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------- LOAD KAGGLE CREDS ------------------------
  Future<void> _loadKaggleCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      kaggleUsername = prefs.getString('kaggle_username');
      kaggleKey = prefs.getString("kaggle_key");
    });
  }

  // --------------------- PICK kaggle.json ------------------------
  Future<void> _pickKaggleJson() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null) return;

    final filePath = result.files.single.path;
    if (filePath == null) return;

    final file = File(filePath);
    final jsonString = await file.readAsString();

    try {
      final data = jsonDecode(jsonString);

      if (data.containsKey("username") && data.containsKey("key")) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('kaggle_username', data['username']);
        await prefs.setString('kaggle_key', data['key']);

        setState(() {
          kaggleUsername = data['username'];
          kaggleKey = data['key'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Kaggle credentials saved successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kaggle credentials Error!")),
      );
      throw FormatException("Invalid Kaggle JSON format");
    }
  }
}