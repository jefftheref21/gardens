class User {
  String userID;
  String username;
  String password;
  String name;
  String? email;
  String? phoneNumber;
  String? profilePicUrl;
  String? bio;

  // Named parameter constructor with required fields
  User({
    required this.userID,
    required this.username,
    required this.password,
    required this.name,
    this.email,
    this.phoneNumber,
    this.profilePicUrl,
    this.bio,
  });

  // Factory constructor to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userID: json['_id'] as String,
      username: json['username'] as String,
      name: json['name'] as String,
      password: json['password'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profilePicUrl: json['profilePicUrl'] as String?,
      bio: json['bio'] as String?,
    );
  }

  // Method to convert a User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'username': username,
      'name': name,
      'password': password,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicUrl': profilePicUrl,
      'bio': bio,
    };
  }
}