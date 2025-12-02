import 'dart:convert';
import 'dart:io';

import 'package:dataset_builder/screens/datasets/class/class_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../widgets/expandable_fab.dart';
import 'class/class_folder_page.dart';
import 'dataset_subset_overview.dart';

class DatasetPage extends StatefulWidget {
  final String datasetName;
  final String description;

  DatasetPage({required this.datasetName, required this.description});

  @override
  State<DatasetPage> createState() => _DatasetPageState();
}

class _DatasetPageState extends State<DatasetPage> {
  List<String> classes = []; // Stores new class names temporarily

  // Subsets (Training always exists, others optional)
  bool hasValidation = false;
  bool hasTesting = false;

  // Search field
  String searchQuery = "";

  // --------------
  // ADD Class dialog
  // --------------

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadClasses();
  }


  Future<void> _loadClasses() async{
      try{
        final dir = await getApplicationDocumentsDirectory();
        final datasetDir = Directory("${dir.path}/datasets/${widget.datasetName}");
        print("Folders ${datasetDir.listSync()}");
        final jsonFile = File("${datasetDir.path}/dataset.json");

        if(jsonFile.existsSync()){
          // print("JSON FILE FOUND");
          final data = jsonDecode(jsonFile.readAsStringSync());
          // print("JSON FILE DATA $data");

          setState(() {
            classes = List<String>.from(data['classes'] ?? []);
          });
        }
      }catch (e){
          print("Failed to load classes : $e");
      }
}


Widget buildSubsetOverviewCard(){

    return Card(
      elevation: 4,
      shape : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // color: Colors.grey[50],
      child: Padding(padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text("Data Subsets Overview",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          SizedBox(height : 12),

          // Top Stats Rows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              subsetItem("Train", "150"),
              subsetItem("Validation", "50"),
              subsetItem("Test", "45")
            ],
          ),

          SizedBox(height: 16,),

          // Actual tiles

          // subsetTile("Training"),
          // subsetTile("Validation"),
          // subsetTile("Testing")
        ],
      ),
      ),

    );
}

  Future<String?> selectSubset() async{
    List<String> subsets = ["training", "validation", "testing"];
    String selected = "training";

    return showDialog(context: context, builder: (context){
      return AlertDialog(
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(onPressed: (){
            Navigator.pop(context, selected);
          }, child: Text("Continue"))
        ],
        title : Text("Select subset"),
        content : DropdownButtonFormField<String>(
            value : selected, //.toLowerCase(),
            items: subsets.map((e) => DropdownMenuItem(value: e, child: Text(e),),).toList(),
            onChanged: (String? value){
              selected = value!;
        },)
      );
    });
  }

  Future<String?> selectClassDialog() async{
        String selected = classes.first;

        return showDialog(context: context, builder: (context){
          return AlertDialog(
            actions: [
              TextButton(onPressed: ()=> Navigator.pop(context), child: Text("Cancel")),
              ElevatedButton(onPressed: (){Navigator.pop(context, selected);}, child: Text("Continue"))
            ],
            title : Text("Select Class"),
            content : DropdownButtonFormField<String>(

              value : selected,
              items : classes.map((c) => DropdownMenuItem(
                value : c,
                child : Text(c)
              )).toList(), onChanged: (String? value) { selected = value!; },
            )
          );
        });
  }

  Future<void> saveCapturedImage(XFile image, String subset, String className) async{
    final dir = await getApplicationDocumentsDirectory();
    final saveDir = Directory("${dir.path}/datasets/${widget.datasetName}/${subset}/$className");
    print("saved to $saveDir");

    // if (!saveDir.existsSync()) saveDir.createSync()
    final fileCount = saveDir.listSync().length;
    final fileName = "img_${fileCount + 1}.jpg";

    await File(image.path).copy("${saveDir.path}/${fileName}");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Saved to $className")));
}

  Future<void> takePhoto() async {

    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please create a class first")));
      return;
    }

    String? activeClass = await selectClassDialog();
    if (activeClass == null) return;

    String? activeSubset = await selectSubset();
    if (activeSubset == null) return;

    while (true){
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image == null){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Closed Camera")));
        break;
      }

      await saveCapturedImage(image, activeSubset, activeClass);


    }

    // final picker = ImagePicker();
    //
    // final XFile? image = await picker.pickImage(source: ImageSource.camera);
    //
    // if (image == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("No image captured")));
    //   return;
    // }


    // Ask user which class to save into
    // String? selectedClass = await showDialog<String>(
    //     context: context, builder: (context) {
    //   String tempSelection = classes.isNotEmpty ? classes.first : "";
    //
    //   return AlertDialog(
    //       title: Text("Selected Class"),
    //       content: DropdownButtonFormField<String>(
    //           items: items, onChanged: onChanged)
    //   );
    // });
  }
  void addClassDialog() {
    TextEditingController classController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Class"),
        content: TextField(
          controller: classController,
          decoration: InputDecoration(hintText: "Class Name (folder)"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // classes.add(classController.text.trim());
                addClass(classController.text.trim());
              });
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  void addClass(String className) async{

    if (className.trim().isEmpty) return;


    final dir = await getApplicationDocumentsDirectory();
    final datasetDir = Directory("${dir.path}/datasets/${widget.datasetName}");

    // Subsets
    final subsets = ["training", "validation", "testing"];

    try{
      for (var subset in subsets) {
        print("Creating subset $subset");
        final subsetDir = Directory("${datasetDir.path}/$subset");

        // Make sure subset folder exists
        if (!subsetDir.existsSync()) {
          subsetDir.createSync(recursive: true);
        }

        // Create the class folder inside the subset
        final classDir = Directory("${subsetDir.path}/$className");

        if (!classDir.existsSync()) {
          classDir.createSync();
        }else{
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("A class with this name already exists")));
        }
      }

      // Update the dataset.json files
      final jsonFile = File("${datasetDir.path}/dataset.json");

      if (jsonFile.existsSync()) {
        final data = jsonDecode(jsonFile.readAsStringSync());
        print("Present Classes data ${data['classes']}");
        List classes = data['classes'] ?? [];

        if (!classes.contains(className)) {
          classes.add(className);
          data['classes'] = classes;
          jsonFile.writeAsStringSync(jsonEncode(data));
        }

        print("Present Classes data ${data['classes']}");
      }


      setState(() {
        classes.add(className);
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Class '$className' added successfully")));
    }catch (e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add class : $e")));
    }
  }

  void deleteDataset() async{
    final confirm = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title : Text("Delete Dataset"),
      content : Text("Are you sure you want to delete '${widget.datasetName}'? This action cannot be undone."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text("Cancel"),
        ),

        ElevatedButton(onPressed: () async{

          final dir = await getApplicationDocumentsDirectory();
          final datasetDir = Directory("${dir.path}/datasets/${widget.datasetName}");

          if (datasetDir.existsSync()){
            try{

              datasetDir.deleteSync(recursive: true); // Deletes all folders and all files included

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dataset '${widget.datasetName}' deleted")));


            }catch (e){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete dataset : $e")));
            }


          }
          Navigator.pop(context, true);
        }, child: Text("Delete"),
          style : ElevatedButton.styleFrom(backgroundColor: Colors.red),
        )
      ],
    ));
  }


  void openAddImageSheet(){

  }



  Widget subsetTile(String datasetName, String subsetName){

    // Assign color and icon based on subset type
    IconData iconData;
    Color iconColor;

    switch(subsetName.toLowerCase()){
      case "training":
        iconData = Icons.school;
        iconColor = Colors.blue;
        break;

      case "validation":
        iconData = Icons.check_circle_outline;
        iconColor = Colors.orange;
        break;
      case "testing":
        iconData = Icons.assignment_turned_in;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.folder;
        iconColor = Colors.grey;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: iconColor.withOpacity(0.2), child: Icon(iconData, color : iconColor),),
        title : Text(subsetName),
        subtitle: Text("${classes.length} classes • ? images"),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: (){
          // Open subset Screen
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tapped on $subsetName subset")));

          Navigator.push(context, MaterialPageRoute(builder: (context) => DataSubsetOverviewPage(datasetName: datasetName, subsetName: subsetName,) ));
        },
      ),
    );
  }


  // -----------------
  // START BUILD UI
  // -----------------
  @override
  Widget build(BuildContext context) {

    List<String> filteredClasses = classes.where((c) => c.toLowerCase().contains(searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.datasetName),
      actions: [
        IconButton(onPressed: (){
          deleteDataset();

        }, icon: Icon(Icons.delete_outline, color : Colors.red))
      ],
      ),
      floatingActionButton: SpeedDial(
        icon : Icons.add,
        activeIcon : Icons.close,
        children : [
          SpeedDialChild(
            child: Icon(Icons.camera_alt),
            label : "Take a photo",
            onTap: (){
              takePhoto();
            }
          ),
          SpeedDialChild(
            child: Icon(Icons.cloud_download),
            label : "Import from web",
            onTap: (){

            }
          ),
          SpeedDialChild(
            child: Icon(Icons.photo_library),
            label: "Upload from Gallery",
            onTap : (){

            }
          )
        ]
      ),

     // TODO : add an expandable FAB

      body:
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //-------------
              //DATA SUBSETS SECTION
              // -------------
              Text("Data Subsets", style : TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height : 8),
              subsetTile(widget.datasetName, "Training"),
              subsetTile(widget.datasetName, "Validation"),
              subsetTile(widget.datasetName, "Testing"),

              SizedBox(height : 24),


              // ---------------
              // Dataset Subsets Overview
              // ---------------------
              // _subsetCard(),
              // buildSubsetOverviewCard(),

              // --------
              // CLASSES SECTION
              // --------

              ClassCard(filteredClasses: filteredClasses, datasetName: widget.datasetName, addClassDialog: addClassDialog,)
              // Card (
              //
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              //     elevation: 2,
              //     child: Column(
              //         children: [
              //           ListTile(
              //             onTap : (){
              //               Navigator.push(context, MaterialPageRoute(builder: (context) => ClassOverview(dataset: widget.datasetName))); //, subset: subset)));
              //             },
              //             title: Text("Classes", style : TextStyle(fontSize : 20, fontWeight: FontWeight.bold)),
              //             trailing: ElevatedButton.icon(onPressed: addClassDialog, label: Text("Add Class"), icon : Icon(Icons.create_new_folder)                          ),
              //           ),
              //
              //           // Display top few classes
              //           Padding(
              //             padding: const EdgeInsets.all(16.0),
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               mainAxisAlignment: MainAxisAlignment.start,
              //               children: filteredClasses.take(3).map((className) => Text(className, style: TextStyle(fontSize : 16),)).toList(),
              //             ),
              //           ),
              //
              //
              //         ]
              //     )
              //
              // ),


            ],
          )
        )

    );
  }
}

class ClassCard extends StatelessWidget {
  final List<String> filteredClasses;
  final String datasetName;
  final VoidCallback addClassDialog;

  const ClassCard({super.key,
  required this.filteredClasses,
    required this.datasetName,
    required this.addClassDialog
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        // Navigate to ClassOverview screen when the card is tapped
        Navigator.push(context, MaterialPageRoute(builder: (context) => ClassOverview(dataset: datasetName)));
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),

        ),
        elevation : 5,
        shadowColor: Colors.black26,
        // color : Colors.white,
        child : Column(
          children: [
            // Title section with the "Classes" title and Add button
            Padding(padding: const EdgeInsets.all(16.0),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Classes", style: TextStyle(fontSize: 24, color : Colors.black87),),
                    SizedBox(width: 20,),
                    TextButton.icon(
                      onPressed: addClassDialog, label: Text("Add Class"), icon: Icon(Icons.add),
                      style: TextButton.styleFrom(backgroundColor: Colors.blue.shade50,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape : RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                        )
                      ),
                    )
                  ],
                ),
            ),
            // Divider for seperation
            Divider(thickness: 1, color : Colors.grey.shade300,),


            // Display top few classes
            Padding(padding : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: filteredClasses.take(3).map((className) => Padding(padding: const EdgeInsets.symmetric(vertical : 1),
              child : Text(
                className,
                style: TextStyle(fontSize: 18, color : Colors.black87),
              )
              )).toList(),
            ),
            ),

            // // If there are classes more than 3, then show View All
            //
            // if (filteredClasses.length > 3)
              Padding(padding: const EdgeInsets.all(4),
              child: TextButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => ClassOverview(dataset: datasetName)));
              }, child: Text("Tap to View Details", style : TextStyle(color : Colors.blue, fontSize: 16))),
              )
          ],
        )
      ),
    );
  }
}



Widget subsetItem(String name, String count) {
  return Column(
    children: [
      Text(
        count,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        name,
        style: const TextStyle(color: Colors.grey),
      ),
    ],
  );
}


