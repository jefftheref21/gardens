import 'location.dart';

class Garden {
  String gardenID;
  String name;
  String description;
  String imageUrl;
  // Location location;
  String address;
  String city;
  String state;
  String zipcode;
  List<String> userIDs;

  Garden({
    required this.gardenID,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.address,
    required this.city,
    required this.state,
    required this.zipcode,
    // required this.location,
    this.userIDs = const [],
  });

  factory Garden.fromJson(Map<String, dynamic> json) {
    return Garden(
      gardenID: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      // location: Location.fromJson(json['location'] as Map<String, dynamic>),
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipcode: json['zipcode'] as String,
      userIDs: List<String>.from(json['userIDs'].map((x) => x.toString())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gardenID': gardenID,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      // 'location': location.toJson(),
      'address': address,
      'city': city,
      'state': state,
      'zipcode': zipcode,
      'userIDs': userIDs,
    };
  }
}