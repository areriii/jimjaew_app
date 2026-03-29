class LoginParam {
  final String username;
  final String password;

  LoginParam({required this.username, required this.password});

  factory LoginParam.fromJson(Map<String, dynamic> json) {
    return LoginParam(username: json['username'], password: json['password']);
  }
}

class LoginResponseModel {
  final bool isSuccess;
  final String profileId;
  final String message;

  LoginResponseModel({
    required this.isSuccess,
    required this.profileId,
    required this.message,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      isSuccess: json['is_success'],
      profileId: json['profile_id'],
      message: json['message'],
    );
  }
}
