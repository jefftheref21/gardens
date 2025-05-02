class Plant {
  String plantID;
  String name;
  String imageUrl;
  
  Plant(
    this.plantID,
    this.name,
    this.imageUrl,
  );

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      json['_id'] as String,
      json['name'] as String,
      json['url'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'plantID': plantID,
      'name': name,
      'imageUrl': imageUrl,
    };
  }
}