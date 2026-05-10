import 'dart:io';
import 'package:flutter/material.dart';

// 🔴 เช็ค Import ให้อยู่ในโฟลเดอร์ products ให้หมด
import 'package:jimjaew_app/home_screen/product_detail_screen.dart'; // ✅ ถูก
import 'package:jimjaew_app/home_screen/product_form_screen.dart';   // ✅ ถูก
import 'package:jimjaew_app/products/product_manager.dart';
import 'package:jimjaew_app/products/shop_item_model.dart'; // ✅ ดึงโมเดลตัวใหม่มาใช้

enum ProductView { list, grid }

// ✅ เปลี่ยนจาก ProductModel เป็น ShopItemModel
Widget productInGrid(List<ShopItemModel> products) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GridView.builder(
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        childAspectRatio: 3 / 4.5,
      ),
      itemBuilder: (context, index) {
        final item = products[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: item)
              ),
            );
          },
          child: Card(
            color: Colors.white70,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    color: Colors.white54,
                    width: double.infinity,
                    child: item.imagePath == null
                        ? const Icon(Icons.image, size: 50, color: Colors.blueAccent)
                        : Image.file(
                      File(item.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_,_,_) =>
                          Icon(Icons.broken_image_outlined, color: Colors.blueGrey.shade200, size: 100,),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                "${item.price} THB",
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// ✅ เปลี่ยนจาก ProductModel เป็น ShopItemModel
Widget productInList(List<ShopItemModel> products) {
  final ProductManager productManager = ProductManager();
  return ListView.builder(
    itemCount: products.length,
    itemBuilder: (context, index) {
      final product = products[index];

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Container(
          color: Colors.white,
          child: ListTile(
            title: Text(product.name),
            subtitle: Text('฿${product.price} | Stock: ${product.stock}'),
            minTileHeight: 100,
            tileColor: Colors.white24,
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("ลบสินค้า?"),
                    content: Text("ต้องการลบ ${product.name} ใช่หรือไม่?"),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          await productManager.deleteProduct(product.id);
                          if (!context.mounted) return;
                          Navigator.of(context).pop(true);
                        },
                        child: const Text("ลบ", style: TextStyle(color: Colors.red)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text("ยกเลิก"),
                      ),
                    ],
                  ),
                );
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductFormScreen(product: product),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}