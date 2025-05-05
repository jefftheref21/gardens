class Plant {
  String plantID;
  String gardenID;
  String name;
  String imageUrl;
  String? description; // Optional field
  double age; // Mainly for trees
  
  Plant({
    required this.plantID,
    required this.gardenID,
    required this.name,
    required this.imageUrl,
    this.description,
    required this.age,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      plantID: json['_id'] as String,
      gardenID: json['gardenID'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String?,
      age: json['age'] as double,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'plantID': plantID,
      'gardenID': gardenID,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'age': age,
    };
  }
}