import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../network.dart';

class GardenPage extends StatefulWidget {
  const GardenPage({super.key});
  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  List<Plant> plants = [];
  int plantCount = 0;
  bool isLoading = true;
  late String gardenID;
  late String gardenName;

  TextEditingController plantNameController = TextEditingController();
  TextEditingController plantImageUrlController = TextEditingController();
  TextEditingController plantDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final fetchedPlants = await fetchPlants(gardenID);
    setState(() {
      plants = fetchedPlants;
      plantCount = plants.length;
      isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    gardenID = args['gardenId'];
    gardenName = args['name'];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gardenName),
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
                          TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Plant Description',
                            ),
                            controller: plantDescriptionController,
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
                                plantDescriptionController.text,
                              );
                              setState(() {
                                plants[index].name = plantNameController.text;
                                plants[index].imageUrl = plantImageUrlController.text;
                                plants[index].description = plantDescriptionController.text;
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
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Plant Description',
                      ),
                      controller: plantDescriptionController,
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () async {
                        final response = await addPlant(

                          gardenID,
                          plantNameController.text,
                          plantImageUrlController.text,
                          plantDescriptionController.text,
                        );
                        setState(() {
                          plants.add(Plant(
                            gardenID: gardenID,
                            plantID: response,
                            name: plantNameController.text,
                            imageUrl: plantImageUrlController.text,
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