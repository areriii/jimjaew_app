//

import 'package:flutter/material.dart';
import 'package:jimjaew_app/model/product_model.dart';
import 'package:jimjaew_app/home_screen/product_detail_screen.dart';
import 'package:jimjaew_app/products/shop_item_model.dart';

class AllProductsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const AllProductsScreen({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("All Products"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 0.58,
          ),
          itemBuilder: (context, index) {
            final product = products[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                    // 🔴 โค้ดใหม่ที่ถูกต้อง ✅
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        // แพ็กข้อมูลใส่กล่อง ShopItemModel ก่อนส่งไปหน้า Detail
                        product: ShopItemModel(
                          id: 'mock_id', // ใส่ ID จำลอง
                          name: product["name"] ?? "ไม่มีชื่อ",
                          // แปลงราคาให้กลายเป็นตัวเลขทศนิยม
                          price: double.tryParse(product["price"].toString()) ?? 0.0,
                          stock: 10, // ใส่สต็อกจำลอง
                          imagePath: null,
                          category: 'Shirt',
                        ),
                      ),
                    )
                );
              },
              child: ProductCard(
                name: product["name"] ?? "",
                price: product["price"] ?? "",
                rating: product["rating"] ?? 0,
                isFavorite: product["favorite"] ?? false,
                imageUrl: product["image"] ?? "",

                onFavoriteToggle: () {
                  product["favorite"] = !(product["favorite"] ?? false);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}