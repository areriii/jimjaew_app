import 'package:flutter/material.dart';

// หน้า Profile (โปรไฟล์ผู้ใช้)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // สีพื้นหลังทั้งหน้า
      backgroundColor: const Color(0xFFF5F5F5),

      // AppBar ด้านบน
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0, // ไม่มีเงา
      ),

      // เนื้อหาสามารถ scroll ได้
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 10),

            // 🔹 รูปโปรไฟล์
            const CircleAvatar(
              radius: 55,
              backgroundImage: NetworkImage(
                "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300",
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 ชื่อผู้ใช้
            const Text(
              "Ari Natthanan",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // 🔹 อีเมล
            const Text(
              "ari@email.com",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 กล่อง About Me
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // หัวข้อ
                  Text(
                    "About Me",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  // รายละเอียด
                  Text(
                    "ชอบขายเสื้อผ้าและกำลังทำแอปเกี่ยวกับแฟชั่นมือ 1 และมือ 2 สนใจการออกแบบแอปให้ใช้งานง่ายและดูสวยสะอาด",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 กล่องข้อมูลเพิ่มเติม (Phone / Address / Role)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),

              child: const Column(
                children: [

                  // row แสดงข้อมูล 1 บรรทัด
                  ProfileInfoRow(
                    icon: Icons.phone,
                    title: "Phone",
                    value: "099-999-9999",
                  ),

                  SizedBox(height: 14),

                  ProfileInfoRow(
                    icon: Icons.location_on,
                    title: "Address",
                    value: "Bangkok, Thailand",
                  ),

                  SizedBox(height: 14),

                  ProfileInfoRow(
                    icon: Icons.shopping_bag,
                    title: "Role",
                    value: "Buyer / Seller",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 ปุ่ม Edit Profile
            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed: () {
                  // TODO: ใส่ logic แก้ไขโปรไฟล์
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D93CF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: const Text(
                  "Edit Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 Widget ย่อย ใช้แสดงข้อมูลทีละแถว (icon + title + value)
class ProfileInfoRow extends StatelessWidget {
  final IconData icon;   // ไอคอนด้านซ้าย
  final String title;    // ชื่อหัวข้อ เช่น Phone
  final String value;    // ค่าที่แสดง เช่น เบอร์โทร

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        // ไอคอน
        Icon(icon, color: const Color(0xFF4D93CF)),

        const SizedBox(width: 12),

        // ชื่อหัวข้อ
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // ค่าข้อมูล
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}