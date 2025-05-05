import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/plant.dart';
import '../models/garden.dart';
import '../models/stats.dart';

// String url = "http://10.0.2.2:5000";
String url = "http://localhost:5000";

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
    // print(jsonResponse);
    // print(jsonResponse[0]['_id']);
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

Future<bool> updatePlant(String plantID, String name, String imageUrl, String description) async {
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
  return response.statusCode == 200;
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

Future<String> addGarden(String userID, String name, String imageUrl, String description, String city, String state, String zipcode, double rating) async {
  final response = await http.post(
    Uri.parse("$url/garden"),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'userID': userID,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'city': city,
      'state': state,
      'zipcode': zipcode,
      'rating': rating,
    }),
  );
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    print(jsonResponse['message']);
    return jsonResponse['gardenID'];
  } else {
    throw Exception('Failed to add garden');
  }
}

Future<bool> updateGarden(String gardenID, String name, String imageUrl, String description) async {
  final response = await http.put(
    Uri.parse("$url/garden"),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'gardenID': gardenID,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
    }),
  );
  return response.statusCode == 200;
}

Future<void> deleteGarden(String gardenID) async {
  final response = await http.delete(
    Uri.parse("$url/garden/$gardenID"),
    headers: {
      'Content-Type': 'application/json',
    },
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to delete garden');
  }
}

Future<Map<String, dynamic>> filterGardens(String name, String city, String state, String zipcode) async {
  final queryParams = <String, String>{
    if (name.trim().isNotEmpty) 'name': name.trim(),
    if (city.trim().isNotEmpty) 'city': city.trim(),
    if (state.trim().isNotEmpty) 'state': state.trim(),
    if (zipcode.trim().isNotEmpty) 'zipcode': zipcode.trim(),
  };

  final uri = Uri.parse('$url/explore').replace(
    queryParameters: queryParams,
  );
  final response = await http.get(uri, headers: {
    'Content-Type': 'application/json',
  });
  if (response.statusCode == 200) {
    final List<dynamic> gardensResponse = json.decode(response.body)['gardens'];
    final dynamic statsResponse = json.decode(response.body)['stats'];
    List<Garden> gardens = [];
    for (var garden in gardensResponse) {
      gardens.add(Garden.fromJson(garden));
    }
    Stats stats = Stats.fromJson(statsResponse);

    return {
      'gardens': gardens,
      'stats': stats,
    };
  } else {
    throw Exception('Failed to load data');
  }
}