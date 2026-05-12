import 'package:cloud_firestore/cloud_firestore.dart';

class ShopItemModel {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String? imagePath;
  final String category;
  // 🌟 เพิ่มตัวแปรสำหรับเก็บดาวรีวิวและจำนวนคนรีวิว
  final double rating;
  final int reviewCount;
  // ในคลาส ShopItemModel เพิ่มฟิลด์นี้ครับ
  final bool isFavorite;

  ShopItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.imagePath,
    required this.category,
    this.rating = 4.5, // ค่าเริ่มต้น 4.5 ดาว
    this.reviewCount = 24, // จำนวนคนรีวิวเริ่มต้น 24 รีวิว
    this.isFavorite = false, // เพิ่มตรงนี้
  });

  factory ShopItemModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;

    // สุ่มดาวเบาๆ ให้สินค้าแต่ละชิ้นมีดาวไม่เท่ากันเพื่อความสมจริง (เช่น 4.0, 4.5, 4.8, 5.0)
    final List<double> mockRatings = [4.0, 4.3, 4.5, 4.7, 4.8, 5.0];
    final List<int> mockReviewCounts = [12, 28, 45, 89, 120];
    int randomIndex = doc.id.hashCode.abs();

    return ShopItemModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: double.tryParse(data['price'].toString()) ?? 0.0,
      stock: data['stock'] ?? 0,
      // ดักจับทั้ง 2 ชื่อเผื่อไว้เลย ถ้าหา imagePath ไม่เจอ ให้ไปหา image_path แทน
      imagePath: data['imagePath'] ,
      category: data['category'] ?? 'Shirt',
      // ดึงค่าจริงจาก Firebase (ถ้ามี) หรือถ้าไม่มีให้สุ่มเพื่อความสวยงาม
      rating: data['rating'] != null
          ? double.tryParse(data['rating'].toString()) ?? 4.5
          : mockRatings[randomIndex % mockRatings.length],
      reviewCount: data['reviewCount'] ?? mockReviewCounts[randomIndex % mockReviewCounts.length],
      // 🌟 เพิ่มบรรทัดนี้เพื่อให้ดึงค่าหัวใจมาจาก Firebase ได้
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'imagePath': imagePath,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFavorite': isFavorite,
    };
  }
}