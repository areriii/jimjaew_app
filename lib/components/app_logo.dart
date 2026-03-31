import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  //กำหนดขนาดรูป เปลี่ยนขนาดหน้าอื่นๆได้
  final double width;
  final double height;

  const AppLogo({
    super.key,
    this.width = 150, //ค่า default = 150
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_jimjaew.png',
      width: width,
      height: height,
      fit: BoxFit.contain, //ไม่ให้รูปโดนตัด ให้อยู่ในกรอบที่กำหนด
    );
  }
}