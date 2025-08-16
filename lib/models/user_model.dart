class UserModel {
  final String uid;
  final String username;
  final String email;
  final String bio;
  final String profileImage;
  final int postCount;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.bio,
    required this.profileImage,
    required this.postCount,
  });

  // Convert Firestore document to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      bio: map['bio'] ?? '',
      profileImage: map['profileImage'] ?? '',
      postCount: map['postCount'] ?? 0,
    );
  }

  // Convert UserModel to Map (for uploading or updating)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'bio': bio,
      'profileImage': profileImage,
      'postCount': postCount,
    };
  }
}
