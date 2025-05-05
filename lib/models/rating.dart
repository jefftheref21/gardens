class Rating {
  String ratingID;
  String gardenID;
  String userID;
  String? comment;
  DateTime lastModified;

  Rating ({
    required this.ratingID,
    required this.gardenID,
    required this.userID,
    this.comment,
    required this.lastModified,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      ratingID: json['_id'] as String,
      gardenID: json['gardenID'] as String,
      userID: json['userID'] as String,
      comment: json['comment'] as String?,
      lastModified: DateTime.parse(json['lastModified'] as String),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'ratingID': ratingID,
      'gardenID': gardenID,
      'userID': userID,
      'comment': comment,
      'lastModified': lastModified,
    };
  }
}