// ไฟล์ lib/model/register_model.dart

class RegisterModel {
  final bool isSuccess;
  final String? message;

  RegisterModel({
    required this.isSuccess,
    this.message,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      // 🌟 แก้ตรงนี้! ให้มันรู้จักคำว่า is_success ที่เซิร์ฟเวอร์ส่งมา
      isSuccess: json['is_success'] ?? json['isSuccess'] ?? false,
      message: json['message'],
    );
  }
}