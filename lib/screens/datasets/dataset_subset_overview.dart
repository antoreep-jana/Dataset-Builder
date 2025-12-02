import 'package:flutter/material.dart';
import 'dataset_files.dart';

// Page 2 : Dataset Overview
class DataSubsetOverviewPage extends StatelessWidget {
  final String subsetName;
  final String datasetName;

  const DataSubsetOverviewPage({super.key, required this.datasetName, required this.subsetName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Subset Overview",),

      ),
      body :
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------
            // HEADER ICON + TITLE
            // ---------------

            Center(
              child: Column(
                children: [
                  Icon(Icons.insert_chart, size : 80, color : Colors.blueAccent),
                  SizedBox(height : 12),
                  Text("$subsetName Set",
                  style : TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                  )
                ],
              ),
            ),

            const SizedBox(height : 24),

            // -------------------
            // DATASET STATISTICS
            // -------------------

            Text("Dataset Summary", style : TextStyle(fontSize: 20, fontWeight : FontWeight.bold)),

            const SizedBox(height : 12),

            Row(children: [
              _infoCard(Icons.folder, "Classes", "10"),
              SizedBox(width: 12,),
              _infoCard(Icons.image, "Images", "245"),
            ],),

            SizedBox(height: 16,),

            // _subsetCard(),

            const SizedBox(height : 24),
            // -----------------------
            // ACTION BUTTONS
            // -----------------------

            ElevatedButton.icon(
              style : ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              icon : Icon(Icons.photo_library),
              label : Text("View All Files"),
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DatasetFilesPage(datasetName : datasetName, subsetName: subsetName))
                );
              },
            ),

            SizedBox(height : 12),

            TextButton.icon(
              icon: Icon(Icons.arrow_back),
              label : Text("Back to dataset"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        )
      )
    );
  }
}


Widget _infoCard(IconData icon, String title, String value){
  return Expanded(
    child: Card(
        elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
      child: Padding(padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, size : 40, color : Colors.blueAccent),
          const SizedBox(height : 8),
          Text(value, style : const TextStyle(fontSize: 20,)),
          const SizedBox(height : 4),
          Text(title, style: const TextStyle(color : Colors.grey),)
        ],
      ),
      ),
    ),
  );
}