import 'package:flutter/material.dart';
// Did some updates
void main() {
  runApp(const DatasetBuilderApp());
}

class DatasetBuilderApp extends StatelessWidget {
  const DatasetBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //List<String> datasets = []; //['Dataset1', "Dataset2", "Dataset3"];
   List<Map<String, String>> datasets = [
     {"name" : "Dataset1", "description" : "Description of dataset 1"},
     {"name" : "Dataset2", "description" : "Description of dataset 2"},
     {"name" : "Dataset3", "description" : "Description of dataset 3"}
  ];

  @override
  Widget build(BuildContext context) {
    //return const Placeholder();
    return Scaffold(
      appBar: AppBar(title: const Text("Dataset Builder")),
      body:
          datasets.isEmpty
              ? const Center(
                child: Text("No datasets yet. Tap '+' to add one!"),
              )
              : ListView.builder(
                itemCount: datasets.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(datasets[index]['name']!),
                    onTap: () {
                      // Navigate to Dataset Details Page
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${datasets[index]['name']!} tapped"),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController nameController = TextEditingController();
          TextEditingController descriptionController = TextEditingController();

          // TO DO
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Create new Dataset"),
                // content: TextField(
                //   decoration: const InputDecoration(hintText: "Enter Dataset Name: "),
                // ),
                content: Column(
                  mainAxisSize: MainAxisSize.min, // Ensures wraps neatly
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: "Enter Dataset Name: ",
                      ),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        hintText: "Enter dataset description (optional)",
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // todo : Cancel creating a dataset
                      Navigator.of(context).pop(); // Close dialog
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO : Save Dataset (next step)
                      String datasetName = nameController.text.trim();
                      String datasetDescription =
                          descriptionController.text.trim();

                      if (datasetName.isEmpty) {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Dataset name cannot be empty!"),
                            duration: Duration(seconds: 1),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Create'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
