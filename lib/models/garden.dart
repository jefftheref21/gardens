class Garden {
  String gardenID;
  String name;
  String description;
  String imageUrl;
  String location;

  Garden({
    required this.gardenID,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.location,
  });

  factory Garden.fromJson(Map<String, dynamic> json) {
    return Garden(
      gardenID: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      location: json['location'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gardenID': gardenID,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
    };
  }
}