import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'checkout_screen.dart';
import 'package:jimjaew_app/products/product_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  final Color primaryBlue = const Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
            "Shopping Cart",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            height: 20,
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('cart').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyCart();
                }

                final cartItems = snapshot.data!.docs;

                double totalAmount = 0;
                for (var doc in cartItems) {
                  final data = doc.data() as Map<String, dynamic>;
                  final double price = double.tryParse(data['price']?.toString() ?? '0') ?? 0;
                  final int quantity = int.tryParse(data['quantity']?.toString() ?? '1') ?? 1;
                  totalAmount += (price * quantity);
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 10, bottom: 20),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final data = cartItems[index].data() as Map<String, dynamic>;
                          final docId = cartItems[index].id;

                          final String productName = data['productName']?.toString() ?? 'ไม่ระบุสินค้า';
                          final String imagePath = data['imagePath']?.toString() ?? '';
                          final double price = double.tryParse(data['price']?.toString() ?? '0') ?? 0;
                          final int quantity = int.tryParse(data['quantity']?.toString() ?? '1') ?? 1;

                          return _buildCartItem(context, docId, productName, imagePath, price, quantity);
                        },
                      ),
                    ),

                    _buildBottomSummary(context, totalAmount),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, String docId, String name, String path, double price, int qty) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 85, height: 85,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.hardEdge,
            child: ProductImage(imagePath: path),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text("฿${price.toStringAsFixed(2)}", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildQtyBtn(Icons.remove, () {
                      if (qty > 1) FirebaseFirestore.instance.collection('cart').doc(docId).update({'quantity': qty - 1});
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    _buildQtyBtn(Icons.add, () {
                      FirebaseFirestore.instance.collection('cart').doc(docId).update({'quantity': qty + 1});
                    }),
                  ],
                )
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => FirebaseFirestore.instance.collection('cart').doc(docId).delete(),
          )
        ],
      ),
    );
  }

  Widget _buildBottomSummary(BuildContext context, double total) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Total Payment", style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text("฿${total.toStringAsFixed(2)}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBlue)),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: const Text("Checkout", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: primaryBlue.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text("ยังไม่มีสินค้าในตะกร้า", style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8)
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}