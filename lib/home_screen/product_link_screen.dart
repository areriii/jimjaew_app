import 'package:flutter/material.dart';

class ProductLinkScreen extends StatelessWidget {
  const ProductLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ลิงก์สินค้า'),
        backgroundColor: const Color(0xFF4D93CF),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'จัดการลิงก์ Affiliate ของคุณที่นี่',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}