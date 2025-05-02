import 'dart:convert';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'plant.dart';

String url = "http://10.0.2.2:5000";

Future<List<Plant>> fetchPlants() async {
    final response = await http.get(Uri.parse("$url/home"), headers: {
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body)['plants'];
      print(jsonResponse);
      print(jsonResponse[0]['_id']);
      List<Plant> plants = [];
      for (var plant in jsonResponse) {
        plants.add(Plant.fromJson(plant));
      }
      return plants;
    } else {
      throw Exception('Failed to load data');
    }
}

Future<String> addPlant(String name, String imageUrl) async {
  final response = await http.post(
    Uri.parse("$url/home"),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'name': name,
      'imageUrl': imageUrl,
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

Future<void> updatePlant(String id, String name, String imageUrl) async {
  final response = await http.put(
    Uri.parse("$url/home"),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'plantID': id,
      'name': name,
      'imageUrl': imageUrl,
    }),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to update plant');
  }
}

Future<void> deletePlant(String id) async {
  final response = await http.delete(
    Uri.parse("$url/home"),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'plantID': id,
    }),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to delete plant');
  }
}