// ตัวเชื่อมสินค้า
import 'package:cloud_firestore/cloud_firestore.dart';

// 🌟 1. สร้างกล่องรับข้อมูลคำสั่งซื้อ
class OrderModel {
  final String id;
  final String productName;
  final double totalPrice;
  final Timestamp createdAt;
  // 🌟 1. เพิ่มตัวแปรสถานะ
  final String status;

  OrderModel({
    required this.id,
    required this.productName,
    required this.totalPrice,
    required this.createdAt,
    required this.status, // เพิ่มตรงนี้ด้วย
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return OrderModel(
      id: doc.id,
      productName: data['productName'] ?? 'ไม่มีชื่อสินค้า',
      totalPrice: double.tryParse(data['totalPrice'].toString()) ?? 0.0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      // 🌟 2. ดึงสถานะมาจาก Firebase (ถ้าไม่มีให้เป็น 'อยู่ระหว่างการส่ง')
      status: data['status'] ?? 'อยู่ระหว่างการส่ง',
    );
  }
}

// 🌟 2. สร้างตัวจัดการ ส่งข้อมูลขึ้น/ลง Firebase
class OrderManager {
  // สร้างคอลเลกชันใหม่ใน Firebase ชื่อ 'orders'
  final CollectionReference _orderCollection = FirebaseFirestore.instance.collection('orders');
// 🌟 1. เพิ่มตะกร้าใบใหม่ (สำหรับของที่ฉันซื้อ)
  final CollectionReference _myPurchaseCollection = FirebaseFirestore.instance.collection('my_purchases');

  // ... (ฟังก์ชัน addOrder และ getOrdersStream ของเดิมปล่อยไว้เหมือนเดิมครับ) ...
  // 🌟 โค้ดส่วนที่ 2: คำสั่งจัดการระบบเทรดใน Firebase
  final CollectionReference _tradeCollection = FirebaseFirestore.instance.collection('trades');

  // 🌟 2. เพิ่มฟังก์ชันสำหรับบันทึก "ของที่ฉันซื้อ"
  Future<void> addMyPurchase(String productName, double totalPrice) async {
    await _myPurchaseCollection.add({
      'productName': productName,
      'totalPrice': totalPrice,
      'status': 'อยู่ระหว่างการส่ง', // สถานะเริ่มต้น
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 🌟 . ฟังก์ชันสำหรับ "ยกเลิกคำสั่งซื้อ" (ลบข้อมูลออกจาก Firebase)
  Future<void> cancelOrder(String orderId) async {
    await _myPurchaseCollection.doc(orderId).delete();
  }
  // 🌟 ฟังก์ชันสำหรับอัปเดตสถานะสินค้า (เช่น เปลี่ยนเป็น 'ส่งแล้ว')
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _myPurchaseCollection.doc(orderId).update({
      'status': newStatus,
    });
  }

  // 🌟 3. เพิ่มฟังก์ชันสำหรับดึง "ประวัติการซื้อของฉัน"
  Stream<List<OrderModel>> getMyPurchasesStream() {
    return _myPurchaseCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    });
  }
  // ฟังก์ชัน: สร้างคำสั่งซื้อใหม่
  Future<void> addOrder(String productName, double totalPrice) async {
    await _orderCollection.add({
      'productName': productName,
      'totalPrice': totalPrice,
      'createdAt': FieldValue.serverTimestamp(), // ประทับเวลาปัจจุบัน
    });
  }

  // ฟังก์ชัน: ดึงข้อมูลคำสั่งซื้อมาแสดงแบบ Real-time
  Stream<List<OrderModel>> getOrdersStream() {
    return _orderCollection
        .orderBy('createdAt', descending: true) // เรียงจากล่าสุดไปเก่าสุด
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    });
  }
  // ดึงข้อมูลการเทรดมาแสดงแบบ Real-time
  Stream<List<TradeModel>> getTradesStream() {
    return _tradeCollection.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TradeModel.fromFirestore(doc)).toList();
    });
  }

  // อัปเดตสถานะการเทรด (เช่น เปลี่ยนเป็น 'อนุมัติแล้ว')
  Future<void> updateTradeStatus(String tradeId, String newStatus) async {
    await _tradeCollection.doc(tradeId).update({'status': newStatus});
  }

  // สร้างคำขอเทรดใหม่ (เอาไว้จำลองลูกค้ากดส่งของมาเทรด)
  Future<void> addTradeRequest(String name, String grade, double originalPrice, double discount) async {
    await _tradeCollection.add({
      'name': name,
      'grade': grade,
      'originalPrice': originalPrice,
      'discount': discount,
      'status': 'รอตรวจสอบ',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
// 🌟 โค้ดส่วนที่ 1: สร้างโมเดลจำลองข้อมูลการเทรด
class TradeModel {
  final String id;
  final String name;
  final String grade;
  final double originalPrice;
  final double discount;
  final String status;
  final Timestamp createdAt;

  TradeModel({
    required this.id, required this.name, required this.grade,
    required this.originalPrice, required this.discount,
    required this.status, required this.createdAt
  });

  factory TradeModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return TradeModel(
      id: doc.id,
      name: data['name'] ?? 'ไม่ระบุชื่อ',
      grade: data['grade'] ?? 'N/A',
      originalPrice: double.tryParse(data['originalPrice'].toString()) ?? 0.0,
      discount: double.tryParse(data['discount'].toString()) ?? 0.0,
      status: data['status'] ?? 'รอตรวจสอบ',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}