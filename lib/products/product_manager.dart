
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
// 🔹 เปลี่ยนมา Import ไฟล์ชื่อใหม่
import 'package:jimjaew_app/products/shop_item_model.dart';

class ProductManager {
  final CollectionReference _productCollection = FirebaseFirestore.instance.collection('products');

  Future<void> addProduct(String name, double price, int stock, String? imagePath) async {
    try {
      await _productCollection.add({
        'name': name,
        'price': price,
        'stock': stock,
        'image_path': imagePath,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to add product: $e');
    }
  }

  // 🔹 อัปเดตให้รับส่งข้อมูลเป็น ShopItemModel
  Stream<List<ShopItemModel>> getProductsStream() {
    return _productCollection
        .orderBy('created_at', descending: true)
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
}