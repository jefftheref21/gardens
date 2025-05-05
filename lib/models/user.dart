class User {
  String userID;
  String username;
  String name;
  String? email;
  String? phoneNumber;
  String? profilePicUrl;
  String? biography;
  List<String> gardenIDs;

  // Named parameter constructor with required fields
  User({
    required this.userID,
    required this.username,
    required this.name,
    this.email,
    this.phoneNumber,
    this.profilePicUrl,
    this.biography,
    this.gardenIDs = const [],
  });

  // Factory constructor to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userID: json['_id'] as String,
      username: json['username'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profilePicUrl: json['profilePicUrl'] as String?,
      biography: json['biography'] as String?,
      gardenIDs: List<String>.from(json['gardenIDs'].map((x) => x.toString())),
    );
  }

  // Method to convert a User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'username': username,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicUrl': profilePicUrl,
      'biography': biography,
      'gardenIDs': gardenIDs,
    };
  }
}