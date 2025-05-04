import 'package:flutter/material.dart';
import '../models/garden.dart';
import '../network.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  // Later we will use this to pass the user data from the login page

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Garden> gardens = [];
  int gardenCount = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final fetchedGardens = await fetchGardens();
    setState(() {
      gardens = fetchedGardens;
      gardenCount = gardens.length;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gardens (Placeholder)'),
        // title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              // Go to profile page
              context.go('/profile',
                extra: {'userID': 'userID_placeholder',
                        'username' : 'username_placeholder', });
            },
          ),
        ],
      ),
      backgroundColor: Colors.lightGreen,
      body: SafeArea(
        child: ListView.builder(
          itemCount: gardenCount,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                // Go to add garden page
                context.go('/garden',
                  extra: {'gardenID': gardens[index].gardenID,
                          'name' : gardens[index].name, });
              },
              child: buildGardenCard(gardens[index]),
            );
          },
        ),
      ),
    );
  }

  Widget buildGardenCard(Garden garden) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(10.0),
            //   child: Image.network(
            //     garden.imageUrl,
            //     height: 100.0,
            //     width: 100.0,
            //     fit: BoxFit.cover,
            //   ),
            // ),
            const SizedBox(
              height: 14.0
            ),
            Text(
              garden.name,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                fontFamily: 'Palantino',
              )
            )
          ]
        )
      )
    );
  }
}