import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dataset_page.dart';
import 'package:path_provider/path_provider.dart';

class CreateDatasetScreen extends StatefulWidget {
  @override
  State<CreateDatasetScreen> createState() => _CreateDatasetScreenState();
}

class _CreateDatasetScreenState extends State<CreateDatasetScreen> {
  String datasetType = "Image Classification"; // Only type for now
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();

  Future<String> _getDatasetRootFolder() async{
    final dir = await getApplicationDocumentsDirectory();
    final datasetsDir = Directory("${dir.path}/datasets");

    if (!datasetsDir.existsSync()){
      datasetsDir.createSync(recursive: true);
    }

    return datasetsDir.path;
  }


  void createDataset() async{
    // TODO: Save dataset to Local Storage later

    final datasetName = nameController.text.trim();
    final description = descController.text.trim();

    if (datasetName.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dataset name cannot be empty")));
    return;
    }

    final rootPath = await _getDatasetRootFolder();

    final datasetPath = "$rootPath/$datasetName";

    final datasetDir = Directory(datasetPath);

    if (!datasetDir.existsSync()){
      datasetDir.createSync(recursive: true);
    }

    // Create classes folder

    // final classesDir = Directory("$datasetPath/classes");
    //
    // if (!classesDir.existsSync()){
    //   classesDir.createSync();
    // }

    // Optional : List of classes (empty for now)
    final List<String> classNames = [];
    // Build initial classes array with counts (all zero for now)
    final List<Map<String, dynamic>> classesWithCounts = classNames.map((className) {
      return {
        "name" : className,
        "counts" : {"training" : 0, "validation" : 0, "testing" : 0}
    };}).toList();

    // Create dataset.json
    final jsonFile = File("$datasetPath/dataset.json");
    jsonFile.writeAsStringSync(jsonEncode({
      "name" : datasetName,
      "description" : description,
      "type" : datasetType,
      "createdAt" : DateTime.now().toIso8601String(),
      "classes" : classesWithCounts
    }));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DatasetPage(
          datasetName: datasetName,
          description: description,

        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Dataset")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Dataset Type
            Text("Dataset Type", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            DropdownButtonFormField(
              value: datasetType,
              items: [
                DropdownMenuItem(
                    value: "Image Classification",
                    child: Text("Image Classification")),
                // Later add:
                DropdownMenuItem(value: "Object Detection", child: Text("Object Detection")),
              ],
              onChanged: (value) {
                setState(() {
                  datasetType = value!;
                });
              },
            ),

            SizedBox(height: 20),

            /// Dataset Name
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Dataset Name",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            /// Description
            TextField(
              controller: descController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 30),

            /// CREATE BTN
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: createDataset,
                child: Text("Create Dataset"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
