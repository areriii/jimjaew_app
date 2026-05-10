// หน้า ผู้ติดตาม  กำลังติดตาม

import 'package:flutter/foundation.dart';

class FollowManager {
  // สร้างตัวแปรแบบพิเศษ (ValueNotifier) เริ่มต้นที่ 15 คน
  // เมื่อค่านี้เปลี่ยน หน้าจอไหนที่จ้องมองมันอยู่จะเปลี่ยนตามทันที!
  static final ValueNotifier<int> followingCount = ValueNotifier<int>(15);
}