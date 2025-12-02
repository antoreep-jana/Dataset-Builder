import 'package:flutter/material.dart';

class ClassFolderPage extends StatefulWidget {
  final String className;

  ClassFolderPage({required this.className});

  @override
  State<ClassFolderPage> createState() => _ClassFolderPageState();
}

class _ClassFolderPageState extends State<ClassFolderPage> {
  List<String> images = []; // For now dummy image refs

  void addImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        height: 160,
        child: Column(
          children: [
            Text("Add Image", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("Take Photo"),
              onTap: () {
                // TODO: Implement camera picker
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text("Upload From Gallery"),
              onTap: () {
                // TODO: Implement gallery picker
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.className)),
      floatingActionButton: FloatingActionButton(
        onPressed: addImageSourcePicker,
        child: Icon(Icons.add_a_photo),
      ),
      body: images.isEmpty
          ? Center(child: Text("No images yet. Add one!"))
          : GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.grey[300],
            child: Center(child: Text("IMG")),
          );
        },
      ),
    );
  }
}
