
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String productName;
  final double totalPrice;
  final Timestamp createdAt;

  final String status;

  OrderModel({
    required this.id,

    required this.productName,
    required this.totalPrice,
    required this.createdAt,
    required this.status,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return OrderModel(
      id: doc.id,
      productName: data['productName'] ?? 'ไม่มีชื่อสินค้า',
      totalPrice: double.tryParse(data['totalPrice'].toString()) ?? 0.0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      status: data['status'] ?? 'อยู่ระหว่างการส่ง',
    );
  }
}


class OrderManager {

  final CollectionReference _orderCollection = FirebaseFirestore.instance.collection('orders');

  final CollectionReference _myPurchaseCollection = FirebaseFirestore.instance.collection('my_purchases');

  final CollectionReference _tradeCollection = FirebaseFirestore.instance.collection('trades');

  Future<void> addMyPurchase(String productName, double totalPrice) async {
    await _myPurchaseCollection.add({
      'productName': productName,
      'totalPrice': totalPrice,
      'status': 'อยู่ระหว่างการส่ง',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelOrder(String orderId) async {
    await _myPurchaseCollection.doc(orderId).delete();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _myPurchaseCollection.doc(orderId).update({
      'status': newStatus,
    });
  }

  Stream<List<OrderModel>> getMyPurchasesStream() {
    return _myPurchaseCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addOrder(String productName, double totalPrice) async {
    await _orderCollection.add({
      'productName': productName,
      'totalPrice': totalPrice,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<OrderModel>> getOrdersStream() {
    return _orderCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    });
  }

  Stream<List<TradeModel>> getTradesStream() {
    return _tradeCollection.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TradeModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateTradeStatus(String tradeId, String newStatus) async {
    await _tradeCollection.doc(tradeId).update({'status': newStatus});
  }

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