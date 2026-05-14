
class RegisterModel {
  final bool isSuccess;
  final String? message;

  RegisterModel({
    required this.isSuccess,
    this.message,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      isSuccess: json['is_success'] ?? json['isSuccess'] ?? false,
      message: json['message'],
    );
  }
}