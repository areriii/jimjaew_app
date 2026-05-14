
import 'package:flutter/material.dart';
import 'package:jimjaew_app/products/order_manager.dart';
import 'package:jimjaew_app/home_screen/income_screen.dart';

class SellerOrderScreen extends StatelessWidget {
  SellerOrderScreen({super.key});

  final OrderManager _orderManager = OrderManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text('Customer Orders'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: ElevatedButton.icon(
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IncomeScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.monetization_on,
                color: Colors.white,
              ),
              label: const Text(
                "View Store Income",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: _orderManager.getOrdersStream(),

              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No customer orders yet",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                final orders = snapshot.data!;

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    final date = order.createdAt.toDate();

                    final dateString =
                        "${date.day}/${date.month}/${date.year} "
                        "${date.hour}:${date.minute.toString().padLeft(2, '0')}";

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      color: Colors.white,
                      elevation: 1,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFF3E0),
                          child: Icon(
                            Icons.receipt_long,
                            color: Colors.orange,
                          ),
                        ),

                        title: Text(
                          order.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          "Ordered on: $dateString",
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),

                        trailing: Text(
                          "+ ฿${order.totalPrice}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}