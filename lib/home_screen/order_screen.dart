// คำสั่งซื้อของฉัน
// หน้านี้ใช้สำหรับแสดงรายการสินค้าที่ผู้ใช้สั่งซื้อ
// ผู้ใช้สามารถยกเลิกคำสั่งซื้อ หรือกดยืนยันว่าได้รับสินค้าแล้วได้
// คอมเมนต์ในโค้ดใช้ภาษาไทย ส่วนข้อความที่แสดงในแอปใช้ภาษาอังกฤษทั้งหมด

import 'package:flutter/material.dart';
import 'package:jimjaew_app/products/order_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderScreen extends StatelessWidget {
  OrderScreen({super.key});

  // ใช้สำหรับเรียกข้อมูลคำสั่งซื้อ และอัปเดตสถานะคำสั่งซื้อจาก Firebase
  final OrderManager _orderManager = OrderManager();

  // ฟังก์ชันแปลงสถานะเก่าที่เป็นภาษาไทยใน Firebase ให้แสดงเป็นภาษาอังกฤษบนแอป
  String _getDisplayStatus(String status) {
    if (status == 'อยู่ระหว่างการส่ง') {
      return 'In Delivery';
    } else if (status == 'ส่งแล้ว') {
      return 'Delivered';
    } else if (status == 'ยกเลิกแล้ว') {
      return 'Cancelled';
    } else {
      return status;
    }
  }

  // ฟังก์ชันเช็คว่าสถานะนี้เป็นสถานะกำลังจัดส่งหรือไม่
  bool _isInDelivery(String status) {
    return status == 'In Delivery' || status == 'อยู่ระหว่างการส่ง';
  }

  // ฟังก์ชันเช็คว่าสถานะนี้เป็นสถานะจัดส่งแล้วหรือไม่
  bool _isDelivered(String status) {
    return status == 'Delivered' || status == 'ส่งแล้ว';
  }

  // ฟังก์ชันกำหนดสีพื้นหลังของสถานะ
  Color _getStatusBackgroundColor(String status) {
    if (_isDelivered(status)) {
      return Colors.green.shade100;
    } else if (_getDisplayStatus(status) == 'Cancelled') {
      return Colors.red.shade100;
    } else {
      return Colors.orange.shade100;
    }
  }

  // ฟังก์ชันกำหนดสีตัวอักษรของสถานะ
  Color _getStatusTextColor(String status) {
    if (_isDelivered(status)) {
      return Colors.green;
    } else if (_getDisplayStatus(status) == 'Cancelled') {
      return Colors.red;
    } else {
      return Colors.orange;
    }
  }

  // ฟังก์ชันแสดง Pop-up เพื่อยืนยันการยกเลิกคำสั่งซื้อ
  void _showCancelDialog(
      BuildContext context,
      String orderId,
      String name,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Order?"),
        content: Text(
          "Are you sure you want to cancel '$name'?",
        ),
        actions: [
          // ปุ่มปิด Pop-up โดยไม่ยกเลิกคำสั่งซื้อ
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "No",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          // ปุ่มยืนยันการยกเลิกคำสั่งซื้อ
          TextButton(
            onPressed: () async {
              // สั่งลบหรือยกเลิกข้อมูลคำสั่งซื้อใน Firebase
              await _orderManager.cancelOrder(orderId);

              // ปิดหน้าต่าง Pop-up หลังจากทำงานเสร็จ
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text(
              "Yes, Cancel",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // AppBar ด้านบนของหน้าคำสั่งซื้อของฉัน
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      // ใช้ StreamBuilder เพื่อดึงคำสั่งซื้อของผู้ใช้แบบ real-time จาก Firebase
      body: StreamBuilder<List<OrderModel>>(
        // ดึงเฉพาะรายการสินค้าที่ผู้ใช้ซื้อ
        stream: _orderManager.getMyPurchasesStream(),

        builder: (context, snapshot) {
          // กรณีกำลังโหลดข้อมูลจาก Firebase
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // กรณีไม่มีคำสั่งซื้อ
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No orders yet",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          // เก็บข้อมูลคำสั่งซื้อทั้งหมดที่ดึงมาจาก Firebase
          final orders = snapshot.data!;

          // แสดงรายการคำสั่งซื้อเป็น ListView
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              // แปลง Timestamp จาก Firebase เป็นวันที่
              final date = order.createdAt.toDate();

              // จัดรูปแบบวันที่ให้แสดงแบบอ่านง่าย
              final dateString = "${date.day}/${date.month}/${date.year}";

              // แปลงสถานะให้เป็นภาษาอังกฤษสำหรับแสดงบนหน้าจอ
              final displayStatus = _getDisplayStatus(order.status);

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),

                  // เนื้อหาภายใน Card ของแต่ละคำสั่งซื้อ
                  child: Column(
                    children: [
                      ListTile(
                        // Icon ด้านซ้ายของคำสั่งซื้อ
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.local_shipping,
                            color: Colors.white,
                          ),
                        ),

                        // ชื่อสินค้าที่สั่งซื้อ
                        title: Text(
                          order.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // วันที่สั่งซื้อและสถานะคำสั่งซื้อ
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Ordered on: $dateString"),

                            // กล่องแสดงสถานะสินค้า
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusBackgroundColor(
                                  order.status,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                displayStatus,
                                style: TextStyle(
                                  color: _getStatusTextColor(order.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // ราคาสินค้า
                        trailing: Text(
                          "฿${order.totalPrice}",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const Divider(),

                      // แถบปุ่มด้านล่างของ Card
                      // จะแสดงปุ่มแตกต่างกันตามสถานะคำสั่งซื้อ
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // ถ้าสินค้าอยู่ระหว่างการส่ง จะแสดงปุ่ม Cancel และ Received
                          if (_isInDelivery(order.status)) ...[
                            TextButton(
                              onPressed: () {
                                _showCancelDialog(
                                  context,
                                  order.id,
                                  order.productName,
                                );
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            ElevatedButton(
                              onPressed: () async {
                                // เมื่อผู้ใช้กดรับสินค้าแล้ว ให้อัปเดตสถานะใน Firebase เป็นภาษาอังกฤษ
                                await _orderManager.updateOrderStatus(
                                  order.id,
                                  'Delivered',
                                );

                                // แสดงข้อความแจ้งเตือนเมื่อยืนยันรับสินค้าสำเร็จ
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Order received successfully!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: const Text(
                                "I Received the Product",
                              ),
                            ),
                          ],

                          // ถ้าสถานะเป็น Delivered แล้ว จะแสดงข้อความขอบคุณแทนปุ่ม
                          if (_isDelivered(order.status))
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Thank you for your purchase!",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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