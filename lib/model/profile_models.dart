class ProfileResponse {
  final String id;
  final String studentId;
  final String email;
  final String firstName;
  final String lastName;

  ProfileResponse({
    required this.id,
    required this.studentId,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      id: json['id'],
      studentId: json['studentId'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }
}
