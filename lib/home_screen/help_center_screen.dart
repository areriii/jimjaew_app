// ศูนย์ช่วยเหลือ

import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('ศูนย์ช่วยเหลือ'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ---------------------------------------------
          // ส่วนที่ 1: ช่องทางการติดต่อ
          // ---------------------------------------------
          const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              "ช่องทางการติดต่อ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          _buildContactCard(Icons.headset_mic, 'ติดต่อเจ้าหน้าที่ (Live Chat)', 'ให้บริการ 09:00 - 18:00 น.', Colors.blue),
          _buildContactCard(Icons.phone, 'โทรสายด่วน (Call Center)', '02-XXX-XXXX', Colors.green),
          _buildContactCard(Icons.email, 'ส่งอีเมลหาเรา', 'support@jimjaew.com', Colors.orange),

          const SizedBox(height: 24),

          // ---------------------------------------------
          // ส่วนที่ 2: คำถามที่พบบ่อย (FAQ)
          // ---------------------------------------------
          const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              "คำถามที่พบบ่อย (FAQ)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),

          // โค้ดคำถาม-คำตอบ (พอกดแล้วจะสไลด์ข้อความลงมา)
          _buildFAQTile(
            'ฉันจะสั่งซื้อสินค้าได้อย่างไร?',
            'คุณสามารถเลือกสินค้าที่ต้องการ กดปุ่ม "ซื้อสินค้า" สีฟ้าด้านล่าง แล้วระบบจะนำคุณไปสู่ขั้นตอนการชำระเงินครับ',
          ),
          _buildFAQTile(
            'สามารถยกเลิกคำสั่งซื้อได้ไหม?',
            'ได้ครับ! หากสินค้าของคุณยังอยู่ในสถานะ "อยู่ระหว่างการส่ง" คุณสามารถไปที่เมนู "คำสั่งซื้อของฉัน" แล้วกดปุ่มยกเลิกสีแดงได้เลยครับ',
          ),
          _buildFAQTile(
            'ใช้เวลาจัดส่งกี่วัน?',
            'โดยปกติทางร้านจะใช้เวลาจัดส่งประมาณ 2-3 วันทำการ ขึ้นอยู่กับพื้นที่ของลูกค้าครับ',
          ),
          _buildFAQTile(
            'ฉันจะได้รับเงินค่าขายสินค้าตอนไหน?',
            'รายได้จะเข้าสู่ระบบ "รายได้ของร้าน" ก็ต่อเมื่อลูกค้าได้รับของและกดปุ่ม "ฉันได้รับสินค้าแล้ว" สีเขียวเท่านั้นครับ',
          ),
          _buildFAQTile(
            'จะเปลี่ยนรูปโปรไฟล์ต้องทำอย่างไร?',
            'ขณะนี้แอปของเรากำลังพัฒนาระบบแก้ไขโปรไฟล์อยู่ อดใจรอการอัปเดตในเวอร์ชันหน้านะครับ!',
          ),
        ],
      ),
    );
  }

  // 🌟 ฟังก์ชันสำหรับวาดกล่อง "ช่องทางการติดต่อ"
  Widget _buildContactCard(IconData icon, String title, String subtitle, Color iconColor) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // 💡 ตรงนี้ในอนาคตเราสามารถใส่โค้ดเพื่อให้มือถือเด้งเปิดแอปโทรศัพท์ หรือแอปแชทได้ครับ
        },
      ),
    );
  }

  // 🌟 ฟังก์ชันสำหรับวาดกล่อง "คำถามที่พบบ่อย" (เลื่อนเปิด/ปิดได้)
  Widget _buildFAQTile(String question, String answer) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        iconColor: Colors.blue,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    answer,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.5, fontSize: 13),
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