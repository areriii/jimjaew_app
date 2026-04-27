

import 'package:cloud_firestore/cloud_firestore.dart';

class ShopItemModel {
  String id;
  String name;
  double price;
  int stock;
  String? imagePath;

  ShopItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.imagePath
  });

  factory ShopItemModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ShopItemModel(
        id: doc.id,
        name: data['name'] ?? 'Unknown',
        price: (data['price'] ?? 0.0).toDouble(),
        stock: data['stock'] ?? 0,
        imagePath: data['image_path']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'updated_at': FieldValue.serverTimestamp(),
      'image_path': imagePath
    };
  }
}