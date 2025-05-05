import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/garden.dart';
import '../utils/network.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({super.key, required this.user});
  // Later we will use this to pass the user data from the login page

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
        title: Text('Profile'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Garden',
            onPressed: () {
              // Go to add garden page
              context.push('/add_garden',
                extra: {'userID': widget.user.userID,
                        'username' : widget.user.username, });
            },
          ),
        ],
      ),
      backgroundColor: Colors.lightGreen,
      body: Column(
        children: <Widget>[
          
          ListView.builder(
            itemCount: gardenCount,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  // Go to garden page
                  context.push('/garden',
                    extra: {'gardenID': gardens[index].gardenID,
                            'name' : gardens[index].name, });
                },
                child: buildGardenCard(gardens[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildGardenCard(Garden garden) {
    return Card(
      child: ListTile(
        title: Text(garden.name),
        subtitle: Text('Garden ID: ${garden.gardenID}'),
      ),
    );
  }
}