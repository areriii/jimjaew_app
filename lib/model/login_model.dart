class LoginParam {
  final String username;  //final หมายถึง "ค่าคงที่ ห้ามเปลี่ยน" เมื่อเราดึงข้อมูลที่ผู้ใช้พิมพ์มาใส่กล่องนี้แล้ว
  final String password;

  LoginParam({required this.username, required this.password});  //required: เป็นการบังคับว่า "ห้ามลืมใส่เด็ดขาด" ถ้าโปรแกรมเมอร์เผลอเขียนแค่ LoginParam(username: "a") โปรแกรมจะขึ้นเส้นแดงเตือนทันทีว่าลืมใส่รหัสผ่านครับ

  factory LoginParam.fromJson(Map<String, dynamic> json) { //factory: เป็นคำสั่งพิเศษที่บอกว่า ฟังก์ชันนี้มีหน้าที่ "ผลิต (คล้ายโรงงาน)" ออบเจกต์นี้ขึ้นมาใหม่จากข้อมูลที่รับเข้ามา //Map<String, dynamic>: เพราะข้อมูล JSON ที่มาจากอินเทอร์เน็ตจะอยู่ในรูปแบบหน้าตาแบบนี้ {"username": "admin", "age": 20}
    return LoginParam(username: json['username'], password: json['password']); //อธิบาย: ดึงข้อมูลจากก้อน JSON เอามาใส่ในแม่พิมพ์ LoginParam แล้วส่งกลับไปให้แอปใช้งาน
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
      isSuccess: json['is_success'],  //ฝั่งซ้าย (ตัวแปรในแอปเรา): เขียนว่า isSuccess (สไตล์อูฐ - Camel Case)
      profileId: json['profile_id'],  //ฝั่งขวา (ข้อมูลจากเซิร์ฟเวอร์): เขียนว่า json['is_success'] (สไตล์งู - Snake Case)
      message: json['message'],
    );
  }
}
