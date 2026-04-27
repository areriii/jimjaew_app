import 'dart:io';
import 'package:flutter/material.dart';

import 'package:jimjaew_app/home_screen/product_form_screen.dart';
import 'package:jimjaew_app/products/product_manager.dart';
// 🔹 เปลี่ยนมา Import ไฟล์ชื่อใหม่
import 'package:jimjaew_app/products/shop_item_model.dart';

import '../home_screen/product_detail_screen.dart';

enum ProductView { list, grid }

// 🔹 อัปเดตให้รับค่าเป็น List<ShopItemModel>
Widget productInGrid(List<ShopItemModel> products) {
  return GridView.builder(
    padding: const EdgeInsets.all(8),
    itemCount: products.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 0.7,
    ),
    itemBuilder: (context, index) {
      final item = products[index];
      return GestureDetector(
        // หมายเหตุ: หากหน้า ProductDetailScreen ยังรับค่าเป็น ProductModel ตัวเก่าอยู่
        // คุณอาจจะต้องเข้าไปแก้ในหน้านั้นให้รับค่าเป็น ShopItemModel ด้วยนะครับ
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: item))),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: item.imagePath == null
                    ? const Icon(Icons.image, size: 50)
                    : Image.file(File(item.imagePath!), fit: BoxFit.cover, width: double.infinity),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(item.name, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("${item.price} THB", style: const TextStyle(color: Colors.orange)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// 🔹 อัปเดตให้รับค่าเป็น List<ShopItemModel>
Widget productInList(List<ShopItemModel> products) {
  final manager = ProductManager();
  return ListView.builder(
    itemCount: products.length,
    itemBuilder: (context, index) {
      final item = products[index];
      return ListTile(
        leading: item.imagePath != null ? Image.file(File(item.imagePath!), width: 50, height: 50, fit: BoxFit.cover) : const Icon(Icons.image),
        title: Text(item.name),
        subtitle: Text("${item.price} THB | Stock: ${item.stock}"),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => manager.deleteProduct(item.id),
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductFormScreen(product: item))),
      );
    },
  );
}