// คำสั่งซื้อของฉัน
// หน้านี้ใช้สำหรับแสดงรายการสินค้าที่ผู้ใช้สั่งซื้อ
// ผู้ใช้สามารถยกเลิกคำสั่งซื้อ หรือกดยืนยันว่าได้รับสินค้าแล้วได้

import 'package:flutter/material.dart';
import 'package:jimjaew_app/products/order_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderScreen extends StatelessWidget {
  OrderScreen({super.key});

  final OrderManager _orderManager = OrderManager();

  String _getDisplayStatus(String status) {
    if (status == 'อยู่ระหว่างการส่ง') return 'In Delivery';
    if (status == 'ส่งแล้ว') return 'Delivered';
    if (status == 'ยกเลิกแล้ว') return 'Cancelled';
    return status;
  }

  bool _isInDelivery(String status) {
    return status == 'In Delivery' || status == 'อยู่ระหว่างการส่ง';
  }

  bool _isDelivered(String status) {
    return status == 'Delivered' || status == 'ส่งแล้ว';
  }

  Color _getStatusBackgroundColor(String status) {
    if (_isDelivered(status)) return Colors.green.shade100;
    if (_getDisplayStatus(status) == 'Cancelled') return Colors.red.shade100;
    return Colors.orange.shade100;
  }

  Color _getStatusTextColor(String status) {
    if (_isDelivered(status)) return Colors.green;
    if (_getDisplayStatus(status) == 'Cancelled') return Colors.red;
    return Colors.orange;
  }

  // 🌟 ฟังก์ชันแสดง Pop-up (เขียนให้ใช้ dialogContext ป้องกันการเด้งผิดหน้า)
  void _showCancelDialog(BuildContext context, String orderId, String name) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text("Cancel Order?"),
        content: Text("Are you sure you want to cancel '$name'?"),
        actions: [
          // ปุ่ม No
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // ปิดแค่ Pop-up
            },
            child: const Text("No", style: TextStyle(color: Colors.grey)),
          ),
          // ปุ่ม Yes, Cancel
          TextButton(
            onPressed: () async {
              // 1. อัปเดตสถานะใน Firebase ทันที
              await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
                'status': 'Cancelled',
              });

              // 2. ปิดแค่ Pop-up
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }

              // 3. โชว์ข้อความว่ายกเลิกสำเร็จ (ใช้ context ของหน้าหลัก)
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order has been cancelled.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text(
              "Yes, Cancel",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('orderDate', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text("No orders yet", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.docs.length,
            itemBuilder: (context, index) {
              final orderDoc = orders.docs[index];
              final orderData = orderDoc.data() as Map<String, dynamic>;

              final Timestamp t = orderData['orderDate'] ?? Timestamp.now();
              final date = t.toDate();
              final dateString = "${date.day}/${date.month}/${date.year}";
              final displayStatus = _getDisplayStatus(orderData['status'] ?? 'Pending');
              final String orderId = orderDoc.id;

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
                        title: Text(
                          orderData['productName'] ?? 'Unknown Item',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Ordered on: $dateString"),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusBackgroundColor(orderData['status'] ?? ''),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                displayStatus,
                                style: TextStyle(
                                  color: _getStatusTextColor(orderData['status'] ?? ''),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          "฿${orderData['totalPrice'] ?? 0}",
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(),

                      // 🌟 แถบปุ่มด้านล่างของการ์ด
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_isInDelivery(orderData['status'] ?? '')) ...[
                            // 🌟 ปุ่ม Cancel (แก้ไขให้เรียก Pop-up ถูกต้อง)
                            TextButton(
                              onPressed: () {
                                _showCancelDialog(context, orderId, orderData['productName'] ?? 'this item');
                              },
                              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                            ),

                            const SizedBox(width: 8),

                            // 🌟 ปุ่ม I Received the Product
                            ElevatedButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
                                  'status': 'Delivered',
                                });

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Order received successfully!'),
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
                              child: const Text("I Received the Product"),
                            ),
                          ],

                          if (_isDelivered(orderData['status'] ?? ''))
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Thank you for your purchase!",
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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