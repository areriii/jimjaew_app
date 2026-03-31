class RegisterParam {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  RegisterParam({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  factory RegisterParam.fromJson(Map<String, dynamic> json) {
    return RegisterParam(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
    );
  }
}

class RegisterResponse {
  final bool isSuccess;
  final String message;

  RegisterResponse({required this.isSuccess, required this.message});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      isSuccess: json['is_success'],
      message: json['message'],
    );
  }
}
