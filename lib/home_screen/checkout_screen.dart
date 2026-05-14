import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = 'PromptPay';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("การชำระเงิน"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cart').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LinearProgressIndicator();

          double subtotal = 0;
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            subtotal += (data['price'] ?? 0) * (data['quantity'] ?? 1);
          }
          double total = subtotal + 50.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle("ที่อยู่จัดส่ง"),
                _buildAddressCard(),
                const SizedBox(height: 20),
                _buildTitle("เลือกช่องทางชำระเงิน"),
                _buildPaymentOption("สแกน QR โค้ด (PromptPay)", Icons.qr_code_scanner, 'PromptPay'),
                _buildPaymentOption("บัตรเครดิต / เดบิต", Icons.credit_card, 'CreditCard'),
                _buildPaymentOption("ชำระเงินปลายทาง (COD)", Icons.local_shipping, 'COD'),
                const SizedBox(height: 20),
                _buildTitle("สรุปยอดสั่งซื้อ"),
                _buildSummaryCard(subtotal, total),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _processPayment(snapshot.data!.docs, total),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("ยืนยันการชำระเงิน", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  );

  Widget _buildAddressCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: const Row(
      children: [
        Icon(Icons.location_on, color: Colors.blue),
        SizedBox(width: 12),
        Text("คุณลูกค้า (081-234-5678)\n123 ม.ธรรมศาสตร์ ศูนย์รังสิต...", style: TextStyle(fontSize: 13)),
      ],
    ),
  );

  Widget _buildPaymentOption(String title, IconData icon, String value) {
    bool isSelected = _selectedPayment == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
            Radio(value: value, groupValue: _selectedPayment, onChanged: (v) => setState(() => _selectedPayment = v.toString())),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double subtotal, double total) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("ยอดรวมสินค้า"), Text("฿$subtotal")]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("ค่าจัดส่ง"), const Text("฿50.0")]),
        const Divider(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("ยอดสุทธิ", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("฿$total", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
        ]),
      ],
    ),
  );

  void _processPayment(List<QueryDocumentSnapshot> docs, double total) async {
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final String productId = data['productId'];
      final int quantity = data['quantity'];
      final productRef = FirebaseFirestore.instance
          .collection('products')
          .doc(productId);
      final productSnapshot = await productRef.get();
      if (!productSnapshot.exists) continue;
      final productData = productSnapshot.data()!;
      int currentStock = productData['stock'] ?? 0;
      if (currentStock < quantity) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${data['productName']} สินค้าไม่พอ',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      await productRef.update({
        'stock': currentStock - quantity,
      });
      await FirebaseFirestore.instance.collection('orders').add({
        'productId': productId,
        'productName': data['productName'],
        'price': data['price'],
        'quantity': quantity,
        'totalPrice': total,
        'status': 'In Delivery',
        'paymentMethod': _selectedPayment,
        'orderDate': Timestamp.now(),
        'imagePath': data['imagePath'],
      });
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(doc.id)
          .delete();
    }
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderScreen(),
        ),
      );
    }
  }
}