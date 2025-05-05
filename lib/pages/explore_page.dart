import 'package:flutter/material.dart';
import 'package:garden/models/garden.dart';
import 'package:garden/models/stats.dart';
import 'package:garden/utils/network.dart';
import 'package:garden/widgets/garden_widget.dart';
import 'package:go_router/go_router.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<Garden> gardens = [];
  int gardenCount = 0;
  Stats currentStats = Stats(
    averageRating: 0.0,
    averagePlantsPerGarden: 0.0,
    averagePlantAge: 0.0,
  );

  // Controllers and filters
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Explore Gardens'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'Profile',
              onPressed: () {
                // Go to profile page
                context.go('/profile',
                    extra: {
                      'userID': 'userID_placeholder',
                      'username': 'username_placeholder',
                    });
              },
            ),
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: 'Home',
              onPressed: () {
                // Go to home page
                context.go('/');
              },
            ),
          ],
        ),
        backgroundColor: Colors.lightGreen,
        body: Column(
          children: <Widget>[
            // Search Filters
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  // Name Search
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Search by Garden name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // City Search
                  TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // State Search
                  TextField(
                    controller: stateController,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // ZIP Code Search
                  TextField(
                    controller: zipCodeController,
                    decoration: const InputDecoration(
                      labelText: 'ZIP Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Search Button
                  ElevatedButton(
                    onPressed: () {
                      _filterGardens();
                    },
                    child: const Text('Search'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            // Tab Bar
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.list), text: 'Gardens'),
                Tab(icon: Icon(Icons.bar_chart), text: 'Report'),
              ],
            ),
            const SizedBox(height: 8.0),
            // Garden List
            Expanded(
              child: TabBarView(
                children: [
                  // Gardens Tab
                  ListView.builder(
                    itemCount: gardenCount,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          // Go to garden details page
                          context.go('/garden',
                              extra: {
                                'gardenID': gardens[index].gardenID,
                                'name': gardens[index].name
                              });
                        },
                        child: buildGardenCard(gardens[index]),
                      );
                    },
                  ),
                  // Report Tab
                  _buildReport(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReport() {
    if (gardens.isEmpty) {
      return const Center(
        child: Text(
          'No gardens found.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          Text(
            'Average Garden Rating: ${currentStats.averageRating.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Average Number of Plants per Garden: ${currentStats.averagePlantsPerGarden.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Average Age of Plants: ${currentStats.averagePlantAge.toStringAsFixed(2)} years',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
  // Filter Gardens Based on Search Inputs
  void _filterGardens() async {
    // Example: Fetch gardens from a database or API based on the filters
    String name = nameController.text.trim();
    String city = cityController.text.trim();
    String state = stateController.text.trim();
    String zipcode = zipCodeController.text.trim();

    print('Filtering gardens with:');
    print('Name: $name, City: $city, State: $state, ZIP: $zipcode');

    if (name.isEmpty && city.isEmpty && state.isEmpty && zipcode.isEmpty) {
      return;
    }
    Map<String, dynamic> results = await filterGardens(name, city, state, zipcode);

    List<Garden> filteredGardens = results['gardens'] as List<Garden>;
    Stats stats = results['stats'] as Stats;

    // Example: Update the gardens list and count
    setState(() {
      gardens = filteredGardens;
      gardenCount = gardens.length;
      currentStats = stats;
    });
  }
}