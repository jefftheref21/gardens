import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../network.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

class GardenPage extends StatefulWidget {
  final String gardenID;
  final String name;

  const GardenPage({super.key, required this.gardenID, required this.name});

  @override
  State<GardenPage> createState() => _GardenPageState();
}
class _GardenPageState extends State<GardenPage> {
  late Future<void> _initFuture;
  List<Plant> plants = [];
  int plantCount = 0;

  TextEditingController plantNameController = TextEditingController();
  TextEditingController plantDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initFuture = init();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final args = ModalRoute.of(context)!.settings.arguments as Map;
  //   widget.gardenID = args['gardenID'];
  //   widget.name = args['name'];
  //   _initFuture = init();
  // }

  Future<void> init() async {
    final fetchedPlants = await fetchPlants(widget.gardenID);
    setState(() {
      plants = fetchedPlants;
      plantCount = plants.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700, fontFamily: 'Palantino')),
      ),
      backgroundColor: Colors.lightGreen,
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while waiting
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle errors
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Render the list of plants once data is loaded
            return SafeArea(
              child: ListView.builder(
                itemCount: plantCount,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      plantNameController.text = plants[index].name;
                      plantDescriptionController.text = plants[index].description ?? '';

                      showPlantDialog(context, index);
                    },
                    child: buildPlantCard(plants[index]),
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          plantNameController.clear();
          plantDescriptionController.clear();

          showAddPlantDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void showPlantDialog(BuildContext context, int index) {
    File? _imageFile;
    final ImagePicker _picker = ImagePicker();
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
              // Image File Picker
              _imageFile == null
                  ? const Text('No image selected.')
                  : Image.file(
                      _imageFile!,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () async {
                  final XFile? pickedFile =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
                child: const Text('Pick Image'),
              ),
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
                  // Upload the image to Firebase Storage and get the URL
                  String? imageUrl;
                  if (_imageFile != null) {
                    imageUrl = await uploadImage(
                      XFile(_imageFile!.path),
                      plants[index].plantID,
                      "plant",
                    );
                  }

                  final response = await updatePlant(
                    plants[index].plantID,
                    plantNameController.text,
                    imageUrl ?? plants[index].imageUrl,
                    plantDescriptionController.text,
                  );
                  setState(() {
                    plants[index].name = plantNameController.text;
                    plants[index].imageUrl = imageUrl ?? plants[index].imageUrl;
                    plants[index].description = plantDescriptionController.text;
                  });
                  context.pop();
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
                  context.pop();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAddPlantDialog(BuildContext context) {
    File? _imageFile;
    final ImagePicker _picker = ImagePicker();

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
              // Image File Picker
              _imageFile == null
                  ? const Text('No image selected.')
                  : Image.file(
                      _imageFile!,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () async {
                  final XFile? pickedFile =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
                child: const Text('Pick Image'),
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
                  // Check if the image file is null before proceeding
                  if (_imageFile == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select an image')),
                    );
                    return;
                  }
                  // Upload the image to Firebase Storage and get the URL
                  String? imageUrl;
                  imageUrl = await uploadImage(
                    XFile(_imageFile!.path),
                    widget.gardenID,
                    "plant",
                  );

                  final response = await addPlant(
                    widget.gardenID,
                    plantNameController.text,
                    imageUrl,
                    plantDescriptionController.text,
                  );
                  setState(() {
                    plants.add(Plant(
                      gardenID: widget.gardenID,
                      plantID: response,
                      name: plantNameController.text,
                      imageUrl: imageUrl!,
                      description: plantDescriptionController.text,
                    ));
                    plantCount = plants.length;
                  });
                  context.pop();
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ),
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
            FutureBuilder<String>(
              future: getImageUrl("plant", plant.imageUrl), // Fetch the image URL
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 150.0,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return const SizedBox(
                    height: 150.0,
                    child: Center(child: Text('Error loading image')),
                  );
                } else {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      snapshot.data!,
                      height: 150.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 14.0),
            Text(
              plant.name,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                fontFamily: 'Palantino',
              ),
            ),
            const SizedBox(height: 14.0),
            Text(
              plant.description ?? 'No description available',
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                fontFamily: 'Palantino',
              ),
            ),
          ],
        ),
      ),
    );
  }
}