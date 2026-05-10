// คำสั่งซื้อของฉัน

import 'package:flutter/material.dart';
// 🔴 เช็ค Import ให้ตรงกับโฟลเดอร์ของคุณ
import 'package:jimjaew_app/products/order_manager.dart';

class OrderScreen extends StatelessWidget {
  OrderScreen({super.key});

  final OrderManager _orderManager = OrderManager();
  // 🌟 เพิ่มฟังก์ชัน Pop-up ยืนยันการยกเลิก ไว้ตรงนี้ครับ (ก่อนถึง Widget build)
  void _showCancelDialog(BuildContext context, String orderId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยกเลิกคำสั่งซื้อ?"),
        content: Text("คุณต้องการยกเลิกรายการ '$name' ใช่หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ไม่", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              // 1. สั่งลบข้อมูลออกจาก Firebase
              await _orderManager.cancelOrder(orderId);
              // 2. ปิดหน้าต่าง Pop-up
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("ใช่, ยกเลิกเลย", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('คำสั่งซื้อของฉัน'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      // 🌟 ใช้ StreamBuilder คอยฟังว่ามีออเดอร์ใหม่เข้ามารึเปล่า
      body: StreamBuilder<List<OrderModel>>(
        stream: _orderManager.getMyPurchasesStream(), // ดึงเฉพาะของที่ฉันซื้อ
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ถ้ายังไม่มีใครซื้อของเลย ให้โชว์หน้าว่างๆ (แบบรูปของคุณ)
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text("ยังไม่มีคำสั่งซื้อในขณะนี้", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          // ถ้ามีคำสั่งซื้อแล้ว ให้โชว์เป็นรายการ (List)
          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final date = order.createdAt.toDate();
              final dateString = "${date.day}/${date.month}/${date.year}";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.local_shipping, color: Colors.white),
                        ),
                        title: Text(order.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("วันที่สั่ง: $dateString"),
                            // 🌟 5. แสดงสถานะสินค้าพร้อมสีที่ต่างกัน
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: order.status == 'ส่งแล้ว' ? Colors.green.shade100 : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.status,
                                style: TextStyle(
                                  color: order.status == 'ส่งแล้ว' ? Colors.green : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Text("฿${order.totalPrice}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                      const Divider(),
                      // 🌟 6. เพิ่มปุ่มกดยกเลิกคำสั่งซื้อ
                      // 🌟 6. แถบปุ่มกด (จะโชว์ปุ่มต่างกันตามสถานะ)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // ถ้าสถานะ 'อยู่ระหว่างการส่ง' ให้โชว์ทั้งปุ่มยกเลิก และ ปุ่มรับสินค้า
                          if (order.status == 'อยู่ระหว่างการส่ง') ...[
                            TextButton(
                              onPressed: () => _showCancelDialog(context, order.id, order.productName),
                              child: const Text("ยกเลิก", style: TextStyle(color: Colors.red)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                // พอกดปุ่มนี้ ให้วิ่งไปเปลี่ยนสถานะใน Firebase เป็น 'ส่งแล้ว'
                                await _orderManager.updateOrderStatus(order.id, 'ส่งแล้ว');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('🎉 ยืนยันการรับสินค้าสำเร็จ!'), backgroundColor: Colors.green),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: const Text("ฉันได้รับสินค้าแล้ว"),
                            ),
                          ],

                          // ถ้าสถานะเป็น 'ส่งแล้ว' ให้โชว์แค่ข้อความขอบคุณ (ไม่มีปุ่มให้กดแล้ว)
                          if (order.status == 'ส่งแล้ว')
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("ขอบคุณที่อุดหนุน!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}