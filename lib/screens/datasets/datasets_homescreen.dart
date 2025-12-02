import 'dart:convert';
import 'dart:io';

import 'package:dataset_builder/screens/datasets/dataset_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'create.dart';

class MyDatasetsScreen extends StatefulWidget {
  MyDatasetsScreen({super.key});

  @override
  State<MyDatasetsScreen> createState() => _MyDatasetsScreenState();
}

class _MyDatasetsScreenState extends State<MyDatasetsScreen> {
  // Future<List<String, dynamic>> fetchLocalDatasets() async{

  //
  // List<Map<String, dynamic>> localDatasets = [
  //   {"name" : "Cats vs Dogs", "synced" : true},
  //   {"name" : "Fruits Dataset", "synced" : false},
  //   {"name" : "Road Signs", "synced" : true}
  // ];

    // final List<Map<String, dynamic>> localDatasets = [];
   List<Map<String, dynamic>> localDatasets = [];
  final List<String> kaggleDatasets = ["Urban Street View", "Medical X-Ray Collection", "Flower Species Dataset"];

  // Future<List<Map<String, dynamic>>> fetchKaggleDatasets() async{}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadLocalDatasets();
  }

    // --------------------
    // Get datasets folder
    // --------------------

    Future<String> _getDatasetRoot() async{
    final dir = await getApplicationDocumentsDirectory();
    final datasetsDir = Directory("${dir.path}/datasets");

    if (!datasetsDir.existsSync()){
      datasetsDir.createSync(recursive: true);
    }

    return datasetsDir.path;
    }


    // --------------------------
    // Load datasets from storage
    // --------------------------
  Future<void> loadLocalDatasets() async{
    final root = await _getDatasetRoot();
    final dir = Directory(root);

    final folders = dir.listSync().whereType<Directory>();

    List<Map<String, dynamic>> results = [];

    for (var folder in folders){
      final jsonFile = File("${folder.path}/dataset.json");

      if(jsonFile.existsSync()){
        try{
          final data = jsonDecode(jsonFile.readAsStringSync());
          print("Data returned $data");

          results.add({"name" : data['name'], "synced" : false});
        }catch (e){
          print("Error reading JSON : $e");
        }
      }

    }

    setState(() {
      localDatasets = results;
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Datasets"),),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async{
        await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateDatasetScreen()));
        loadLocalDatasets();
      }),
      body: Padding(padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION : LOCAL Datasets
            Text("On This Device",
            style : TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold
            )
            ),
            SizedBox(height : 10),

            ...localDatasets.map((ds) => datasetTile(
              context,
              ds["name"], ds["synced"]
            )),

            SizedBox(height: 30,),


            // SECTION : KAGGLE CLOUD Datatsets

            Text("On Kaggle Cloud",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            )
            ),

            SizedBox(height: 10,),

            ...kaggleDatasets.map((ds) => kaggleDatasetTile(ds))
          ],
        ),
      ),
      )
    );
  }
}


Widget datasetTile(BuildContext context, String name, bool synced){
  return Card(
    child: ListTile(
      leading: Icon(Icons.folder, size : 32),
      title : Text(name),
      subtitle: Text(synced ? "Synced with Kaggle" : "Not Synced"),
      trailing: synced? Icon(Icons.cloud_done, color: Colors.green,) : Icon(Icons.cloud_off, color : Colors.grey),
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => DatasetPage(datasetName: name, description: "Local Dataset")));
      },
    ),
  );
}

Widget kaggleDatasetTile(String name){

  return Card(
    child: ListTile(
      leading: Icon(Icons.cloud, color : Colors.blue, size : 32),

      title : Text(name),
      subtitle: Text("Kaggle Cloud dataset"),
      trailing: Icon(Icons.arrow_forward_ios, size : 18),
    ),
  );
}