// หน้ากดซื้อสินค้า
// หน้านี้ใช้สำหรับแสดงรายละเอียดสินค้า รูปสินค้า ราคา สต็อก รีวิว
// และมีปุ่ม Add to Cart กับ Buy Now สำหรับสั่งซื้อสินค้า

import 'package:flutter/material.dart';
import 'package:jimjaew_app/products/shop_item_model.dart';
import '../products/order_manager.dart';

class ProductDetailScreen extends StatefulWidget {
  // รับข้อมูลสินค้าเป็นก้อน ShopItemModel
  // เพื่อให้หน้านี้สามารถใช้ข้อมูลจาก Firebase ได้โดยตรง
  final ShopItemModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // ใช้สำหรับสั่งซื้อสินค้าและบันทึกข้อมูลคำสั่งซื้อ
  final OrderManager _orderManager = OrderManager();

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลสินค้าที่ถูกส่งเข้ามาเก็บไว้ในตัวแปร item
    final item = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,

      // AppBar ด้านบนของหน้ารายละเอียดสินค้า
      appBar: AppBar(
        title: Text(item.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // ปุ่มไอคอนตะกร้าสินค้าด้านขวาบน
          IconButton(
            onPressed: () {
              // สามารถเพิ่ม logic ไปหน้า Cart ได้ในอนาคต
            },
            icon: const Icon(Icons.shopping_cart),
          ),
        ],
      ),

      // เนื้อหาหลักของหน้ารายละเอียดสินค้า
      body: ListView(
        children: [
          // ส่วนแสดงรูปภาพสินค้า
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.grey[100],
            child: _buildProductImage(item),
          ),

          // ส่วนแสดงรายละเอียดสินค้า
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ชื่อสินค้า
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // แถวราคาและจำนวนสินค้าในสต็อก
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ราคาสินค้า
                    Text(
                      "฿${item.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // สถานะสินค้าในสต็อก
                    Text(
                      item.stock > 0
                          ? "Stock: ${item.stock}"
                          : "Out of Stock",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: item.stock > 10
                            ? Colors.green
                            : (item.stock > 0 ? Colors.orange : Colors.red),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // แถวแสดงคะแนนดาว รีวิว และจำนวนที่ขายแล้ว
                Row(
                  children: [
                    // แสดงดาว 5 ดวงตามคะแนนของสินค้า
                    Row(
                      children: List.generate(
                        5,
                            (index) {
                          return Icon(
                            index < item.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    // คะแนนรีวิว เช่น 4.5
                    Text(
                      item.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 8),

                    // เส้นคั่นระหว่างคะแนนกับจำนวนขาย
                    Container(
                      height: 15,
                      width: 1,
                      color: Colors.grey.shade400,
                    ),

                    const SizedBox(width: 8),

                    // จำนวนสินค้าที่ขายแล้ว
                    Text(
                      "Sold ${item.reviewCount * 3}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                const Divider(
                  height: 40,
                  thickness: 1,
                ),

                // หัวข้อรายละเอียดสินค้า
                const Text(
                  "Product Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // รายละเอียดสินค้า
                // ตอนนี้ใช้ข้อความกลางไว้ก่อน หากมี field description ใน Firebase สามารถเปลี่ยนมาใช้ item.description ได้
                const Text(
                  "This product information is loaded from the store database. You can add a full product description in Firebase and display it here later.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ปุ่มด้านล่างของหน้ารายละเอียดสินค้า
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12.0),
        child: SafeArea(
          child: Row(
            children: [
              // ปุ่มเพิ่มสินค้าลงตะกร้า
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: item.stock <= 0
                      ? null
                      : () {
                    // สามารถเพิ่ม logic สำหรับ Add to Cart ได้ในอนาคต
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Product added to cart.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.blue,
                  ),
                  label: const Text(
                    "Add to Cart",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.blue,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ปุ่มซื้อสินค้า
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: item.stock <= 0
                      ? null
                      : () async {
                    // เมื่อกด Buy Now จะบันทึกคำสั่งซื้อของผู้ใช้ลง Firebase
                    await _orderManager.addMyPurchase(
                      item.name,
                      item.price,
                    );

                    // แสดงข้อความแจ้งเตือนเมื่อสั่งซื้อสำเร็จ
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Purchase completed successfully. Please check My Orders.',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.payment,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Buy Now",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันแสดงรูปภาพสินค้า
  // รองรับรูปจาก URL ที่บันทึกมาจาก Firebase
  Widget _buildProductImage(ShopItemModel item) {
    final imagePath = item.imagePath;

    // ถ้าไม่มีรูปภาพ ให้แสดง icon แทน
    if (imagePath == null || imagePath.isEmpty) {
      return const Icon(
        Icons.image,
        size: 100,
        color: Colors.grey,
      );
    }

    // ใช้ Image.network เพื่อให้รองรับรูปจาก Firebase Storage หรือ URL
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.broken_image,
          size: 100,
          color: Colors.grey,
        );
      },
    );
  }
}