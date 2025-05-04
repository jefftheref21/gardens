import 'dart:convert';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'models/plant.dart';
import 'models/garden.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

String url = "http://10.0.2.2:5000";

Future<List<Plant>> fetchPlants(String gardenID) async {
  // Fetch plants from the server for a specific garden
  final response = await http.get(Uri.parse("$url/garden/$gardenID"), headers: {
    'Content-Type': 'application/json',
  });
  
  if (response.statusCode == 200) {
    final List<dynamic> jsonResponse = json.decode(response.body)['plants'];
    print(jsonResponse);
    print(jsonResponse[0]['_id']);
    List<Plant> plants = [];
    for (var plant in jsonResponse) {
      if (plant['gardenID'] == gardenID) {
        plants.add(Plant.fromJson(plant));
      }
    }
    return plants;
  } else {
    throw Exception('Failed to load data');
  }
}

Future<List<Garden>> fetchGardens() async {
  final response = await http.get(Uri.parse("$url/home"), headers: {
    'Content-Type': 'application/json',
  });
  if (response.statusCode == 200) {
    final List<dynamic> jsonResponse = json.decode(response.body)['gardens'];
    print(jsonResponse);
    print(jsonResponse[0]['_id']);
    List<Garden> gardens = [];
    for (var garden in jsonResponse) {
      gardens.add(Garden.fromJson(garden));
    }
    return gardens;
  } else {
    throw Exception('Failed to load data');
  }
}

Future<String> addPlant(String gardenID, String name, String imageUrl, String description) async {
  final response = await http.post(
    Uri.parse("$url/garden/$gardenID"),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
    }),

  );
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    print(jsonResponse['message']);
    return jsonResponse['plantID'];
  } else {
    throw Exception('Failed to add plant');
  }
}

Future<void> updatePlant(String plantID, String name, String imageUrl, String description) async {
  final response = await http.put(
    Uri.parse("$url/garden"),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'plantID': plantID,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
    }),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to update plant');
  }
}

Future<void> deletePlant(String plantID) async {
  final response = await http.delete(
    Uri.parse("$url/garden"),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'plantID': plantID,
    }),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to delete plant');
  }
}

Future<String> uploadImage(XFile imageFile, String _id, String type) async {
  final storageRef = FirebaseStorage.instance.ref();
  final imagesRef = storageRef.child("{$type}_uploads/$_id/${DateTime.now().millisecondsSinceEpoch}.jpg");

  await imagesRef.putFile(File(imageFile.path));
  String downloadURL = await imagesRef.getDownloadURL();
  return downloadURL;
}

Future<String> getImageUrl(String type, String imagePath) async {
  final storageRef = FirebaseStorage.instance.ref().child('{$type}_uploads/$imagePath');
  return await storageRef.getDownloadURL();
}