import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jimjaew_app/home_screen/cart_screen.dart';
import 'package:jimjaew_app/products/shop_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../products/order_manager.dart';
import 'package:jimjaew_app/products/product_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final ShopItemModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {

  final Color primaryBlue = const Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    final item = widget.product;

    return Scaffold(

      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),

        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
              },
              icon: const Icon(Icons.shopping_cart)
          )
        ],
      ),
      body: ListView(
        children: [

          Container(
            height: 350,
            width: double.infinity,
            color: Colors.white,
            child: ProductImage(imagePath: item.imagePath),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "฿${item.price.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: primaryBlue,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: item.stock > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.stock > 0 ? "มีสินค้า : ${item.stock} ชิ้น" : "สินค้าหมด",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: item.stock > 10 ? Colors.green : (item.stock > 0 ? Colors.orange : Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < item.rating.floor() ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 22,
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    const Text("|", style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 12),
                    Text(
                      "ขายแล้ว ${item.reviewCount * 3} ชิ้น",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),

                const Divider(height: 40, thickness: 1),
                const Text(
                  "รายละเอียดสินค้า",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "สินค้านี้ผ่านการคัดสรรคุณภาพมาอย่างดี ดีไซน์ทันสมัยเข้ากับทุกไลฟ์สไตล์ "
                      "วัสดุมีความทนทานและใช้งานได้ยาวนาน เหมาะสำหรับเป็นของขวัญหรือใช้เอง",
                  style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.6),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
            ]
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: item.stock > 0 ? () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('กำลังเพิ่มลงตะกร้า...')),
              );
              final cartRef = FirebaseFirestore.instance.collection('cart');
              final snapshot = await cartRef
                  .where('productId', isEqualTo: widget.product.id)
                  .get();
              if (snapshot.docs.isNotEmpty) {
                final docId = snapshot.docs.first.id;
                final currentQty = snapshot.docs.first.data()['quantity'] ?? 1;
                if (currentQty >= item.stock) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('จำนวนสินค้าเกินสต็อก'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                await cartRef.doc(docId).update({
                  'quantity': currentQty + 1,
                });
              } else {
                await cartRef.add({
                  'productId': widget.product.id,
                  'productName': widget.product.name,
                  'price': widget.product.price,
                  'imagePath': widget.product.imagePath ?? '',
                  'quantity': 1,
                });
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('เพิ่มลงตะกร้าสำเร็จ!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } : null,
            icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
            label: Text(
                item.stock > 0 ? "เพิ่มลงรถเข็น" : "สินค้าหมดชั่วคราว",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: item.stock > 0 ? primaryBlue : Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}