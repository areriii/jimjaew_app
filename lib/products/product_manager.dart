

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
// 🔹 เปลี่ยนมา Import ไฟล์ชื่อใหม่
import 'package:jimjaew_app/products/shop_item_model.dart';

class ProductManager {
  final CollectionReference _productCollection = FirebaseFirestore.instance.collection('products');

  Future<void> addProduct(String name, double price, int stock, String? imagePath ,String category) async {
    try {
      await _productCollection.add({
        'name': name,
        'price': price,
        'stock': stock,
        'imagePath': imagePath,
        'category': category,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to add product: $e');
    }
  }

  // 🌟 1. ฟังก์ชันเดิม: ดึงสินค้า "ทั้งหมด" (เอาไว้โชว์ในหน้าจัดการสินค้า)
  Stream<List<ShopItemModel>> getProductsStream() {
    return _productCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ShopItemModel.fromFirestore(doc)).toList();
    });
  }

  // 🌟 2. ฟังก์ชันใหม่: ดึงสินค้า "แยกตามหมวดหมู่" (เอาไว้โชว์เวลาคลิกวงกลมหมวดหมู่)
  Stream<List<ShopItemModel>> getProductsByCategoryStream(String category) {
    return _productCollection
        .where('category', isEqualTo: category) // กรองเฉพาะหมวดหมู่
    // (เอา orderBy ออกชั่วคราว เพื่อป้องกัน Error จากระบบ Firebase Index)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ShopItemModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> updatedData) async {
    try {
      updatedData['updated_at'] = FieldValue.serverTimestamp();
      await _productCollection.doc(productId).update(updatedData);
    } catch (e) {
      debugPrint('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _productCollection.doc(productId).delete();
    } catch (e) {
      debugPrint('Failed to delete product: $e');
    }
  }
  // เพิ่มเข้าไปในคลาส ProductManager
  Future<void> toggleFavorite(String productId, bool currentStatus) async {
    await _productCollection.doc(productId).update({
      'isFavorite': !currentStatus, // สลับค่าเป็นตรงกันข้าม
    });
  }
}