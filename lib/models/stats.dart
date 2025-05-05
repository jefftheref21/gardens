class Stats {
  final double averageRating;
  final double averagePlantsPerGarden;
  final double averagePlantAge;

  Stats({
    required this.averageRating,
    required this.averagePlantsPerGarden,
    required this.averagePlantAge,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      averageRating: (json['averageRating'] as num).toDouble(),
      averagePlantsPerGarden: (json['averagePlantsPerGarden'] as num).toDouble(),
      averagePlantAge: (json['averagePlantAge'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'averagePlantsPerGarden': averagePlantsPerGarden,
      'averagePlantAge': averagePlantAge,
    };
  }
}