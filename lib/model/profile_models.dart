class ProfileResponse {
  final String email;
  final String firstName;
  final String lastName;

  ProfileResponse({
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }
}
