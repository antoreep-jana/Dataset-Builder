import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DatasetFilesPage extends StatefulWidget {
  final String datasetName;
  final String subsetName;
  const DatasetFilesPage({super.key, required this.datasetName, required this.subsetName});

  @override
  State<DatasetFilesPage> createState() => _DatasetFilesPageState();
}

class _DatasetFilesPageState extends State<DatasetFilesPage> {

  List<String> classNames = [];
  int selectedIndex = 0;
  List<File> images = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadClasses();
    // _loadImagesForClass(classNames[0]);
  }


  Future<void> _loadClasses() async{
    final dir = await getApplicationDocumentsDirectory();
    final subsetPath = "${dir.path}/datasets/${widget.datasetName}/${widget.subsetName.toLowerCase()}";

    final subsetDir = Directory(subsetPath);
    print("Folders present ${subsetDir.listSync()}");
    if(!subsetDir.existsSync()) return;

    final folders = subsetDir.listSync()
                    .where((e) => e is Directory)
                    .map((e) => e.path.split("/").last) //[0].toUpperCase() + e.path.split("/").last.substring(1))
                    .toList();

    setState(() {
      classNames = folders;
    });

    final classDir = Directory("${dir.path}/datasets/${widget.datasetName}/${widget.subsetName.toLowerCase()}/a");
    print("Class path ${classDir.listSync()}");

    if (classNames.isNotEmpty){
    // Load images for the 1st class
      _loadImagesForClass(classNames[0]);
    }

  }


  void _loadImagesForClass(String className) async{
    final dir = await getApplicationDocumentsDirectory();
    final classDir = Directory("${dir.path}/datasets/${widget.datasetName}/${widget.subsetName.toLowerCase()}/$className");
    print("Class path ${classDir.listSync()}");

    // if (!classDir.existsSync()) return;

    // final imgs = classDir.listSync().where((f) => f is File && )
    // Allowed image extensions
    final imgExtensions = [".jpg", ".jpeg", ".png"];

    final imgs = classDir.listSync().where((f) => f is File && imgExtensions.any((ext) => f.path.toLowerCase().endsWith(ext))).map((f) => File(f.path)).toList();
    setState(() {
      images = imgs;
    });
  }


  @override
  Widget build(BuildContext context) {

    if (classNames.isEmpty) {
      // Show a loading indicator until classes are loaded
      return Scaffold(
        appBar: AppBar(title: Text("${widget.subsetName} Files")),
        body: Center(child: CircularProgressIndicator()),
      );
    }


    return Scaffold(appBar: AppBar(title: Text("${widget.subsetName} Files"),),
    body: Row(
      children: [
        // Left sidebar with the classes

        Container(
            width: 100,
            child: NavigationRail(
              selectedIndex: selectedIndex < classNames.length ? selectedIndex : 0,
              labelType: NavigationRailLabelType.all,
              // destinations: dataset.keys.map((className) => NavigationRailDestination(
              onDestinationSelected: (index){
                setState(() {
                  selectedIndex = index;
                });
                _loadImagesForClass(classNames[index]);
              },
             destinations: classNames.map((className) => NavigationRailDestination(

                  // icon: Icon(Icons.folder, size: 50,),
                icon : CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(className[0].toUpperCase(),
                     style: TextStyle(color : Colors.white),
                              ),
                  // child: Image.network("https://marketplace.canva.com/8-1Kc/MAGoQJ8-1Kc/1/tl/canva-ginger-cat-with-paws-raised-in-air-MAGoQJ8-1Kc.jpg"),
                ),
                label: Text(className, style: TextStyle(fontSize: 13),))).toList(),

             )
        ),

        Expanded(child: GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemCount: images.length,
            itemBuilder: (context, index){
          return Padding(padding : const EdgeInsets.all(8.0),
              child : Image.file(images[index], fit : BoxFit.cover));
        }))
      ],
    ),
    );
  }
}
