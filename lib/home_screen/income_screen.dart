
import 'package:flutter/material.dart';
import 'package:jimjaew_app/products/order_manager.dart';

class IncomeScreen extends StatelessWidget {
  IncomeScreen({super.key});

  final OrderManager _orderManager = OrderManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text('Store Income'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_shopping_cart,
              color: Colors.white,
            ),
            tooltip: 'Add Demo Income',
            onPressed: () async {

              await _orderManager.addOrder(
                "Demo Customer Bought a Shirt",
                500.0,
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<List<OrderModel>>(
        stream: _orderManager.getOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to load income data'),
            );
          }

          final orders = snapshot.data ?? [];

          double totalIncome = 0;
          for (var order in orders) {
            totalIncome += order.totalPrice;
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 30.0,
                  horizontal: 20.0,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue,
                      Color(0xFF56CCF2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Total Income",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "฿${totalIncome.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Total sales: ${orders.length} orders",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Income History",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: orders.isEmpty
                    ? const Center(
                  child: Text(
                    "No income yet",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    final date = order.createdAt.toDate();
                    final dateString =
                        "${date.day}/${date.month}/${date.year} "
                        "${date.hour}:${date.minute.toString().padLeft(2, '0')}";

                    return Card(
                      color: Colors.white,
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8F5E9),
                          child: Icon(
                            Icons.monetization_on,
                            color: Colors.green,
                          ),
                        ),

                        title: Text(
                          order.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          dateString,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                        trailing: Text(
                          "+ ฿${order.totalPrice}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}