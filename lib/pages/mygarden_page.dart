import 'package:flutter/material.dart';
import '../plant.dart';
import '../network.dart';

class MyGardenPage extends StatefulWidget {
  const MyGardenPage({super.key, required this.title});

  final String title;

  @override
  State<MyGardenPage> createState() => _MyGardenPageState();
}

class _MyGardenPageState extends State<MyGardenPage> {
  List<Plant> plants = [];
  int plantCount = 0;
  bool isLoading = true;

  TextEditingController plantNameController = TextEditingController();
  TextEditingController plantImageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final fetchedPlants = await fetchPlants();
    setState(() {
      plants = fetchedPlants;
      plantCount = plants.length;
      isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.lightGreen,
      body: SafeArea(
        child: ListView.builder(
          itemCount: plantCount,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                plantNameController.text = plants[index].name;
                plantImageUrlController.text = plants[index].imageUrl;
                
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text('Update plant'),
                          const SizedBox(height: 15),
                          TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Plant Name',
                            ),
                            controller: plantNameController,
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Plant Image URL',
                            ),
                            controller: plantImageUrlController,
                          ),
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: () async {
                              print(plantNameController.text);
                              print(plantImageUrlController.text);
                              final response = await updatePlant(
                                plants[index].plantID,
                                plantNameController.text,
                                plantImageUrlController.text,
                              );
                              setState(() {
                                plants[index].name = plantNameController.text;
                                plants[index].imageUrl = plantImageUrlController.text;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Update'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await deletePlant(plants[index].plantID);
                              setState(() {
                                plants.removeAt(index);
                                plantCount = plants.length;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ),
                  ),  
                );
              },
              child: buildPlantCard(plants[index]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          plantNameController.clear();
          plantImageUrlController.clear();

          showDialog<String>(
            context: context,
            builder: (BuildContext context) => Dialog(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Add new plant'),
                    const SizedBox(height: 15),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Plant Name',
                      ),
                      controller: plantNameController,
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Plant Image URL',
                      ),
                      controller: plantImageUrlController,
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () async {
                        final response = await addPlant(
                          plantNameController.text,
                          plantImageUrlController.text,
                        );
                        setState(() {
                          plants.add(Plant(
                            response,
                            plantNameController.text,
                            plantImageUrlController.text,
                          ));
                          plantCount = plants.length;
                        });
                        print(plants);
                        Navigator.pop(context);
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildPlantCard(Plant plant) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Image(image: AssetImage(plant.imageUrl)),
            Text(
              plant.imageUrl + "_placeholder",
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                fontFamily: 'Palantino',
              )
            ),
            const SizedBox(
              height: 14.0
            ),
            Text(
              plant.name,
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