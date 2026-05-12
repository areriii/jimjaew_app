import 'package:flutter/material.dart';

class FollowManager {
  // 🌟 ใช้ ValueNotifier เพื่อให้หน้าจออื่นๆ อัปเดตตามอัตโนมัติเมื่อค่าเปลี่ยน
  static ValueNotifier<int> followingCount = ValueNotifier<int>(16);

  // 🌟 เก็บรายการ ID ของเพื่อนที่เราติดตามไว้ใน List
  static List<String> followedUserIds = [];

  static void toggleFollow(String userId) {
    if (followedUserIds.contains(userId)) {
      followedUserIds.remove(userId);
      followingCount.value--;
    } else {
      followedUserIds.add(userId);
      followingCount.value++;
    }
  }

  static bool isFollowing(String userId) {
    return followedUserIds.contains(userId);
  }
}