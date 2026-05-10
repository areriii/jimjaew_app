// หน้าจัดการสินค้า
// หน้านี้ใช้สำหรับแสดงรายการสินค้าในร้าน
// สามารถสลับมุมมองระหว่าง List View และ Grid View ได้
// และมีปุ่ม + สำหรับเพิ่มสินค้าใหม่

import 'package:flutter/material.dart';
import 'package:jimjaew_app/home_screen/product_form_screen.dart';
import 'package:jimjaew_app/products/product_manager.dart';
import 'package:jimjaew_app/products/product_util.dart';
import 'package:jimjaew_app/products/shop_item_model.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  // ใช้เรียกข้อมูลสินค้าและจัดการสินค้าจาก Firebase
  final ProductManager _productManager = ProductManager();

  // ใช้เก็บสถานะมุมมองปัจจุบัน
  // ค่าเริ่มต้นเป็น list
  ProductView _productView = ProductView.list;

  // ใช้เก็บข้อมูลสินค้าที่ดึงมาจาก Firebase
  List<ShopItemModel> _products = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar ด้านบนของหน้าจัดการสินค้า
      appBar: AppBar(
        title: const Text('Manage Products'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,

        // ปุ่มด้านขวาบนสำหรับสลับ List View / Grid View
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                // ถ้าตอนนี้เป็น List ให้เปลี่ยนเป็น Grid
                // ถ้าตอนนี้เป็น Grid ให้เปลี่ยนกลับเป็น List
                _productView = _productView == ProductView.list
                    ? ProductView.grid
                    : ProductView.list;
              });
            },
            icon: Icon(
              _productView == ProductView.list
                  ? Icons.grid_view
                  : Icons.list,
            ),
          ),
        ],
      ),

      // ส่วนแสดงรายการสินค้า
      body: StreamBuilder<List<ShopItemModel>>(
        // ดึงข้อมูลสินค้าจาก Firebase แบบ real-time
        stream: _productManager.getProductsStream(),

        builder: (context, snapshot) {
          // กรณีกำลังโหลดข้อมูลสินค้า
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // กรณีโหลดข้อมูลผิดพลาด
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Something went wrong!',
              ),
            );
          }

          // กรณียังไม่มีสินค้าในระบบ
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No products yet. Tap + to add a product.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            );
          }

          // เก็บข้อมูลสินค้าที่ดึงมาจาก Firebase
          _products = snapshot.data ?? [];

          // เลือกแสดงผลตามมุมมองที่ผู้ใช้เลือก
          if (_productView == ProductView.grid) {
            // แสดงสินค้าแบบ Grid View
            return productInGrid(_products);
          } else {
            // แสดงสินค้าแบบ List View
            return productInList(_products);
          }
        },
      ),

      // ปุ่มเพิ่มสินค้าใหม่
      // ในโหมด Grid จะซ่อนปุ่มนี้ไว้ตามโค้ดเดิม
      floatingActionButton: _productView == ProductView.grid
          ? null
          : FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () {
          // เมื่อกดปุ่ม + จะไปหน้า ProductFormScreen เพื่อเพิ่มสินค้า
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}