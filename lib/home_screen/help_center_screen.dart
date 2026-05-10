// ศูนย์ช่วยเหลือ
// หน้านี้ใช้สำหรับแสดงช่องทางการติดต่อ และคำถามที่พบบ่อยของแอป
// คอมเมนต์เป็นภาษาไทย ส่วนข้อความที่แสดงในแอปเป็นภาษาอังกฤษทั้งหมด

import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // AppBar ด้านบนของหน้าศูนย์ช่วยเหลือ
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      // เนื้อหาหลักของหน้า ใช้ ListView เพื่อให้เลื่อนดูข้อมูลได้
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ---------------------------------------------
          // ส่วนที่ 1: ช่องทางการติดต่อ
          // ---------------------------------------------
          const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              "Contact Channels",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // การ์ดช่องทางติดต่อเจ้าหน้าที่ผ่าน Live Chat
          _buildContactCard(
            Icons.headset_mic,
            'Live Chat Support',
            'Available from 09:00 AM - 06:00 PM',
            Colors.blue,
          ),

          // การ์ดช่องทางติดต่อผ่าน Call Center
          _buildContactCard(
            Icons.phone,
            'Call Center',
            '02-XXX-XXXX',
            Colors.green,
          ),

          // การ์ดช่องทางติดต่อผ่านอีเมล
          _buildContactCard(
            Icons.email,
            'Email Support',
            'support@jimjaew.com',
            Colors.orange,
          ),

          const SizedBox(height: 24),

          // ---------------------------------------------
          // ส่วนที่ 2: คำถามที่พบบ่อย
          // ---------------------------------------------
          const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              "Frequently Asked Questions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // คำถามที่ 1: วิธีสั่งซื้อสินค้า
          _buildFAQTile(
            'How can I place an order?',
            'You can select the product you want, tap the "Buy Now" button, and the system will process your purchase.',
          ),

          // คำถามที่ 2: การยกเลิกคำสั่งซื้อ
          _buildFAQTile(
            'Can I cancel my order?',
            'Yes. If your order is still in the "In Delivery" status, you can go to "My Orders" and tap the cancel button.',
          ),

          // คำถามที่ 3: ระยะเวลาจัดส่ง
          _buildFAQTile(
            'How long does delivery take?',
            'Delivery usually takes around 2-3 business days, depending on the customer location.',
          ),

          // คำถามที่ 4: การได้รับเงินจากการขายสินค้า
          _buildFAQTile(
            'When will I receive my sales income?',
            'Your income will appear in "Store Income" after the customer confirms that they have received the product.',
          ),

          // คำถามที่ 5: การเปลี่ยนรูปโปรไฟล์
          _buildFAQTile(
            'How can I change my profile picture?',
            'The profile editing feature is currently under development. Please wait for the next app update.',
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสำหรับสร้างการ์ดช่องทางการติดต่อ
  Widget _buildContactCard(
      IconData icon,
      String title,
      String subtitle,
      Color iconColor,
      ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      // รายละเอียดภายในการ์ดช่องทางติดต่อ
      child: ListTile(
        // ไอคอนด้านซ้ายของช่องทางติดต่อ
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),

        // ชื่อช่องทางติดต่อ
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),

        // รายละเอียดช่องทางติดต่อ
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),

        // ไอคอนลูกศรด้านขวา
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),

        onTap: () {
          // ในอนาคตสามารถเพิ่ม logic เปิดแอปโทรศัพท์ อีเมล หรือแชทได้ตรงนี้
        },
      ),
    );
  }

  // ฟังก์ชันสำหรับสร้างกล่องคำถามที่พบบ่อย
  // ใช้ ExpansionTile เพื่อให้ผู้ใช้กดเปิด/ปิดคำตอบได้
  Widget _buildFAQTile(
      String question,
      String answer,
      ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      // กล่องคำถามแบบกดขยายคำตอบได้
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        iconColor: Colors.blue,

        // ส่วนคำตอบที่จะแสดงเมื่อกดเปิด
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    answer,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}