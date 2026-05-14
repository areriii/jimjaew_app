import 'package:cloud_firestore/cloud_firestore.dart';

class ShopItemModel {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String? imagePath;
  final String category;
  final double rating;
  final int reviewCount;
  final bool isFavorite;

  ShopItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.imagePath,
    required this.category,
    this.rating = 4.5,
    this.reviewCount = 24,
    this.isFavorite = false,
  });

  factory ShopItemModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;

    final List<double> mockRatings = [4.0, 4.3, 4.5, 4.7, 4.8, 5.0];
    final List<int> mockReviewCounts = [12, 28, 45, 89, 120];
    int randomIndex = doc.id.hashCode.abs();

    return ShopItemModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: double.tryParse(data['price'].toString()) ?? 0.0,
      stock: data['stock'] ?? 0,
      imagePath: data['imagePath'] ,
      category: data['category'] ?? 'Shirt',
      rating: data['rating'] != null
          ? double.tryParse(data['rating'].toString()) ?? 4.5
          : mockRatings[randomIndex % mockRatings.length],
      reviewCount: data['reviewCount'] ?? mockReviewCounts[randomIndex % mockReviewCounts.length],
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