// เพิ่มสินค้า

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:jimjaew_app/products/product_manager.dart';
import 'package:jimjaew_app/products/shop_item_model.dart';

class ProductFormScreen extends StatefulWidget {
  final ShopItemModel? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductManager _productManager = ProductManager();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  bool get isEditMode => widget.product != null;
  bool _isLoading = false;
  String? _savedImagePath;

  // 🌟 1. เพิ่มตัวแปรเพื่อเก็บหมวดหมู่ที่ถูกเลือก และรายการหมวดหมู่ทั้งหมด
  String _selectedCategory = 'Shirt'; // ตั้งค่าเริ่มต้นเป็น Shirt
  final List<String> _categories = ['Shirt', 'Pants', 'Glasses', 'Shoes', 'Watch'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: isEditMode ? widget.product!.name : '');
    _priceController = TextEditingController(text: isEditMode ? widget.product!.price.toString() : '');
    _stockController = TextEditingController(text: isEditMode ? widget.product!.stock.toString() : '');
    _savedImagePath = widget.product?.imagePath;

    // 🌟 2. ถ้าเป็นการกด "แก้ไขสินค้า" ให้ดึงหมวดหมู่เดิมจาก Firebase มาแสดงในกล่อง Dropdown
    if (isEditMode) {
      if (_categories.contains(widget.product!.category)) {
        _selectedCategory = widget.product!.category;
      }
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      String name = _nameController.text.trim();
      double price = double.parse(_priceController.text.trim());
      int stock = int.parse(_stockController.text.trim());

      if (isEditMode) {
        await _productManager.updateProduct(widget.product!.id, {
          'name': name,
          'price': price,
          'stock': stock,
          'imagePath': _savedImagePath,
          // 🌟 3. ส่งข้อมูลหมวดหมู่ไปอัปเดตด้วย
          'category': _selectedCategory,
        });
      } else {
        // 🌟 4. ส่งข้อมูลหมวดหมู่แนบไปตอนสร้างสินค้าใหม่
        await _productManager.addProduct(name, price, stock, _savedImagePath, _selectedCategory);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndSaveImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    _savedImagePath = '${directory.path}/$fileName';
    await File(pickedFile.path).copy(_savedImagePath!);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'แก้ไขสินค้า' : 'เพิ่มสินค้าใหม่'),
        backgroundColor:  Colors.blue ,
        foregroundColor: Colors.white,
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final deleted = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("ลบสินค้า?"),
                    content: Text("ต้องการลบ ${widget.product!.name} ใช่หรือไม่?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("ยกเลิก"),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _productManager.deleteProduct(widget.product!.id);
                          if (!context.mounted) return;
                          Navigator.of(context).pop(true);
                        },
                        child: const Text("ลบ", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (!context.mounted) return;
                if (deleted == true) Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'ชื่อสินค้า', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'กรุณากรอกชื่อสินค้า' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'ราคา (บาท)', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'กรุณากรอกราคา' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'จำนวนสต็อก', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'กรุณากรอกจำนวน' : null,
              ),
              const SizedBox(height: 16),

              // 🌟 5. วาดกล่อง Dropdown สำหรับเลือกหมวดหมู่ให้แสดงบนหน้าจอ
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'หมวดหมู่สินค้า',
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickAndSaveImage,
                      icon: const Icon(Icons.photo),
                      label: const Text("เลือกรูปภาพ"),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton.filled(
                    onPressed: _savedImagePath == null ? null : () => setState(() => _savedImagePath = null),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 200,
                decoration: BoxDecoration(color: Colors.grey[200], border: Border.all(color: Colors.grey)),
                child: _savedImagePath != null
                    ? Image.file(File(_savedImagePath!), fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image, size: 50))
                    : const Center(child: Text('ไม่มีรูปภาพ')),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: _isLoading ? null : _saveData,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEditMode ? 'อัปเดตข้อมูล' : 'บันทึกสินค้า', style: const TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}