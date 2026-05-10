//หน้า ระบบ เทรด
import 'package:flutter/material.dart';
// 🔴 เช็ค Import ให้ตรงกับโฟลเดอร์ของคุณนะครับ
import 'package:jimjaew_app/home_screen/seller_order_screen.dart';
import 'package:jimjaew_app/home_screen/income_screen.dart';
import 'package:jimjaew_app/products/order_manager.dart';

class TradeSystemScreen extends StatefulWidget {
  const TradeSystemScreen({super.key});

  @override
  State<TradeSystemScreen> createState() => _TradeSystemScreenState();
}

class _TradeSystemScreenState extends State<TradeSystemScreen> {
  final OrderManager _orderManager = OrderManager();

  // 🌟 ฟังก์ชันอนุมัติแล้วอัปเดตขึ้น Firebase
  void _approveTrade(TradeModel item) {
    double finalPrice = item.originalPrice - item.discount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยืนยันการอนุมัติเทรด"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("สินค้า: ${item.name}"),
            const SizedBox(height: 8),
            Text("ราคาปกติ: ฿${item.originalPrice}", style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
            Text("ส่วนลดเทรด: - ฿${item.discount}", style: const TextStyle(color: Colors.red)),
            const Divider(),
            Text("ราคาสุทธิ: ฿$finalPrice", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ยกเลิก")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // ปิด Pop-up

              // 1. เปลี่ยนสถานะใน Firebase เป็น "อนุมัติแล้ว"
              await _orderManager.updateTradeStatus(item.id, 'อนุมัติแล้ว');

              // 2. ส่งยอดเงินเข้า "รายได้ของร้าน"
              await _orderManager.addOrder("ขายสินค้า (เทรด): ${item.name}", finalPrice);

              // 3. ส่งยอดเงินเข้า "คำสั่งซื้อจากลูกค้า"
              //await _orderManager.addMyPurchase("ใช้ส่วนลดเทรด: ${item.name}", finalPrice);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('🎉 อนุมัติสำเร็จ! ระบบบันทึกข้อมูลเรียบร้อย'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text("อนุมัติและรับชำระเงิน", style: TextStyle(fontWeight: FontWeight.bold)),
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
        title: const Text('ระบบการเทรดสินค้า'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(child: _buildShortcutButton(context, 'ออเดอร์ลูกค้า', Icons.shopping_basket, Colors.orange, SellerOrderScreen())),
                const SizedBox(width: 12),
                Expanded(child: _buildShortcutButton(context, 'รายได้ของร้าน', Icons.account_balance_wallet, Colors.green, IncomeScreen())),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("รายการที่ลูกค้าส่งมาเทรด (จาก Firebase จริง)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          // 🌟 ใช้ StreamBuilder ดึงข้อมูลจริงจาก Firebase
          Expanded(
            child: StreamBuilder<List<TradeModel>>(
              stream: _orderManager.getTradesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("ยังไม่มีรายการเทรด", style: TextStyle(color: Colors.grey)));
                }

                final trades = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: trades.length,
                  itemBuilder: (context, index) {
                    final item = trades[index];
                    Color statusColor = item.status == 'อนุมัติแล้ว' ? Colors.green : (item.status == 'รอตรวจสอบ' ? Colors.orange : Colors.red);

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                      child: ListTile(
                        onTap: item.status == 'รอตรวจสอบ' ? () => _approveTrade(item) : null,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                          child: const Icon(Icons.swap_horiz, color: Colors.blue),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("สภาพ: ${item.grade} | ลด ฿${item.discount}"),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(item.status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // 🌟 ปุ่มจำลองลูกค้าส่งของมาเทรด
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // กดปุ่มนี้จะส่งข้อมูลเข้า Firebase จริงๆ
          await _orderManager.addTradeRequest('นาฬิกาสมาร์ทวอทช์', 'เกรด A', 1500.0, 400.0);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ส่งคำขอเทรดจำลองสำเร็จ!')),
            );
          }
        },
        label: const Text("จำลองลูกค้าส่งของมาเทรด", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildShortcutButton(BuildContext context, String title, IconData icon, Color color, Widget targetPage) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}