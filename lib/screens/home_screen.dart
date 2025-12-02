import 'package:dataset_builder/screens/datasets/create.dart';
import 'package:dataset_builder/screens/datasets/datasets_homescreen.dart';
import 'package:dataset_builder/screens/login_screen.dart';
import 'package:dataset_builder/screens/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _selectedIndex = 0;


  String username = "Loading...";
  String kaggleName = "Loading...";

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Navigator.pushReplacementNamed(context, '/login');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }


  final List<Widget> _pages = [
    HomeContent(),
    MyDatasetsScreen(),
    ProfilePage()
  ];


  // Load user details on init
  void loadUserDetails() async{

    await FirebaseAuth.instance.currentUser?.reload();

    final User? user = FirebaseAuth.instance.currentUser;
    print("User details $user");

    final String fetchedUsername = user?.displayName ?? "User";

    final String fetchedKaggleName = "dummy_kaggle_user"; // TODO: fetch from Firestore

    setState(() {
      username = fetchedUsername;
      kaggleName = fetchedKaggleName;
    });
  }

  @override
  void initState(){
    super.initState();
    loadUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    // Get logged-in user

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Annotater', style: TextStyle(color : Colors.blue, fontSize: 35),),
        actions: [

          IconButton(onPressed: (){

            _logout(context);
          }, icon: Icon(Icons.logout, color: Colors.red, size: 25,))

        ],
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() {
            _selectedIndex = index;
          }),

          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label : "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.folder), label : "My Datasets"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label : "Profile")
          ]),

    );
  }



  /// Dummy dataset tile/card
  Widget datasetCard(String title) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.folder, size: 40, color: Colors.blueAccent),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Text(
            "10 files",
            style: TextStyle(fontSize: 12, color: Colors.black),
          )
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {

  // Access parent State for username and kaggleName
  // final String username;
  // final String kaggleName;

  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {

    final parentState = context.findAncestorStateOfType<_HomeScreenState>();
    final username = parentState?.username ?? "...";
    final kaggleName = parentState?.kaggleName ?? "...";


    return Scaffold(//appBar: AppBar(title: Text("Home"),),
    body : Padding(
    padding : const EdgeInsets.all(16.0),
    child : SingleChildScrollView(
      child : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // GREETING

          Text("Hello, $username 👋",
          style : TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
          ),

          SizedBox(height: 8,),

          // Kaggle Account
          Text("Your Kaggle Account : $kaggleName",
          style : TextStyle(fontSize : 16, color : Colors.grey[700])
          ),

          SizedBox(height : 24),

          Text("Quick Access", style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold
          ),),

          // Dummy horizontal cards
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [

                // fetch the list of datasets locally
                homeCard("Dataset A"),
                homeCard("Dataset B"),
                homeCard("Dataset C")
              ],
            ),
          )
        ],
      )
    )
    )

    );
  }
}

Widget homeCard(String title){
  return Container(
    width: 150,
      margin: EdgeInsets.only(right : 12),
    padding : EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white,
    borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color : Colors.black12, blurRadius: 4
        )
      ]
    ),
    child : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.folder, color : Colors.blueAccent, size : 40),
        SizedBox(height : 12),
        Text(title, style : TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
      ],
    )
  );
}
