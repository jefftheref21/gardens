class Comment {
  String commentID;
  String gardenID;
  String userID;
  String content;
  String date;

  Comment(
    this.commentID,
    this.gardenID,
    this.userID,
    this.content,
    this.date,
  );
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      json['_id'] as String,
      json['gardenID'] as String,
      json['userID'] as String,
      json['content'] as String,
      json['date'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'commentID': commentID,
      'gardenID': gardenID,
      'userID': userID,
      'content': content,
      'date': date,
    };
  }
}