import 'package:flutter/material.dart';

// หน้าแสดงรายละเอียดสินค้า
class ProductDetailScreen extends StatefulWidget {

  // รับค่ามาจากหน้า Home (ตอนกดสินค้า)
  final String name;
  final String price;
  final int rating;
  final bool isFavorite;
  final String imageUrl;
  final String description;

  const ProductDetailScreen({
    super.key,
    required this.name,
    required this.price,
    required this.rating,
    required this.isFavorite,
    required this.imageUrl,
    required this.description,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {

  // ขนาดที่เลือก (default = M)
  String selectedSize = "M";

  // สีที่เลือก (index)
  int selectedColorIndex = 2;

  // สถานะ favorite (หัวใจ)
  late bool isFavorite;

  // list ขนาด
  final List<String> sizes = ["XS", "S", "M", "L", "XL"];

  // list สี
  final List<Color> colors = [
    const Color(0xFF2DD4BF),
    const Color(0xFF38BDF8),
    const Color(0xFF083B5C),
  ];

  @override
  void initState() {
    super.initState();

    // เอาค่า favorite จากหน้าก่อนมาใช้
    isFavorite = widget.isFavorite;
  }

  // ฟังก์ชันสร้างดาว rating
  Widget buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // สีพื้นหลังด้านบน
      backgroundColor: const Color(0xFFF6E7E5),

      body: SafeArea(
        child: Column(
          children: [

            // 🔼 ส่วนรูปสินค้า
            Expanded(
              flex: 5,
              child: Stack(
                children: [

                  // รูปสินค้า
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFD9D9D9),
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.contain,

                      // ถ้ารูปโหลดไม่ได้
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.image_not_supported, size: 50),
                        );
                      },
                    ),
                  ),

                  // ปุ่มย้อนกลับ
                  Positioned(
                    top: 22,
                    left: 20,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF62B0F6),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔽 กล่องรายละเอียดด้านล่าง
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),

                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),

                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ชื่อสินค้า + หัวใจ
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // ปุ่ม favorite
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isFavorite = !isFavorite;
                              });
                            },
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // ราคา + rating
                      Row(
                        children: [
                          Text(
                            widget.price,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // ดาว rating
                          buildStarRating(widget.rating),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 🔹 Description
                      const Text(
                        "Description:",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        widget.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // 🔹 Size
                      const Text(
                        "Size:",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ปุ่มเลือก size
                      Row(
                        children: sizes.map((size) {
                          final isSelected = selectedSize == size;

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedSize = size;
                                });
                              },

                              child: Container(
                                width: 46,
                                height: 46,
                                alignment: Alignment.center,

                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF5B9DDB)
                                      : const Color(0xFFAED0F0),
                                  borderRadius: BorderRadius.circular(8),
                                ),

                                child: Text(
                                  size,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 28),

                      // 🔹 Colors
                      const Text(
                        "Colors Available:",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ปุ่มเลือกสี
                      Row(
                        children: List.generate(colors.length, (index) {
                          final isSelected = selectedColorIndex == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedColorIndex = index;
                              });
                            },

                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 44,
                              height: 44,

                              decoration: BoxDecoration(
                                color: colors[index],
                                shape: BoxShape.circle,
                              ),

                              // ถ้าเลือกแล้วโชว์ ✔
                              child: isSelected
                                  ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 28,
                              )
                                  : null,
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 30),

                      // 🔹 ปุ่ม Add To Cart
                      SizedBox(
                        width: double.infinity,
                        height: 56,

                        child: ElevatedButton(
                          onPressed: () {},

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4D93CF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),

                          child: const Text(
                            "Add To Cart",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}