class UserProfile {
  final int sub;
  final String username;
  final String? profileImageUrl;

  UserProfile({
    required this.sub,
    required this.username,
    this.profileImageUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      sub: json['sub'],
      username: json['username'],
      profileImageUrl: json['profile_image_url'],
    );
  }
}