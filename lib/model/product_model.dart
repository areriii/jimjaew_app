//

import 'package:flutter/material.dart';
import 'dart:io';

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final int rating;
  final bool isFavorite;
  final String imageUrl;
  final VoidCallback onFavoriteToggle;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.rating,
    required this.isFavorite,
    required this.imageUrl,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                // 🌟 อัปเกรดระบบวาดรูปภาพตรงนี้ครับ!
                child: imageUrl.isEmpty
                    ? const Center(
                  // ถ้าไม่มีรูปเลย โชว์ไอคอนสีเทา
                  child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                )
                    : (imageUrl.startsWith('http')
                // ถ้าเป็นข้อมูลจำลอง (ขึ้นด้วย http) ให้โหลดจากเน็ต
                    ? Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  ),
                )
                // ถ้าเป็นของจริง (รูปจากในมือถือ) ให้โหลดจาก File
                    : Image.file(
                  File(imageUrl),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  ),
                )),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onFavoriteToggle,
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.black87,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              price,
              style: const TextStyle(
                color: Color(0xFFE06A6A),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            ...List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 16,
              );
            }),
          ],
        ),
      ],
    );
  }
}