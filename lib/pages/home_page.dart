import 'package:flutter/material.dart';
import 'package:garden/models/garden.dart';
import 'package:garden/utils/network.dart';
import 'package:garden/utils/image_network.dart';
import 'package:garden/widgets/garden_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  // Later we will use this to pass the user data from the login page

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Garden> gardens = [];
  int gardenCount = 0;

  TextEditingController gardenNameController = TextEditingController();
  TextEditingController gardenDescriptionController = TextEditingController();
  TextEditingController gardenCityController = TextEditingController();
  TextEditingController gardenStateController = TextEditingController();
  TextEditingController gardenZipCodeController = TextEditingController();
  TextEditingController gardenRatingController = TextEditingController();

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
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Explore',
            onPressed: () {
              // Go to explore page
              context.go('/explore');
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
                context.push('/garden',
                  extra: {'gardenID': gardens[index].gardenID,
                          'name' : gardens[index].name, });
              },
              child: buildGardenCard(gardens[index]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddGardenDialog(context);
        },
        tooltip: 'Add Garden',
        child: const Icon(Icons.add),
      ),
    );
  }

  void showAddGardenDialog(BuildContext context) {
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
              const Text('Add new garden'),
              const SizedBox(height: 15),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Garden Name',
                ),
                controller: gardenNameController,
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
                controller: gardenDescriptionController,
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'City',
                ),
                controller: gardenCityController,
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'State',
                ),
                controller: gardenStateController,
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'ZIP Code',
                ),
                controller: gardenZipCodeController,
              ),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                decoration: const InputDecoration(
                  labelText: 'Enter a double value',
                  border: OutlineInputBorder(),
                ),
                controller: gardenRatingController,
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
                  print(gardenNameController.text);
                  print(gardenDescriptionController.text);
                  print(_imageFile!.path);

                  double? rating = double.tryParse(gardenRatingController.text);

                  // Upload the image to Firebase Storage and get the URL
                  // String? imageUrl;
                  // imageUrl = await uploadImage(
                  //   XFile(_imageFile!.path),

                  //   "garden",
                  // );

                  // final response = await addGarden(
                  //   widget.gardenID,
                  //   plantNameController.text,
                  //   imageUrl,
                  //   plantDescriptionController.text,
                  // );
                  // setState(() {
                  //   plants.add(Plant(
                  //     gardenID: widget.gardenID,
                  //     plantID: response,
                  //     name: plantNameController.text,
                  //     imageUrl: imageUrl!,
                  //     description: plantDescriptionController.text,
                  //   ));
                  //   plantCount = plants.length;
                    
                  // });
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
}