import 'dart:io';
import 'package:dataset_builder/screens/datasets/class/class_details.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../services/dataset_storage.dart';

class ClassOverview extends StatefulWidget {

  final String dataset;
  // final String subset;

  const ClassOverview({super.key,
  required this.dataset,
    // required this.subset
  });

  @override
  State<ClassOverview> createState() => _ClassOverviewState();
}

class _ClassOverviewState extends State<ClassOverview> {

  List<String> classNames = [];
  Map<String, int> cachedImageCounts = {};

  bool loading = true;

  @override
  void initState(){
    super.initState();
    loadClasses();
  }

  Future<void> loadClasses() async{
    // final classes = await DatasetStorage.listClasses(widget.dataset);
    final dir = await getApplicationDocumentsDirectory();
    final subsetDir = Directory("${dir.path}/datasets/${widget.dataset}/training/");

    final classes = subsetDir.listSync().where((e) => e is Directory).map((e) => e.path.split("/").last).toList();
    setState(() {
      classNames = classes;
      loading = false;
    });



    // Load image counts efficiently

    // for (var cls in classes){
    //   DatasetStorage.getImages()
    // }
  }

  Future<void> deleteClass(String datasetName, String className, BuildContext context) async{
    final dir = await getApplicationDocumentsDirectory();
    final dataset_path = "${dir.path}/datasets/${datasetName}";

    final subsets = ['training', 'validation', 'testing'];

    for (var subset in subsets){
      final subset_path = Directory("$dataset_path/$subset/$className");
      subset_path.deleteSync();
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Class $className deleted")));

    loadClasses();
  }

  // void addClassDialog() {
  //   TextEditingController classController = TextEditingController();
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text("Add Class"),
  //       content: TextField(
  //         controller: classController,
  //         decoration: InputDecoration(hintText: "Class Name (folder)"),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //           },
  //           child: Text("Cancel"),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             setState(() {
  //               // classes.add(classController.text.trim());
  //               addClass(classController.text.trim());
  //             });
  //             Navigator.pop(context);
  //           },
  //           child: Text("Add"),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // void addClass(String className) async{
  //
  //   if (className.trim().isEmpty) return;
  //
  //
  //   final dir = await getApplicationDocumentsDirectory();
  //   final datasetDir = Directory("${dir.path}/datasets/${widget.datasetName}");
  //
  //   // Subsets
  //   final subsets = ["training", "validation", "testing"];
  //
  //   try{
  //     for (var subset in subsets) {
  //       print("Creating subset $subset");
  //       final subsetDir = Directory("${datasetDir.path}/$subset");
  //
  //       // Make sure subset folder exists
  //       if (!subsetDir.existsSync()) {
  //         subsetDir.createSync(recursive: true);
  //       }
  //
  //       // Create the class folder inside the subset
  //       final classDir = Directory("${subsetDir.path}/$className");
  //
  //       if (!classDir.existsSync()) {
  //         classDir.createSync();
  //       }else{
  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("A class with this name already exists")));
  //       }
  //     }
  //
  //     // Update the dataset.json files
  //     final jsonFile = File("${datasetDir.path}/dataset.json");
  //
  //     if (jsonFile.existsSync()) {
  //       final data = jsonDecode(jsonFile.readAsStringSync());
  //       print("Present Classes data ${data['classes']}");
  //       List classes = data['classes'] ?? [];
  //
  //       if (!classes.contains(className)) {
  //         classes.add(className);
  //         data['classes'] = classes;
  //         jsonFile.writeAsStringSync(jsonEncode(data));
  //       }
  //
  //       print("Present Classes data ${data['classes']}");
  //     }
  //
  //
  //     setState(() {
  //       classes.add(className);
  //     });
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Class '$className' added successfully")));
  //   }catch (e){
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add class : $e")));
  //   }
  // }

  // Future<void> addClass(String datasetName, String className, BuildContext context) async{
  //   final dir = await getApplicationDocumentsDirectory();
  //
  //   final dataset_path = "${dir.path}/datasets/${datasetName}";
  //
  //   final subsets = ['training', 'validation', 'testing'];
  //
  //   for (var subset in subsets){
  //     final subset_path = Directory("$dataset_path/$subset/$className");
  //     if (!subset_path.existsSync()){
  //       subset_path.createSync();
  //     }
  //   }
  //
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Class $className created")));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dataset Classes"),
      actions: [
        IconButton(onPressed: (){


        }, icon: Icon(Icons.add)),

      ],
      ),

      body : loading? Center(child : CircularProgressIndicator()) :
          classNames.isEmpty ? Center(child : Text("No classes found")) :
              ListView.builder(
                  itemCount: classNames.length,
                  itemBuilder: (context, index){
                    final className = classNames[index];
                    final count = cachedImageCounts[className] ?? 0;


                    return Card(

                      child : ListTile(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ClassDetails(className: className)));
                        }
                        ,
                        title : Text(className),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("200 Images"),
                            const SizedBox(width: 10,),
                            IconButton(onPressed: (){
                              deleteClass(widget.dataset, className, context);

                            }, icon: Icon(Icons.delete_outline, color : Colors.red))
                          ],
                        ),
                      )
                    );
                  })
    );
  }
}


