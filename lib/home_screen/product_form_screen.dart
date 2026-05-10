// หน้าเพิ่มและแก้ไขสินค้า
// หน้านี้ใช้สำหรับเพิ่มสินค้าใหม่ หรือแก้ไขข้อมูลสินค้าที่มีอยู่แล้ว
// ข้อมูลสินค้าจะถูกบันทึกผ่าน ProductManager ไปยัง Firebase

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:jimjaew_app/products/product_manager.dart';
import 'package:jimjaew_app/products/shop_item_model.dart';

class ProductFormScreen extends StatefulWidget {
  // ถ้ามีการส่ง product เข้ามา แปลว่าเป็นโหมดแก้ไขสินค้า
  // ถ้าไม่ได้ส่ง product เข้ามา แปลว่าเป็นโหมดเพิ่มสินค้าใหม่
  final ShopItemModel? product;

  const ProductFormScreen({
    super.key,
    this.product,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  // key สำหรับตรวจสอบความถูกต้องของ Form
  final _formKey = GlobalKey<FormState>();

  // ใช้สำหรับเรียกฟังก์ชันเพิ่ม แก้ไข และลบสินค้า
  final ProductManager _productManager = ProductManager();

  // Controller สำหรับช่องกรอกชื่อสินค้า
  late TextEditingController _nameController;

  // Controller สำหรับช่องกรอกราคา
  late TextEditingController _priceController;

  // Controller สำหรับช่องกรอกจำนวนสินค้าในสต็อก
  late TextEditingController _stockController;

  // ตรวจสอบว่าหน้านี้เป็นโหมดแก้ไขสินค้าหรือไม่
  bool get isEditMode => widget.product != null;

  // ใช้สำหรับแสดงสถานะโหลดตอนกดบันทึกข้อมูล
  bool _isLoading = false;

  // ใช้เก็บ path ของรูปภาพที่เลือกไว้
  String? _savedImagePath;

  // หมวดหมู่ที่ถูกเลือกใน Dropdown
  String _selectedCategory = 'Shirt';

  // รายการหมวดหมู่ทั้งหมดที่ให้ผู้ใช้เลือก
  final List<String> _categories = [
    'Shirt',
    'Pants',
    'Glasses',
    'Shoes',
    'Watch',
  ];

  @override
  void initState() {
    super.initState();

    // ถ้าเป็นโหมดแก้ไข จะนำข้อมูลเดิมมาใส่ในช่องกรอก
    // ถ้าเป็นโหมดเพิ่มใหม่ ช่องกรอกจะเริ่มเป็นค่าว่าง
    _nameController = TextEditingController(
      text: isEditMode ? widget.product!.name : '',
    );

    _priceController = TextEditingController(
      text: isEditMode ? widget.product!.price.toString() : '',
    );

    _stockController = TextEditingController(
      text: isEditMode ? widget.product!.stock.toString() : '',
    );

    // ดึงรูปเดิมมาแสดง ถ้าเป็นการแก้ไขสินค้า
    _savedImagePath = widget.product?.imagePath;

    // ถ้าเป็นโหมดแก้ไข ให้เลือกหมวดหมู่เดิมของสินค้านั้น
    if (isEditMode) {
      if (_categories.contains(widget.product!.category)) {
        _selectedCategory = widget.product!.category;
      }
    }
  }

  @override
  void dispose() {
    // ปิด Controller เพื่อป้องกัน memory leak
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // ฟังก์ชันบันทึกข้อมูลสินค้า
  Future<void> _saveData() async {
    // ถ้าข้อมูลใน Form ไม่ถูกต้อง จะไม่ให้บันทึก
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // ดึงค่าจากช่องกรอกข้อมูล
      final String name = _nameController.text.trim();
      final double price = double.parse(_priceController.text.trim());
      final int stock = int.parse(_stockController.text.trim());

      if (isEditMode) {
        // กรณีแก้ไขสินค้าเดิม
        await _productManager.updateProduct(
          widget.product!.id,
          {
            'name': name,
            'price': price,
            'stock': stock,
            'imagePath': _savedImagePath,
            'category': _selectedCategory,
          },
        );
      } else {
        // กรณีเพิ่มสินค้าใหม่
        await _productManager.addProduct(
          name,
          price,
          stock,
          _savedImagePath,
          _selectedCategory,
        );
      }

      // ถ้าบันทึกสำเร็จ ให้ย้อนกลับไปหน้าก่อนหน้า
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // ถ้าบันทึกไม่สำเร็จ ให้แสดงข้อความ error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      }
    } finally {
      // ปิดสถานะ loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ฟังก์ชันเลือกรูปภาพจากเครื่อง
  Future<void> _pickAndSaveImage() async {
    final picker = ImagePicker();

    // เปิด Gallery เพื่อให้ผู้ใช้เลือกรูปสินค้า
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    // ถ้าผู้ใช้ไม่ได้เลือกรูป ให้หยุดทำงาน
    if (pickedFile == null) return;

    // ดึงตำแหน่งโฟลเดอร์ภายในแอป
    final directory = await getApplicationDocumentsDirectory();

    // ตั้งชื่อไฟล์ใหม่โดยใช้เวลาปัจจุบัน เพื่อไม่ให้ชื่อไฟล์ซ้ำกัน
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    // กำหนด path สำหรับเก็บรูปภาพ
    _savedImagePath = '${directory.path}/$fileName';

    // copy รูปจาก path เดิมไปเก็บไว้ในโฟลเดอร์ของแอป
    await File(pickedFile.path).copy(_savedImagePath!);

    // อัปเดตหน้าจอเพื่อแสดงรูปที่เลือก
    setState(() {});
  }

  // ฟังก์ชันแสดงกล่องยืนยันการลบสินค้า
  Future<void> _showDeleteDialog() async {
    final deleted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product?"),
        content: Text(
          "Are you sure you want to delete ${widget.product!.name}?",
        ),
        actions: [
          // ปุ่มยกเลิกการลบ
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("Cancel"),
          ),

          // ปุ่มยืนยันการลบสินค้า
          TextButton(
            onPressed: () async {
              await _productManager.deleteProduct(
                widget.product!.id,
              );

              if (!context.mounted) return;

              Navigator.of(context).pop(true);
            },
            child: const Text(
              "Delete",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    // ถ้าลบสำเร็จ ให้ย้อนกลับไปหน้าก่อนหน้า
    if (!context.mounted) return;

    if (deleted == true) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar ด้านบน
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Product' : 'Add New Product',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,

        // ถ้าเป็นโหมดแก้ไขสินค้า จะแสดงปุ่มลบสินค้า
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),

      // ส่วน Form สำหรับกรอกข้อมูลสินค้า
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ช่องกรอกชื่อสินค้า
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ช่องกรอกราคา
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Price (THB)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }

                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ช่องกรอกจำนวนสินค้าในสต็อก
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock quantity';
                  }

                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Dropdown สำหรับเลือกหมวดหมู่สินค้า
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Product Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // แถวปุ่มเลือกรูปภาพ และปุ่มล้างรูปภาพ
              Row(
                children: [
                  // ปุ่มเลือกรูปภาพสินค้า
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickAndSaveImage,
                      icon: const Icon(Icons.photo),
                      label: const Text("Choose Image"),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // ปุ่มล้างรูปภาพที่เลือกไว้
                  IconButton.filled(
                    onPressed: _savedImagePath == null
                        ? null
                        : () {
                      setState(() {
                        _savedImagePath = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // กล่องแสดง Preview รูปภาพสินค้า
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: _savedImagePath != null
                    ? Image.file(
                  File(_savedImagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.broken_image,
                      size: 50,
                    );
                  },
                )
                    : const Center(
                  child: Text('No image selected'),
                ),
              ),

              const SizedBox(height: 32),

              // ปุ่มบันทึกข้อมูลสินค้า
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: _isLoading ? null : _saveData,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : Text(
                    isEditMode ? 'Update Product' : 'Save Product',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}