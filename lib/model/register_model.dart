// โมเดลสำหรับรับผลลัพธ์จาก API สมัครสมาชิก
// ใช้เก็บสถานะว่าสมัครสำเร็จหรือไม่ และข้อความจาก server

class RegisterResponse {
  final bool isSuccess;
  final String message;

  RegisterResponse({
    required this.isSuccess,
    required this.message,
  });

  // แปลงข้อมูล JSON จาก API ให้เป็น RegisterResponse
  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      // รองรับหลายชื่อ field เผื่อ API ส่งชื่อไม่เหมือนกัน
      isSuccess: json['isSuccess'] == true ||
          json['success'] == true ||
          json['status'] == true,

      // กัน error กรณี message เป็น null หรือไม่มี field message
      message: json['message']?.toString() ??
          json['msg']?.toString() ??
          json['error']?.toString() ??
          'No message from server',
    );
  }
}