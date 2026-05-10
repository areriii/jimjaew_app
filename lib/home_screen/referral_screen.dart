// หน้าแนะนำเพื่อน

import 'package:flutter/material.dart';
import 'package:jimjaew_app/home_screen/follow_manager.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  // 🌟 1. สร้างข้อมูลเพื่อนจำลอง (รายชื่อ, รูปภาพ, และสถานะว่ากดติดตามหรือยัง)
  // ในอนาคตเราสามารถดึงข้อมูลส่วนนี้มาจาก Firebase ได้ครับ
  final List<Map<String, dynamic>> _friends = [
    {"name": "สมชาย ใจดี", "username": "@somchai_dev", "isFollowing": false, "image": "https://i.pravatar.cc/150?img=11"},
    {"name": "มานะ พากเพียร", "username": "@mana_coder", "isFollowing": true, "image": "https://i.pravatar.cc/150?img=12"},
    {"name": "วิภา สวยงาม", "username": "@wipa_shop", "isFollowing": false, "image": "https://i.pravatar.cc/150?img=5"},
    {"name": "ปิติ ช่างภาพ", "username": "@piti_photo", "isFollowing": false, "image": "https://i.pravatar.cc/150?img=14"},
    {"name": "ชูใจ น่ารัก", "username": "@choojai_cute", "isFollowing": true, "image": "https://i.pravatar.cc/150?img=9"},
  ];

  // 🌟 ฟังก์ชันสลับสถานะ ติดตาม / เลิกติดตาม
  void _toggleFollow(int index) {
    setState(() {
      // ดึงสถานะเดิมมาดูก่อนว่าติดตามอยู่ไหม
      bool wasFollowing = _friends[index]["isFollowing"];

      // สลับค่า (ถ้าจริงให้เป็นเท็จ, ถ้าเท็จให้เป็นจริง)
      _friends[index]["isFollowing"] = !wasFollowing;

      // 🌟 สั่งอัปเดตตัวเลขยอด "กำลังติดตาม" แบบ Real-time!
      if (!wasFollowing) {
        // ถ้าเดิมยังไม่ติดตาม (เพิ่งกดติดตามใหม่) -> ให้บวกยอดเพิ่ม 1
        FollowManager.followingCount.value++;
      } else {
        // ถ้าเดิมติดตามอยู่แล้ว (กดยกเลิกติดตาม) -> ให้ลดยอดลง 1
        FollowManager.followingCount.value--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('แนะนำเพื่อน'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      // 🌟 3. วาดรายการเพื่อนแบบ ListView
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          final bool isFollowing = friend["isFollowing"];

          return Card(
            color: Colors.white,
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

              // รูปโปรไฟล์ (ดึงภาพจำลองจากเว็บ)
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(friend["image"]),
              ),

              // ชื่อ และ Username
              title: Text(friend["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(friend["username"], style: const TextStyle(color: Colors.grey, fontSize: 12)),

              // 🌟 4. ปุ่มกดติดตาม (เปลี่ยนสีตามสถานะ)
              trailing: SizedBox(
                width: 100, // กำหนดความกว้างปุ่มให้เท่ากัน
                height: 35,
                child: ElevatedButton(
                  onPressed: () => _toggleFollow(index),
                  style: ElevatedButton.styleFrom(
                    // ถ้าติดตามแล้วให้ปุ่มเป็นสีเทาอ่อน ถ้ายังไม่ติดตามให้เป็นสีฟ้า
                    backgroundColor: isFollowing ? Colors.grey.shade200 : Colors.blue,
                    foregroundColor: isFollowing ? Colors.black87 : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    isFollowing ? "ติดตามแล้ว" : "ติดตาม",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}